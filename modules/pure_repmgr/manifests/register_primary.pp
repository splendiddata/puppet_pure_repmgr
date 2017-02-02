# == Class: pure_repmgr::register_primary
# Private class
class pure_repmgr::register_primary(
) inherits pure_repmgr
{
   $cmd = shellquote( "$pg_bin_dir/repmgr", '-f', "${pure_repmgr::repmgr_conf}", 'master', 'register')
   $unless = shellquote( "select * from repmgr_testdb.repl_nodes where type='master' or name='$fqdn'" )

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      unless   => "/bin/echo ${unless} | $pg_bin_dir/psql -d repmgr --quiet --tuples-only | /bin/grep -q '|'"
   }
}
