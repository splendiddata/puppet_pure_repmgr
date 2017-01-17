# == Class: pure_postgres::pg_hba
#
# Configs postgres after being installed from pure repo
class pure_postgres::pg_hba
(
  $database        = undef,
  $pg_hba_file     = $pure_postgres::pg_hba_conf,
  $method          = undef,
  $netmask         = undef,
  $state           = 'present',
  $sources         = undef,
  $connection_type = undef,
  $user            = undef,

) inherits pure_postgres
{
   file { "/usr/pgpure/postgres/9.6/bin/modify_pg_hba.py":
      ensure => 'present',
      owner  => 'postgres',
      group  => 'postgres',
      mode   => '0750',
      source => 'puppet:///modules/pure_postgres/pg_hba.py',
   }

   $sources.each | String $source | {
      $cmd = shellquote( '/usr/pgpure/postgres/9.6/bin/modify_pg_hba.py', '-d', $database, '-f', $pg_hba_file, '-m', $method, '-n', $netmask, '--state', $state, '-s', $source, '-t', $connection_type, '-u', $user )

      exec { "exec $cmd":
         user     => $pure_postgres::postgres_user,
         command  => $cmd,
         loglevel => "debug",
      }
   }

}

