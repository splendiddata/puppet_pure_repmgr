# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
) inherits pure_repmgr::params
{
   class { 'pure_postgres':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
      do_initdb => false,
   }
   package { 'repmgr':
      ensure => 'installed',
   }
}

