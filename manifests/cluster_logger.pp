# Copyright (C) 2017 Collaboration of KPN and Splendid Data
#
# This file is part of puppet_pure_postgres.
#
# puppet_pure_barman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# puppet_pure_postgres is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with puppet_pure_postgres.  If not, see <http://www.gnu.org/licenses/>.

# == Class: pure_repmgr::cluster_logger
#
# Installs cluster_logger for cluster aware state logging
class pure_repmgr::cluster_logger
(
  $buffercache = $pure_repmgr::buffercache,
) inherits pure_repmgr
{

  if $buffercache {
    ensure_resource('package', $pure_postgres::params::pg_package_contrib, {'ensure' => 'present'})

    pure_postgres::sql::extension{ 'pg_buffercache':
      require => Package[$pure_postgres::params::pg_package_contrib],
    }

    pure_postgres::sql::grant{ 'select on pg_buffercache to pure_cluster_logger':
      permission  => 'select',
      object      => 'pg_buffercache',
      object_type => 'table',
      role        => 'pure_cluster_logger',
      require     => [ Pure_postgres::Role['pure_cluster_logger'], Pure_postgres::Extension['pg_buffercache'] ],
    }

    pure_postgres::sql::grant{ 'execute on pg_buffercache_pages to pure_cluster_logger':
      permission  => 'execute',
      object      => 'pg_buffercache_pages()',
      object_type => 'function',
      role        => 'pure_cluster_logger',
      require     => [ Pure_postgres::Role['pure_cluster_logger'], Pure_postgres::Extension['pg_buffercache'] ],
    }
  }

  @@pure_postgres::pg_hba {"pg_hba entry for pure_cluster_logger from ${facts['networking']['ip']}":
    database        => 'postgres',
    method          => 'trust',
    state           => 'present',
    source          => "${facts['networking']['ip']}/32",
    connection_type => 'host',
    user            => 'pure_cluster_logger',
    notify          => Class['pure_postgres::reload'],
    tag             => $pure_repmgr::repmgr_cluster_name,
  }

  file {'/etc/logrotate.d/pure-cluster-logger':
    ensure => 'file',
    source => 'puppet:///modules/pure_repmgr/logrotate_cluster_logger',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { "${pure_postgres::pg_etc_dir}/cluster_logger.ini":
    ensure  => absent,
  }

  pure_postgres::sql::role {'pure_cluster_logger':
    canlogin => true,
  }

  user { 'pure_cluster_logger':
    ensure     => present,
    comment    => 'postgrespure cluster logging service',
    groups     => 'pgpure',
    home       => '/var/log/pgpure/cluster_logger',
    managehome => true,
    shell      => '/sbin/nologin',
    system     => true,
  }

  file { [ '/usr/pgpure/cluster_logger', '/var/log/pgpure/cluster_logger', '/etc/pgpure/cluster_logger' ]:
    ensure => directory,
    owner  => 'pure_cluster_logger',
    group  => 'pgpure',
  }

  file { '/etc/pgpure/cluster_logger/cluster_logger.ini':
    ensure  => file,
    content => epp('pure_repmgr/cluster_logger.epp'),
    owner   => 'pure_cluster_logger',
    group   => 'pgpure',
    mode    => '0640',
    replace =>  false,
    notify  => Service['pure_cluster_logger.service'],
  }

  file {'/usr/pgpure/cluster_logger/pure_cluster_logger.py':
    ensure  => 'file',
    path    => '/usr/pgpure/cluster_logger/pure_cluster_logger.py',
    content => epp('pure_repmgr/pure_cluster_logger.epp'),
    owner   => 'pure_cluster_logger',
    group   => 'pgpure',
    mode    => '0750',
    notify  => Service['pure_cluster_logger.service'],
  }

  file {'/var/log/pgpure/cluster_logger/cluster_logger.log':
    ensure => 'file',
    owner  => 'pure_cluster_logger',
    group  => 'pgpure',
    mode   => '0640',
  }

  if ! defined(Exec['systemctl daemon-reload']) {
    exec { 'systemctl daemon-reload':
      refreshonly => true,
      cwd         => '/',
      path        => '/bin'
    }
  }

  file {'/usr/lib/systemd/system/pure_cluster_logger.service':
    ensure => 'file',
    path   => '/usr/lib/systemd/system/pure_cluster_logger.service',
    source => 'puppet:///modules/pure_repmgr/pure_cluster_logger.service',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Exec['systemctl daemon-reload'],
  }

  -> service { 'pure_cluster_logger.service':
    ensure => 'running',
    enable => true,
  }

}
