# == Class pure_repmgr::params
class pure_repmgr::params
{
  $repmgr_conf_dir       = '/etc'
  $repmgr_conf           = "${repmgr_conf_dir}/repmgr.conf"
  $wal_keep_segments     = 100
  $max_wal_senders       = 10
  $max_replication_slots = 3
  $cluster_logger        = true
  $repmgr_password       = 'repmgr'
}

