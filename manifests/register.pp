# == Class: pure_repmgr::register
# Private class
class pure_repmgr::register(
   $replication_role  = $facts['pure_replication_role'],
) inherits pure_repmgr
{
   $check = $replication_role ? {
      'master'  => 'False',
      'standby' => 'True',
      default   => '',
   }

   if $check == ''{
      fail("Invalid value for \$replication_role: $replication_role")
   }

   $cmd = shellquote( "$pg_bin_dir/repmgr", '-f', "${pure_repmgr::repmgr_conf}", $replication_role, 'register')
   $unless = shellquote("${pure_postgres::pg_bin_dir}/psql", "-d", "repmgr", "-c", "select * from repmgr_${pure_cloud_cluster}.repl_nodes where pg_is_in_recovery()=$check or name='$fqdn'" )

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      unless   => "/bin/test $($unless | wc -l) -gt 1",
      onlyif   => "/bin/test -f '${pure_postgres::pg_pid_file}'",
      cwd      => $pure_postgres::pg_bin_dir,
      path    => '$pg_bin_dir:/usr/local/bin:/bin',
   }

}
