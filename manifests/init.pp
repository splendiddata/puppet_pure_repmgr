# == Class: pure_repmgr
#
# Module for doing repmgr stuff with pure distribution.
class pure_repmgr
(
  $primarynetwork       = undef,
  $dnsname              = undef,
  $cluster_logger       = $pure_repmgr::params::cluster_logger,
  $pg_data_dir          = $pure_postgres::params::pg_data_dir,
  $pg_xlog_dir          = $pure_postgres::params::pg_xlog_dir,
  $repmgr_password      = $pure_repmgr::params::repmgr_password,
  $replication_password = $pure_repmgr::params::replication_password,
  $buffercache          = $pure_repmgr::params::buffercache,
  $barman_server        = undef,
  $autorestart          = $pure_postgres::params::autorestart,
) inherits pure_repmgr::params
{

  include pure_postgres::params

  class { 'pure_repmgr::install':
  } ->

  class { 'pure_repmgr::config':
  }

}

