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
      tag    => $pure_repmgr::dnsname,
      user   => 'postgres',
    }
  }

  Ssh_authorized_key <<| tag == $pure_repmgr::dnsname |>>

  class { 'pure_postgres::ssh':
    tags => [ $pure_repmgr::dnsname, $pure_repmgr::barman_server ],
  }

}

