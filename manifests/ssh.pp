# == Class: pure_repmgr::ssh
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::ssh
(
) inherits pure_repmgr
{

   if $facts['pure_postgres_ssh_public_key'] {
      @@ssh_authorized_key { "postgres@$fqdn":
         ensure => present,
         type   => $facts['pure_postgres_ssh_public_key']['type'],
         key    => $facts['pure_postgres_ssh_public_key']['key'],
         tag    => $facts['pure_cloud_clusterdns'],
         user   => 'postgres',
      }
   }

   Ssh_authorized_key <<| tag == $facts['pure_cloud_clusterdns'] |>>

   @@sshkey { $facts['fqdn']:
      type => ecdsa-sha2-nistp256,
      key  => $::sshecdsakey,
      tag    => $facts['pure_cloud_clusterdns'],
   }

   @@sshkey { "${facts['fqdn']}_${facts['networking']['ip']}":
      name   => $facts['networking']['ip'],
      type   => ecdsa-sha2-nistp256,
      key    => $::sshecdsakey,
      tag    => $facts['pure_cloud_clusterdns'],
   }

   @@sshkey { "${facts['fqdn']}_${facts['hostname']}":
      name   => $facts['networking']['hostname'],
      type   => ecdsa-sha2-nistp256,
      key    => $::sshecdsakey,
      tag    => $facts['pure_cloud_clusterdns'],
   }

   Sshkey <<| tag == $facts['pure_cloud_clusterdns'] |>>

}

