# == Class: pure_repmgr::ssh
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::ssh
(
)
{

  if $facts['pure_postgres_ssh_public_key_key'] {
    @@ssh_authorized_key { "postgres@${::fqdn}":
      ensure => present,
      type   => $facts['pure_postgres_ssh_public_key_type'],
      key    => $facts['pure_postgres_ssh_public_key_key'],
      tag    => $facts['pure_cloud_clusterdns'],
      user   => 'postgres',
    }
  }

  Ssh_authorized_key <<| tag == $facts['pure_cloud_clusterdns'] |>>

  class { 'pure_postgres::ssh':
    tags => [ $facts['pure_cloud_clusterdns'], "barman:${pure_repmgr::barman_server}" ],
  }

}

