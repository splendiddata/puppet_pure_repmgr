# == Class: pure_repmgr::register
# Private class
class pure_repmgr::register(
  $replication_role  = $facts['pure_replication_role'],
) inherits pure_repmgr
{
  $check = $replication_role ? {
    'master'  => 'True',
    'standby' => 'False',
    default   => '',
  }

  if $check == ''{
    fail("Invalid value for \$replication_role: ${replication_role}")
  }

  $cmd = shellquote( "${pure_postgres::params::pg_bin_dir}/repmgr", '-f', $pure_repmgr::params::repmgr_conf, $replication_role, 'register')
  $unless = shellquote( "${pure_postgres::params::pg_bin_dir}/psql", '-d', 'repmgr', '--quiet', '--tuples-only',
                        '-c', "select * from repmgr_${facts['pure_cloud_cluster']}.repl_nodes where name='${facts['fqdn']}'" )

  exec { "exec ${cmd}":
    user    => $pure_postgres::postgres_user,
    command => $cmd,
    unless  => "/bin/test $(${unless} | wc -l) -gt 1",
    onlyif  => "/bin/test -f '${pure_postgres::pg_pid_file}'",
    cwd     => $pure_postgres::pg_bin_dir,
    path    => "${pure_postgres::pg_bin_dir}:/usr/local/bin:/bin",
  }

}
