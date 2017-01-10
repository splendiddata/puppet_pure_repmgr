# == Class: repmgr::register_primary
# Private class
class repmgr::register_primary
{
  $check_schema_exists = shellquote( 'psql', '-Upostgres', '-d', 'repmgr', '-tAc', "select schema_name from information_schema.schemata where schema_name = \'repmgr_${repmgr::cluster_name}\'" )
  $check_registration_object = shellquote( 'psql', '-Upostgres', '-d', 'repmgr', '-tAc', "select name from repmgr_${repmgr::cluster_name}.repl_nodes where name = ${repmgr::node_name}" )

  # Restart postgresql service.
  exec { 'restart_postgresql':
    user    => $repmgr::postgresql_user,
    command => '/etc/init.d/postgresql restart',
    before  => Exec['register_primary'],
  }

  # Register the primary in the database.
  exec { 'register_primary':
    command => "/usr/bin/repmgr -f ${repmgr::repmgr_conf_dir}/repmgr.conf \
    --verbose master register",
    user    => $repmgr::postgresql_user,
    cwd     => $repmgr::postgresql_home,
  }
}