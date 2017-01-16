# == Class: pure_repmgr::config
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::config
(
  $primarynetwork          = undef,
  $dnsname                 = undef,
) inherits pure_repmgr::params
{
   file { [  '/etc/facter', '/etc/facter/facts.d' ]:
      ensure               => 'directory',
      owner                => 'root',
      group                => 'root',
      mode                 => '0755',
   }

   file { '/etc/facter/facts.d/pure_cloud_cluster.ini':
      ensure  => file,
      content => epp('pure_repmgr/pure_cloud_cluster.epp', {'primarynetwork' => $primarynetwork, 'dnsname' => $dnsname}),
      owner                => 'root',
      group                => 'root',
      mode                 => '0750',
      require              => File['/etc/facter/facts.d']
   }

   file { 'pure_cloud_cluster.py':
      path                 => '/etc/facter/facts.d/pure_cloud_cluster.py',
      ensure               => 'file',
      source               => 'puppet:///modules/pure_repmgr/pure_cloud_cluster.py',
      owner                => 'root',
      group                => 'root',
      mode                 => '0750',
      require              => File['/etc/facter/facts.d/pure_cloud_cluster.ini']
   }


}

