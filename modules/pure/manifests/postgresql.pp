# == Class: pure::postgresql
#
# Installs postgres from pure repo in a bare format (without running initdb on /var/pgpure/postgres/9.6/data)
class pure::postgresql
(
  $pg_version           = $pure::params::version,
) inherits pure::params
{
   $pg_package_name     = "postgres-${pg_version}"

   #Doing this before installing rpm prevents initdb in rpm,
   #which helps in idempotency state detection of new cluster.

   group { 'pgpure':
      ensure               => present,
   }

   user { 'postgres':
      ensure               => present,
      comment              => "postgres server",
      groups               => "pgpure",
      home                 => "/home/postgres",
      managehome           => true,
      shell                => '/bin/bash',
      system               => true,
   }

   file { [  '/var/pgpure', '/var/pgpure/postgres',
            "/var/pgpure/postgres/$pg_version", "/var/pgpure/postgres/$pg_version/data" ]:
      ensure               => 'directory',
      owner                => 'postgres',
      group                => 'postgres',
      mode                 => '0700',
   }

   #End of doing stuff before RPM to prevent initdb in RPM...

   package { $pg_package_name:
      ensure => 'installed',
   }

   # create a directory      
   file { "${pg_etc_dir}/conf.d":
      ensure => 'directory',
      owner  => 'postgres',
      group  => 'postgres',
      mode   => '0750',
   }

  #Add conf.d to postgres.conf
  file_line { 'confd':
     path => "$pg_etc_dir/postgresql.conf",
     line => "include_dir = 'conf.d'",
  }

}
