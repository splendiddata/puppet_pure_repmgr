# == Class: pure_repmgr::cluster_logger
#
# Installs cluster_logger for cluster aware state logging
class pure_repmgr::cluster_logger
(
) inherits pure_repmgr
{

      file { ['/usr/pgpure/cluster_logger', '/var/log/pgpure/cluster_logger' ]:
         ensure => directory,
         owner  => $pure_postgres::postgres_user,
         group  => $pure_postgres::postgres_group,
      } ->

      file {'/usr/pgpure/cluster_logger/pure_cluster_logger.py':
         path    => '/usr/pgpure/cluster_logger/pure_cluster_logger.py',
         ensure  => 'file',
         source  => 'puppet:///modules/pure_repmgr/pure_cluster_logger.py',
         owner   => $pure_postgres::postgres_user,
         group   => $pure_postgres::postgres_group,
         mode    => '0750',
      } ->

      file {'/usr/lib/systemd/system/pure_cluster_logger.service':
         path    => '/usr/lib/systemd/system/pure_cluster_logger.service',
         ensure  => 'file',
         source  => 'puppet:///modules/pure_repmgr/pure_cluster_logger.service',
         owner   => 'root',
         group   => 'root',
         mode    => '0644',
      }

}
