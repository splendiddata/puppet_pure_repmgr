# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
) inherits pure_repmgr::params
{
   package { 'repmgr':
      ensure => 'installed',
   }
}

