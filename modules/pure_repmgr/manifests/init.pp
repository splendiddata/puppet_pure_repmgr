# == Class: pure_repmgr
#
# Module for doing repmgr stuff with pure distribution.
class pure_repmgr
(
) inherits pure_repmgr::params
{
   class { 'pure_repmgr::install':
   }

}

