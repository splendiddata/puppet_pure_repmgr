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
      file { "${repmgr_conf}":
         ensure  => file,
         content => epp('pure_repmgr/repmgr.epp'),
         owner                => 'postgres',
         group                => 'postgres',
         mode                 => '0640',
         replace              => false,
      }

      if $facts['pure_cloud_nodeid'] == '1' and size($facts['pure_cloud_available_hosts']) == 0 {

         $facts['pure_cloud_nodes'].each | String $source | {
            pure_postgres::pg_hba {"pg_hba entry for $source":   
               database        => 'repmgr,replication',
               method          => 'trust',
               state           => 'present',
               source          => "${source}/32",
               connection_type => 'host',
               user            => 'repmgr',
            }
         }

         class { 'pure_postgres::config':
         } ->

         file { "${pure_postgres::pg_etc_dir}/conf.d/wal.conf":
            ensure  => file,
            content => epp('pure_repmgr/wal.epp'),
            owner                => 'postgres',
            group                => 'postgres',
            mode                 => '0640',
            require              => File["${pure_postgres::pg_etc_dir}/conf.d"],
            replace              => false,
         } ->

         file_line { 'wal_log_hints on':
            path => "$pure_postgres::pg_etc_dir/conf.d/wal.conf",
            line => 'wal_log_hints = on',
         } ->

         class { 'pure_postgres::service':
            service_ensure => 'running',
         } ->

         postgresql::server::role{ 'repmgr':
            password_hash    => 'repmgr',
            superuser        => true,
            username         => 'repmgr',
         } ->

         postgresql::server::db { 'repmgr':
            user     => 'repmgr',
            password => postgresql_password('repmgr', 'repmgr'),
            dbname   => 'repmgr',
            owner    => 'repmgr',
         } ->

         postgresql_psql { "ALTER ROLE repmgr SET search_path TO \"repmgr_${pure_cloud_cluster}\", \"\$user\", public;":
            command     => "ALTER ROLE repmgr SET search_path TO \"repmgr_${pure_cloud_cluster}\", \"\\\$user\", public;",
            require     => Class['Postgresql::Server'],
         } ->

         class {'pure_repmgr::register_primary':
         }
      }
      else {
         # create a directory
         file { "${pg_etc_dir}/conf.d":
            ensure   => 'directory',
            owner    => 'postgres',
            group    => 'postgres',
            mode     => '0750',
            require  => Package["postgresql-server"],
         } ->

         class { "pure_postgres::postgresql_server":
         }


         #I am not the first node, or there al already running postgres instances in this cluster
         $facts['pure_cloud_available_hosts'].each | String $upstreamhost | {
            pure_repmgr::clone_standby {"clone from $upstreamhost":
               upstreamhost   => $upstreamhost,
               datadir        => $pg_data_dir,
               require        => Class['pure_postgres::postgresql_server'],
               before         => Class['pure_postgres::service'],
            }
         }

         class { 'pure_postgres::service':
            service_ensure => 'running',
         } ->

         class {'pure_repmgr::register_standby':
         }

      }
   }
}

