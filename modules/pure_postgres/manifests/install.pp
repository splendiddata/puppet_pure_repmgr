# == Class: pure_postgres::install
#
# Installs postgres from pure repo in a bare format (without running initdb on /var/pgpure/postgres/9.6/data)
class pure_postgres::install
(
  $pg_version           = $pure_postgres::params::version,
  $do_initdb            = $pure_postgres::params::do_initdb,
) inherits pure_postgres::params
{
   $pg_package_name     = "postgres-${pg_version}"

   if !$do_initdb {
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

   }

   package { $pg_package_name:
      ensure => 'installed',
   }

}

