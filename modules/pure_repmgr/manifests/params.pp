# == Class pure_repmgr::params
class pure_repmgr::params
{
  $pg_etc_dir            = "/etc/pgpure/postgres/$pg_version/data"
  $pg_data_dir           = "/var/pgpure/postgres/$pg_version/data"
  $wal_keep_segments     = 100
  $max_wal_senders       = 10
  $max_replication_slots = 3
}

