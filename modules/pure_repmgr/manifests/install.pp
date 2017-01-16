# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
) inherits pure_repmgr::params
{

   if $facts['pure_cloud_nodeid'] {
      if $facts['pure_cloud_nodeid'] == "1" {
         $do_initdb = true
      }
      else {
         $do_initdb = false
      }
      
      class { 'pure_postgres':
         repo => 'http://base.dev.splendiddata.com/postgrespure',
         do_initdb => $do_initdb,
      }

      package { 'repmgr':
         ensure => 'installed',
      }
   }
}

