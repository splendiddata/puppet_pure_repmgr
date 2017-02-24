# == Class: pure_repmgr
#
# Module for doing repmgr stuff with pure distribution.
class pure_repmgr
(
  $primarynetwork = undef,
  $dnsname        = undef,
  $cluster_logger = $pure_repmgr::params::cluster_logger,
  $pg_data_dir    = $pure_postgres::params::pg_data_dir,
  $pg_xlog_dir    = $pure_postgres::params::pg_xlog_dir,
) inherits pure_repmgr::params
{
   class { 'pure_repmgr::install':
   } ->

   class { 'pure_repmgr::config':
   }

}

