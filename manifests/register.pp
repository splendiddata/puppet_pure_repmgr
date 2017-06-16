# == Class: pure_repmgr::register
# Private class
class pure_repmgr::register(
) inherits pure_repmgr
{
  $cmdrole   = shellquote( "${pure_postgres::params::pg_bin_dir}/psql", '-c', "select case when pg_is_in_recovery() then 'standby' else 'master' end", '--quiet', '--tuples-only' )
  $cmdrepmgr = shellquote( "${pure_postgres::params::pg_bin_dir}/repmgr", '-f', $pure_repmgr::params::repmgr_conf)
  $unless    = shellquote( "${pure_postgres::params::pg_bin_dir}/psql", '-d', 'repmgr', '--quiet', '--tuples-only',
                      '-c', "select * from repmgr_${pure_repmgr::repmgr_cluster_name}.repl_nodes where name='${facts['fqdn']}'" )

  exec { "exec ${cmd}":
    user    => $pure_postgres::postgres_user,
    command => "$cmdrepmgr \$(${cmdrole}) register",
    unless  => "/bin/test $(${unless} | wc -l) -gt 1",
    onlyif  => "/bin/test -f '${pure_postgres::pg_pid_file}'",
    cwd     => $pure_postgres::pg_bin_dir,
    path    => "${pure_postgres::pg_bin_dir}:/usr/local/bin:/bin",
  }

}
