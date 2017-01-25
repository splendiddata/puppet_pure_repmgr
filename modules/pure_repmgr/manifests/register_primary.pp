# == Class: pure_repmgr::register_primary
# Private class
class pure_repmgr::register_primary(
) inherits pure_repmgr
{
   $cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/repmgr', '-f', "${pure_repmgr::repmgr_conf}", 'master', 'register')
   $unless = shellquote( "select * from repmgr_testdb.repl_nodes where type='master' or name='$fqdn'" )

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      unless   => "/bin/echo ${unless} | /usr/pgpure/postgres/9.6/bin/psql -d repmgr --quiet --tuples-only | /bin/grep -q '|'"
   }
}
