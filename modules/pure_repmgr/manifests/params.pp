# == Class pure_repmgr::params
class pure_repmgr::params
{
  $pg_etc_dir           = "/etc/pgpure/postgres/$pg_version/data"
  $pg_data_dir          = "/var/pgpure/postgres/$pg_version/data"
  $do_initdb            = true
}

