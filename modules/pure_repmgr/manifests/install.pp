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
   } ->

   package { 'python-psycopg2':
      ensure => 'installed',
   }

   if $facts['pure_cloud_nodeid'] {

      if $facts['pure_cloud_nodeid'] == "1" and size($facts['pure_cloud_available_hosts']) == 0 {
         class { 'pure_postgres::install':
            pg_version => '9.6',
            do_initdb  => true,
            require   => Class['pure_postgres::repo'],
         }
      }
      else {
         class { 'pure_postgres::install':
            pg_version => '9.6',
            do_initdb  => false,
            require   => Class['pure_postgres::repo'],
         }
      }

      package { 'repmgr':
         ensure => 'installed',
         require   => Class['pure_postgres::repo'],
      }

   }
}

