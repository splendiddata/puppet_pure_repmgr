# == Class repmgr::params
class repmgr::params
{
  $common_package_name    = 'repmgr-common'
  $common_package_version = 'latest'
  $pg_package_name        = 'postgresql-9.3-repmgr'
  $pg_package_version     = 'latest'

  $additional_packages = $::operatingsystem ?
  {
    'Ubuntu' => [ 'postgresql-server-dev-9.3' ]
  }

  # Unless specified otherwise, assume we're a cluster of one.
  $cluster_name = 'my_cluster'
  $primary      = $::hostname
  $node_number  = 1

  $node_name       = $::hostname
  $node_priority   = 100
  $repmgr_conf_dir = '/usr/lib/postgresql/repmgr'
  $repmgr_log_dir  = '/var/log/repmgr'

  $postgresql_group = $::operatingsystem ?
  {
    'Ubuntu' => 'postgres'
  }

  $postgresql_user = $::operatingsystem ?
  {
    'Ubuntu' => 'postgres'
  }

  $postgresql_version  = '9.3'
  $postgresql_home     = '/var/lib/postgresql'
  $repmgr_db_name      = 'repmgr_db'
  $repmgr_db_user_name = 'repmgr_usr'
}