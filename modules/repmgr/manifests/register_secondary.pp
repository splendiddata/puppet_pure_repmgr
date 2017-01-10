# == Class: repmgr::register_secondary
# Private class
class repmgr::register_secondary
{
  # Start postgresql service.
  exec { 'restart_postgresql':
    user    => $repmgr::postgresql_user,
    command => '/etc/init.d/postgresql restart',
    before  => Exec['register_secondary'],
  }

  # Register the secondary in the database.
  exec { 'register_secondary':
    command => "/usr/bin/repmgr -f ${repmgr::repmgr_conf_dir}/repmgr.conf \
    --verbose --force standby register",
    user    => $repmgr::postgresql_user,
    cwd     => $repmgr::postgresql_home,
    path    => $repmgr::postgresql_bin_dir,
  }
}