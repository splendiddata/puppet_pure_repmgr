# == Definition: pure_repmgr::clone_standby
# Private class
define pure_repmgr::clone_standby(
   $upstreamhost       = undef,
) 
{
   $cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/repmgr', '-f', "${pure_repmgr::repmgr_conf}", '-h', $upstreamhost, '-U', 'repmgr', '-d', 'repmgr', '-D', $pg_data_dir ,'standby', 'clone')

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      loglevel => 'debug',
      unless   => "/bin/test -d $pg_data_dir"
   }
}
