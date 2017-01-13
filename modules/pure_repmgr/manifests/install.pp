# == Class: pure_repmgr::install
#
# Installs postgres from pure repo in a bare format (without running initdb on /var/pgpure/postgres/9.6/data)
class pure_repmgr::install
(
) inherits pure_repmgr::params
{
   package { 'repmgr':
      ensure => 'installed',
   }
}

