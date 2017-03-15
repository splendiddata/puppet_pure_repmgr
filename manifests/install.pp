# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
  $pg_data_dir = $pure_repmgr::pg_data_dir,
  $pg_xlog_dir = $pure_repmgr::pg_xlog_dir,
) inherits pure_repmgr
{

  package {$pure_postgres::params::pg_package_libs:
    ensure => 'installed',
    before => Package['python-psycopg2', 'repmgr'],
  }

  package { 'python-psycopg2':
    ensure => 'installed',
  }

  package { 'repmgr':
    ensure => 'installed',
  }

  if $facts['pure_cloud_nodeid'] {

    #By default don't initdb. For intial master, config will include initdb class himself.
    class { 'pure_postgres':
      do_initdb   => false,
      pg_data_dir => $pg_data_dir,
      pg_xlog_dir => $pg_xlog_dir,
      pg_ssl_cn   => $pure_repmgr::dnsname,
    }

    if $cluster_logger {
      include pure_repmgr::cluster_logger
    }
  }
  else {
    include pure_postgres::postgres_user
  }

}

