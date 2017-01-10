# == Class: repmgr
#
# Installs repmgr from repo packages, and configures a three-node replication
# cluster containing one primary and two secondaries.
#
# Following a failure of the primary, the highest priority secondary will
# promote itself to become the new primary and the lower priority secondary will
# repoint itself to replicate from the new primary.  Should the new primary also
# fail, the lower priority secondary will promote itself. Should that node also
# fail, there would be no working servers until puppet is run to reset the
# cluster.
#
# To reset configuration following a failover, drop the repmgr database on each
# node. The next puppet run will then reconfigure repmgr to it's original state.
#
# This module does not handle failback.
#
class repmgr
(
  $common_package_name    = $repmgr::params::common_package_name,
  $common_package_version = $repmgr::params::common_package_version,
  $pg_package_name        = $repmgr::params::pg_package_name,
  $pg_package_version     = $repmgr::params::pg_package_version,
  $additional_packages    = $repmgr::params::additional_packages,
  $cluster_name           = $repmgr::params::cluster_name,
  $primary                = $repmgr::params::primary,
  $node_number            = $repmgr::params::node_number,
  $node_name              = $repmgr::params::node_name,
  $node_priority          = $repmgr::params::node_priority,
  $repmgr_conf_dir        = $repmgr::params::repmgr_conf_dir,
  $repmgr_log_dir         = $repmgr::params::repmgr_log_dir,
  $postgresql_group       = $repmgr::params::postgresql_group,
  $postgresql_user        = $repmgr::params::postgresql_user,
  $postgresql_version     = $repmgr::params::postgresql_version,
  $postgresql_home        = $repmgr::params::postgresql_home,
  $repmgr_db_name         = $repmgr::params::repmgr_db_name,
  $repmgr_db_user_name    = $repmgr::params::repmgr_db_user_name,
  $vc_server              = undef,
  $notify_email           = undef,
)
{
  $postgresql_conf_dir = "/etc/postgresql/${postgresql_version}/main"
  $postgresql_data_dir = "/var/lib/postgresql/${postgresql_version}/main"
  $postgresql_bin_dir  = "/usr/lib/postgresql/${postgresql_version}/bin"

  # Ensure packages are installed / up to date.
  class { 'repmgr::install':
  }
  contain 'repmgr::install'

  # If we're already registered, skip (almost) everything. Otherwise, configure.
  if $::replication_tier !~ /(primary|secondary)/
  {
    # If we're the primary, configure as such.
    if $::hostname == $primary
    {
      class { 'repmgr::configure_primary':
        before => [ File['repmgr_conf'], Class['repmgr::register_primary'] ],
      }
      contain 'repmgr::configure_primary'
    }
    else # We must be a secondary. Configure as such.
    {
      class { 'repmgr::configure_secondary':
        before => [ File['repmgr_conf'], Class['repmgr::register_secondary'] ],
      }
      contain 'repmgr::configure_secondary'
    }

    # Create / update main repmgr config file.
    file { 'repmgr_conf':
      ensure  => file,
      content => template('repmgr/repmgr_conf.erb'),
      path    => "${repmgr_conf_dir}/repmgr.conf",
      group   => $postgresql_group,
      owner   => $postgresql_user,
      replace => true,
      mode    => '0600',
    } ->

    # Update mlocate db, as some custom facts use it to find repmgr.conf.
    exec { 'updatedb':
      command => '/usr/bin/updatedb',
    } ->

    # Create / update notify_ops.sh script.
    file { 'notify_ops_sh':
      ensure  => file,
      content => template('repmgr/notify_ops_sh.erb'),
      path    => "${repmgr_conf_dir}/notify_ops.sh",
      group   => $postgresql_group,
      owner   => $postgresql_user,
      replace => true,
      mode    => '0700',
    } ->

    # Create repmgr log file if required.
    file { 'repmgr.log':
      ensure => file,
      path   => "${repmgr_log_dir}/repmgr.log",
      group  => $postgresql_group,
      owner  => $postgresql_user,
      mode   => '0600',
    } ->

    # Create / update defaults for repmgrd.
    file { 'repmgrd_defaults':
      ensure  => file,
      content => template('repmgr/repmgrd_defaults.erb'),
      path    => '/etc/default/repmgrd',
      group   => $postgresql_group,
      owner   => $postgresql_user,
      replace => true,
      mode    => '0644',
    }

    # If we're the primary, set up repmgr database and register primary node.
    if $::hostname == $primary
    {
      # Register as a primary.
      class { 'repmgr::register_primary':
        require => File['repmgr_conf']
      }
      contain 'repmgr::register_primary'
    }
    else # We must be a secondary.
    {
      # Clone the primary.
      class { 'repmgr::clone_primary':
        require => File['repmgr_conf']
      }
      contain 'repmgr::clone_primary'

      # Register as a secondary.
      class { 'repmgr::register_secondary':
        require => [ Exec['enable_funcs'], Class['repmgr::clone_primary'] ],
        notify  => Class['repmgr::repmgrd_service'],
      }
      contain 'repmgr::register_secondary'
    }
  }

  # Ensure repmgrd is running if we're a secondary, and stopped if a primary.
  class { 'repmgr::repmgrd_service':
  }
  contain 'repmgr::repmgrd_service'
}
