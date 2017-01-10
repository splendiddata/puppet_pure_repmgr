# == Class repmgr::clone_primary
# Private class
class repmgr::clone_primary
{
  # Stop PostgreSQL service.
  if $::postgresql_status != 'down'
  {
    exec { 'stop_postgresql':
      user    => $repmgr::postgresql_user,
      command => '/etc/init.d/postgresql stop',
    }
  }

  # Clear the postgresql data directory.
  exec { 'clear_datadir':
    cwd     => $repmgr::postgresql_data_dir,
    user    => 'root',
    command => '/bin/rm -rf *',
  }

  # Clone data from the primary.
  exec { 'clone_primary':
    user    => $repmgr::postgresql_user,
    command => "/usr/bin/repmgr -f ${repmgr::repmgr_conf_dir}/repmgr.conf \
    --verbose -d ${repmgr::repmgr_db_name} --ignore-external-config-files \
    -U ${repmgr::repmgr_db_user_name} -p 5432 -w 10 standby clone \
    ${repmgr::primary} --force",
    timeout => 900,
  }
}