# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
) inherits pure_repmgr::params
{

   include pure_postgres
   package { 'python-psycopg2':
      ensure => 'installed',
   }

   if $facts['pure_cloud_nodeid'] {

      if $facts['pure_cloud_nodeid'] == "1" and size($facts['pure_cloud_available_hosts']) == 0 {
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
   else {
      #Also create postgres user with ssh keys in first run
      class {'pure_postgres::postgres_user':
      }
   }
}

