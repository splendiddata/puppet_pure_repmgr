# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
) inherits pure_repmgr::params
{

   include pure_postgres
   class { 'pure_postgres::repo':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
   }

   package { 'python-psycopg2':
      ensure => 'installed',
   }

   if $facts['pure_cloud_nodeid'] {

      if $facts['pure_cloud_nodeid'] == "1" {
         class { 'pure_postgres::install':
            pg_version => '9.6',
            do_initdb  => true,
         }
      }
      else {
         class { 'pure_postgres::install':
            pg_version => '9.6',
            do_initdb  => false,
         }
      }

      package { 'repmgr':
         ensure => 'installed',
      }

   }
}

