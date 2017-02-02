# == Class: pure_repmgr::register_standby
# Private class
class pure_repmgr::register_standby(
) inherits pure_repmgr
{

   $cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/repmgr', '-f', "${pure_repmgr::repmgr_conf}", 'standby', 'register')
   $unless = shellquote( "select * from repmgr_testdb.repl_nodes where name='$fqdn'" )

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      unless   => "/usr/bin/echo ${unless} | /usr/pgpure/postgres/9.6/bin/psql -d repmgr --quiet --tuples-only | /usr/bin/grep -q '|'",
      onlyif   => "/bin/test -f /var/pgpure/postgres/9.6/data/PG_VERSION",
   }
}
