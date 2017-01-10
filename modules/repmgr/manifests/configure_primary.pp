# == Class: repmgr::configure_primary
# Private class
class repmgr::configure_primary
{
  $check_user_exists = shellquote( 'psql', '-Upostgres', '-tAc', "SELECT r.rolname FROM pg_catalog.pg_roles r WHERE r.rolname = \'${repmgr::repmgr_db_user_name}\'")
  $check_db_exists   = shellquote( 'psql', '-Upostgres', '-tAc', "SELECT datname FROM pg_database WHERE datname = \'${repmgr::repmgr_db_name}\'")

  # Set values in failover script.
  $repmgr_conf_dir     = $repmgr::repmgr_conf_dir
  $vc_server           = $repmgr::vc_server

  # Create repmgr db user, if it doesn't already exist.
  exec { 'create_repmgr_user':
    command => "createuser --login --superuser ${repmgr::repmgr_db_user_name}",
    user    => $repmgr::postgresql_user,
    cwd     => $repmgr::postgresql_home,
    path    => $repmgr::postgresql_bin_dir,
    onlyif  => "/usr/bin/test \"\$(${check_user_exists})\" != \
    ${repmgr::repmgr_db_user_name}",
  } ->

  # Create repmgr database, if it doesn't already exist.
  exec { 'create_repmgr_db':
    command => "createdb -O ${repmgr::repmgr_db_user_name} \
    ${repmgr::repmgr_db_name}",
    user    => $repmgr::postgresql_user,
    cwd     => $repmgr::postgresql_home,
    path    => $repmgr::postgresql_bin_dir,
    onlyif  => "/usr/bin/test \"\$(${check_db_exists})\" \
    != \"${repmgr::repmgr_db_name}\"",
  }

  # Create the failover script.
  file { 'primary_perform_failover.sh':
    ensure  => file,
    content => template('repmgr/perform_failover_sh.erb'),
    path    => "${repmgr::repmgr_conf_dir}/perform_failover.sh",
    group   => $repmgr::postgresql_group,
    owner   => $repmgr::postgresql_user,
    replace => true,
    mode    => '0700',
  }
}