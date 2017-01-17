# == Class: pure_repmgr::config
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::config
(
) inherits pure_repmgr
{
   file { [  '/etc/facter', '/etc/facter/facts.d' ]:
      ensure               => 'directory',
      owner                => 'root',
      group                => 'root',
      mode                 => '0755',
   }

   file { '/etc/facter/facts.d/pure_cloud_cluster.ini':
      ensure  => file,
      content => epp('pure_repmgr/pure_cloud_cluster.epp'),
      owner                => 'root',
      group                => 'root',
      mode                 => '0640',
      require              => File['/etc/facter/facts.d'],
      replace              =>  false,
   }

   file { 'pure_cloud_cluster.py':
      path                 => '/etc/facter/facts.d/pure_cloud_cluster.py',
      ensure               => 'file',
      source               => 'puppet:///modules/pure_repmgr/pure_cloud_cluster.py',
      owner                => 'root',
      group                => 'root',
      mode                 => '0750',
      require              => File['/etc/facter/facts.d/pure_cloud_cluster.ini'],
   }

   if $facts['pure_cloud_nodeid'] {
      file { '/etc/repmgr.conf':
         ensure  => file,
         content => epp('pure_repmgr/repmgr.epp'),
         owner                => 'postgres',
         group                => 'postgres',
         mode                 => '0640',
         replace              => false,
      }

      file { "${pure_postgres::pg_etc_dir}/conf.d/wal.conf":
         ensure  => file,
         content => epp('pure_repmgr/wal.epp'),
         owner                => 'postgres',
         group                => 'postgres',
         mode                 => '0640',
         require              => File["${pure_postgres::pg_etc_dir}/conf.d"],
         replace              => false,
      }

      file_line { 'wal_log_hints on':
         path => "$pure_postgres::pg_etc_dir/conf.d/wal.conf",  
         line => 'wal_log_hints = on',
      }

      class { 'pure_postgres::pg_hba':   
         database        => 'repmgr',
         method          => 'trust',
         netmask         => '255.255.255.255',
         state           => 'present',
         sources         => $facts['pure_cloud_nodes'],
         connection_type => 'host',
         user            => 'repmgr',
      }

   }
}

