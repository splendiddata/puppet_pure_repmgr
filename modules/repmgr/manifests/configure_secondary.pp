# == Class: repmgr::configure_secondary
# Private class
class repmgr::configure_secondary
{
  # Set values in failover script.
  $repmgr_conf_dir     = $repmgr::repmgr_conf_dir
  $vc_server           = $repmgr::vc_server

  # Create the failover script.
  file { 'secondary_perform_failover.sh':
    ensure  => file,
    content => template('repmgr/perform_failover_sh.erb'),
    path    => "${repmgr::repmgr_conf_dir}/perform_failover.sh",
    group   => $repmgr::postgresql_group,
    owner   => $repmgr::postgresql_user,
    replace => true,
    mode    => '0700',
  }
}