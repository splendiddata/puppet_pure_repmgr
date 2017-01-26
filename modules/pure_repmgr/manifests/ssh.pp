# == Class: pure_repmgr::ssh
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::ssh
(
) inherits pure_repmgr
{

   @@ssh_authorized_key { "postgres@$fqdn":
      ensure => present,
      type   => $facts['pure_postgres_ssh_public_key']['type'],
      key    => $facts['pure_postgres_ssh_public_key']['key'],
      tag    => $facts['pure_cloud_clusterdns'],
      user   => 'postgres',
   }

   Ssh_authorized_key <<| tag == $facts['pure_cloud_clusterdns'] |>>

   @@sshkey { $::hostname:
      type => ecdsa-sha2-nistp256,
      key  => $::sshecdsakey,
      tag    => $facts['pure_cloud_clusterdns'],
   }

   Sshkey <<| tag == $facts['pure_cloud_clusterdns'] |>>

}

