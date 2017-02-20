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
      mode                 => '0644',
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
      $nodeid = $facts['pure_cloud_nodeid']

      include pure_repmgr::ssh

      file { "${repmgr_conf}":
         ensure  => file,
         content => epp('pure_repmgr/repmgr.epp'),
         owner                => 'postgres',
         group                => 'postgres',
         mode                 => '0640',
         replace              => false,
      }

      class { 'pure_postgres::config':
      }

      if $nodeid == '1' and size($facts['pure_cloud_available_hosts']) == 0 {

         $replication_role  = pick( $facts['pure_replication_role'], 'master')

         file { "${pure_postgres::pg_etc_dir}/conf.d/wal.conf":
            ensure  => file,
            content => epp('pure_repmgr/wal.epp'),
            owner                => 'postgres',
            group                => 'postgres',
            mode                 => '0640',
            require              => [ Class['pure_postgres::config'], File["${pure_postgres::pg_etc_dir}/conf.d"] ],
            replace              => false,
         } ->

         file_line { 'wal_log_hints on':
            path   => "$pure_postgres::pg_etc_dir/conf.d/wal.conf",
            line   => 'wal_log_hints = on',
            before => Class['pure_postgres::start'],
         }

      }
      elsif size($facts['pure_cloud_available_hosts']) > 0 {
         
         $replication_role  = pick( $facts['pure_replication_role'], 'standby')

         split($facts['pure_cloud_available_hosts'],",").each | String $upstreamhost | {
            pure_repmgr::clone_standby {"clone from $upstreamhost":
               upstreamhost   => $upstreamhost,
               datadir        => $pg_data_dir,
               require        => File["${pg_etc_dir}/conf.d"],
               before         => Class['pure_postgres::start'],
            }
         }

      }
      else {
         notify { "standby in empty cluster":
            message  => "This is no initial master (ID $nodeid) and there are no running database servers yet.",
            withpath => true,
         }
      }


      split($facts['pure_cloud_nodes'],",").each | String $source | {
         pure_postgres::pg_hba {"pg_hba entry for $source":
            database        => 'repmgr,replication',
            method          => 'trust',
            state           => 'present',
            source          => "${source}/32",
            connection_type => 'host',
            user            => 'repmgr',
            before          => Class['pure_postgres::start'],
            notify          => Class['pure_postgres::reload'],
         }
      }

      class { 'pure_postgres::start':
      } ->

      class {'pure_repmgr::register':
         replication_role  => $replication_role,
      }

      if $replication_role == 'master' {
         pure_postgres::role {'repmgr':
            with_db          => true,
            password_hash    => 'repmgr',
            superuser        => true,
            #$user will be expanded by postgres and should not be expanded by puppet.
            searchpath       => [ "\"repmgr_${pure_cloud_cluster}\"", '"$user"', 'public' ],
            replication      => true,
            before           => Class['pure_repmgr::register'],
            require          => Class['pure_postgres::reload'],
         }
      }

      class { 'pure_postgres::reload':
         before  => Class['pure_repmgr::register'],
         require => Class['pure_postgres::start'],
      }


   }

}

