# == Class: pure_repmgr
#
# Module for doing repmgr stuff with pure distribution.
class pure_repmgr
(
  $primarynetwork          = undef,
  $dnsname                 = undef,

) inherits pure_repmgr::params
{
   class { 'pure_repmgr::install':
   }

   class { 'pure_repmgr::config':
      primarynetwork      => $primarynetwork,
      dnsname             => $dnsname,
   }

}

