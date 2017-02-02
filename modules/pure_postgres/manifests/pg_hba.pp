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

   $cmd = shellquote( "$pure_postgres::pg_bin_dir/modify_pg_hba.py", '-d', $database, '-f', $pg_hba_file, '-m', $method, '-n', $netmask, '--state', $state, '-s', $source, '-t', $connection_type, '-u', $user , '--reload')

   exec { "exec $cmd":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      loglevel => 'debug',
      require  => File["$pure_postgres::pg_bin_dir/modify_pg_hba.py"]
   }

}

