# == Class: pure_postgres::service
#
# Manages service of postgres installed from pure repo
class pure_postgres::service
(
) inherits pure_postgres
{
      if ! ($service_ensure in [ 'running', 'stopped', 'restarted', 'reloaded']) {
        fail('service_ensure parameter must be running, stopped, restarted or reloaded')
      }

      if $service_manage == true {
         # Restart postgresql service.
         exec { 'restart_postgresql':
            user    => $repmgr::postgresql_user,
            command => '/etc/init.d/postgresql restart',
            before  => Exec['register_primary'],
         }


        service { 'ntp':
          ensure     => $service_ensure,
          enable     => $service_enable,
          name       => $service_name,
          hasstatus  => true,
          hasrestart => true,
        }
      }
}

