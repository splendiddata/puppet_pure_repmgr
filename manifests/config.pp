# == Class: pure_repmgr::config
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::config
(
  $repmgr_password = $pure_repmgr::repmgr_password,
) inherits pure_repmgr
{

  file { "${pure_postgres::pg_bin_dir}/pure_repmgr_releasenotes.txt":
    ensure  => 'file',
    source => 'puppet:///modules/pure_repmgr/releasenotes.txt',
    owner   => $pure_postgres::postgres_user,
    group   => $pure_postgres::postgres_group,
    mode    => '0750',
  }

  if ! defined(File['/etc/facter/facts.d']) {
    file { [  '/etc/facter', '/etc/facter/facts.d' ]:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  file { '/etc/facter/facts.d/pure_cloud_cluster.ini':
    ensure  => absent,
  }

  file { '/etc/facter/facts.d/pure_cloud_cluster.py':
    ensure  => absent,
  }

  #create facts script to add postgres ssh keys to facts
  file { '/etc/facter/facts.d/pure_repmgr_facts.py':
    ensure  => file,
    content => epp('pure_repmgr/pure_repmgr_facts.epp'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/facter/facts.d'],
  }

  Pure_postgres::Pg_hba <<| tag == $pure_repmgr::repmgr_cluster_name |>>

  if $facts['pure_cloud_nodeid'] {
    $nodeid = $facts['pure_cloud_nodeid']
  } else {
    $nodeid = '100'
  }

  include pure_repmgr::ssh

  file { $pure_repmgr::params::repmgr_conf:
    ensure  => file,
    content => epp('pure_repmgr/repmgr.epp'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
  }

  include pure_postgres::config
  include pure_postgres::service

  if $pure_repmgr::initial_master {

    include pure_postgres::initdb

    $replication_role  = 'master'

  }

  file { "${pure_postgres::pg_etc_dir}/conf.d/wal.conf":
    ensure  => file,
    content => epp('pure_repmgr/wal.epp'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
    replace => true,
  }

  file_line { 'wal_log_hints on':
    path   => "${pure_postgres::pg_etc_dir}/conf.d/wal.conf",
    line   => 'wal_log_hints = on',
    notify => Class['pure_postgres::restart'],
  }

  Class['pure_postgres::config'] -> File["${pure_postgres::pg_etc_dir}/conf.d/wal.conf"]
  File["${pure_postgres::pg_etc_dir}/conf.d"] -> File["${pure_postgres::pg_etc_dir}/conf.d/wal.conf"]
  File["${pure_postgres::pg_etc_dir}/conf.d/wal.conf"] -> File_line['wal_log_hints on']
  File["${pure_postgres::pg_etc_dir}/conf.d/wal.conf"] -> Class['pure_postgres::start']

  @@pure_postgres::pg_hba {"pg_hba entry for repmgr from ${facts['networking']['ip']}":
    database        => 'repmgr',
    method          => 'trust',
    state           => 'present',
    source          => "${facts['networking']['ip']}/32",
    connection_type => 'host',
    user            => 'repmgr',
    notify          => Class['pure_postgres::reload'],
    tag             => $pure_repmgr::repmgr_cluster_name,
  }

  if $facts['pure_replication_role'] == 'master' {
    @@pure_repmgr::clone_standby {"clone from ${facts['networking']['ip']}":
      upstreamhost => $facts['networking']['ip'],
      datadir      => $pure_postgres::pg_data_dir,
      require      => File["${pure_postgres::pg_etc_dir}/conf.d"],
      tag          => $pure_repmgr::repmgr_cluster_name,
    }

    Pure_repmgr::Clone_standby["clone from ${facts['networking']['ip']}"] ~> Class['pure_postgres::start']
  } else {
    Pure_repmgr::Clone_standby <<| tag == $pure_repmgr::repmgr_cluster_name |>>
  }

  pure_postgres::role {'repmgr':
    with_db       => true,
    password_hash => $repmgr_password,
    superuser     => true,
    #workaround, since repmgr can currently not handle switchover with other user for replication
    replication   => true,
    #$user will be expanded by postgres and should not be expanded by puppet.
    searchpath    => [ "\"repmgr_${pure_repmgr::repmgr_cluster_name}\"", '"$user"', 'public' ],
    before        => Class['pure_repmgr::register'],
    require       => Class['pure_postgres::reload'],
  }

  pure_postgres::role {'replication':
    password_hash => $pure_repmgr::replication_password,
    replication   => true,
    canlogin      => true,
  }

  @@pure_postgres::pg_hba {"pg_hba entry for replication from ${facts['networking']['ip']}":
    database        => 'replication',
    method          => 'trust',
    state           => 'present',
    source          => "${facts['networking']['ip']}/32",
    connection_type => 'host',
    #workaround, since repmgr can currently not handle switchover with other user for replication
    user            => 'replication,repmgr',
    notify          => Class['pure_postgres::reload'],
    tag             => $pure_repmgr::repmgr_cluster_name,
  }

  class {'pure_repmgr::register':
    require          => Pure_postgres::Started['postgres started'],
  }

  if $pure_repmgr::barman_server {
    class {'pure_barman::client':
      barman_server => $pure_repmgr::barman_server,
    }
  }

}

