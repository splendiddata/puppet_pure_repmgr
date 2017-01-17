# == Class: pure_postgres::pg_hba
#
# Change pg_hba on a postgrespure database server
define pure_postgres::pg_hba
(
  $database        = undef,
  $pg_hba_file     = $pure_postgres::pg_hba_conf,
  $method          = undef,
  $netmask         = '',
  $state           = 'present',
  $source          = undef,
  $connection_type = undef,
  $user            = undef,

)
{

   $cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/modify_pg_hba.py', '-d', $database, '-f', $pg_hba_file, '-m', $method, '-n', $netmask, '--state', $state, '-s', $source, '-t', $connection_type, '-u', $user )

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      loglevel => "debug",
      require  => File['/usr/pgpure/postgres/9.6/bin/modify_pg_hba.py']
   }

}

