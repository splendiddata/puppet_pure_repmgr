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

  #The logic behind the block below is that for every cluster one node should be initial master
  #If this node starts running, puppet will check the number of active standbys that are already active.
  #If no node was active, puppet assumes this is an initializing cluster and will run initdb on this specific node only.
  #This logic breaks:
  #- When more than one node has the parameter $pure_repmgr::initial_master initial master set puppet is started at the same time.
  #  In that case puppet will initialize the second node, before puppetdb knows that the first was already initialized 
  #  and you have two masters in one cluster.
  #- When puppetdb lags and doesn't have the correct facts yet, and this node has an empty datafolder
  #  I can only think of a poorly executed migraton of all puppet nodes to a new puppet cluster,
  #  with incorrect data path and all agents starting at exactly the same time.
  #  To prevent that situation from happening you can unset pure_repmgr::initial_master 
  #  when the initial master is properly initialized since it only has use in a initializing cluster.

  if $pure_repmgr::initial_master {
    #This is set for every node that should initdb (should be only one per cluster)
    #If set, read puppet db for number of nodes that are active in this cluster
    $active_nodes_query = ["from", "resources", [ "and", [ "=", "title", "Pure_repmgr" ], [ "=", [ "parameter", "dnsname" ], $pure_repmgr::dnsname ], [ "~", ["fact", "pure_replication_role"], "(master|standby)" ] ] ]
    $active_nodes = puppetdb_query($active_nodes_query)

    if size($active_nodes) == 0 {
      #There is no node active in this cluster, so this should be an empty cluster. Let initdb do its thing.
      #Also note that initdb will only init an empty datadir.
      include pure_postgres::initdb
    }
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

