# == Definition: pure_repmgr::clone_standby
# Private class
define pure_repmgr::clone_standby(
   $upstreamhost       = undef,
   $datadir            = $pure_repmgr::pg_data_dir,
) 
{

   $check_cmd = shellquote( '/bin/ssh', '-o', 'NumberOfPasswordPrompts 0', $upstreamhost, 'ls' )
   $clone_cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/repmgr', '-f', "${pure_repmgr::repmgr_conf}", '-h', $upstreamhost, '-U', 'repmgr', '-d', 'repmgr', '-D', $datadir ,'--copy-external-config-files', 'standby', 'clone')

   exec { "exec $clone_cmd":
      user     => $pure_postgres::postgres_user,
      command  => $clone_cmd,
      unless   => "/bin/test -f $datadir/PG_VERSION",
      onlyif   => $check_cmd,
   }
}
