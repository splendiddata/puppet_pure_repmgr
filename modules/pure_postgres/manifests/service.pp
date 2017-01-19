# == Class: pure_postgres::service
#
# Manages service of postgres installed from pure repo
class pure_postgres::service
(
   $service_ensure  = undef,
) inherits pure_postgres
{

   $action  = $service_ensure ? {
     'running'   => 'start',
     'stopped'   => 'stop',
     'restarted' => 'restart',
     'reloaded' =>  'reload',
     'started and reloaded' =>  'reload',
     default  => '',
   }

   if $action == ''{
      fail('service_ensure parameter must be running, stopped, restarted, reloaded or started and reloaded')
   }

   if $service_ensure == 'started and reloaded' {
      # Restart postgresql service.
      exec { "service postgres start":
         user    => $pure_postgres::postgres_user,
         command => "/etc/init.d/postgres $action",
         before  => "service postgres $action",
         loglevel => 'debug',
      }
   }

   # Restart postgresql service.
   exec { "service postgres $action":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres $action",
      loglevel => 'debug',
   }
}

