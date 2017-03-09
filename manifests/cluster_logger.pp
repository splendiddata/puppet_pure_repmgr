# == Class: pure_repmgr::cluster_logger
#
# Installs cluster_logger for cluster aware state logging
class pure_repmgr::cluster_logger
(
) inherits pure_repmgr
{

  split($facts['pure_cloud_nodes'],",").each | String $source | {
    pure_postgres::pg_hba {"pg_hba entry for pure_cluster_logger from $source":
      database        => 'postgres',
      method          => 'trust',
      state           => 'present',
      source          => "${source}/32",
      connection_type => 'host',
      user            => 'pure_cluster_logger',
      notify          => Class['pure_postgres::reload'],
    }
  }

  pure_postgres::role {'pure_cluster_logger':
    canlogin => true,
  } ->

  user { 'pure_cluster_logger':
    ensure     => present,
    comment    => 'postgrespure cluster logging service',
    groups     => 'pgpure',
    home       => '/var/log/pgpure/cluster_logger',
    managehome => true,
    shell      => '/sbin/nologin',
    system     => true,
  } ->

  file { [ '/usr/pgpure/cluster_logger', '/var/log/pgpure/cluster_logger' ]:
    ensure => directory,
    owner  => 'pure_cluster_logger',
    group  => 'pgpure',
  } ->

  file { "${pure_postgres::pg_etc_dir}/cluster_logger.ini":
    ensure  => file,
    content => epp('pure_repmgr/cluster_logger.epp'),
    owner   => 'pure_cluster_logger',
    group   => 'pgpure',
    mode    => '0640',
    replace =>  false,
    notify  => Service['pure_cluster_logger.service'],
  } ->

  file {'/usr/pgpure/cluster_logger/pure_cluster_logger.py':
    path    => '/usr/pgpure/cluster_logger/pure_cluster_logger.py',
    ensure  => 'file',
    content => epp('pure_repmgr/pure_cluster_logger.epp'),
    owner   => 'pure_cluster_logger',
    group   => 'pgpure',
    mode    => '0750',
    notify  => Service['pure_cluster_logger.service'],
  } ->

  file {'/var/log/pgpure/cluster_logger/cluster_logger.log':
    ensure  => 'file',
    owner   => 'pure_cluster_logger',
    group   => 'pgpure',
    mode    => '0640',
  } ->

  file {'/usr/lib/systemd/system/pure_cluster_logger.service':
    path   => '/usr/lib/systemd/system/pure_cluster_logger.service',
    ensure => 'file',
    source => 'puppet:///modules/pure_repmgr/pure_cluster_logger.service',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Exec['systemctl daemon-reload'],
  } ->

  service { 'pure_cluster_logger.service':
    ensure => 'running',
    enable => true,
  }

  if ! defined(Exec['systemctl daemon-reload']) {
    exec { 'systemctl daemon-reload':
      refreshonly => true,
      cwd         => '/',
      path        => '/bin'
    }
  }

}
