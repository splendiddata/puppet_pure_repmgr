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
            pg_version => $pg_version,
            do_initdb  => true,
         }
      }
      else {
         class { 'pure_postgres::install':
            pg_version => $pg_version,
            do_initdb  => false,
         }
      }

      package { 'repmgr':
         ensure => 'installed',
      }

      file {'/usr/pgpure/splunk_logger':
         ensure => directory,
         owner  => $pure_postgres::postgres_user,
         group  => $pure_postgres::postgres_group,
      } ->

      file {'/usr/pgpure/splunk_logger/pure_splunk_logger.py':
         path    => '/usr/pgpure/splunk_logger/pure_splunk_logger.py',
         ensure  => 'file',
         source  => 'puppet:///modules/pure_repmgr/pure_splunk_logger.py',
         owner   => $pure_postgres::postgres_user,
         group   => $pure_postgres::postgres_group,
         mode    => '0750',
      } ->

      file {'/usr/lib/systemd/system/pure_splunk_logger.service':
         path    => '/usr/lib/systemd/system/pure_splunk_logger.service',
         ensure  => 'file',
         source  => 'puppet:///modules/pure_repmgr/pure_splunk_logger.service',
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
      }

   }
   else {
      #Also create postgres user with ssh keys in first run
      class {'pure_postgres::postgres_user':
      }
   }

}

