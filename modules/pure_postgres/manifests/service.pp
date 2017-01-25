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
     'started and reloaded' =>  'startreload',
     default  => '',
   }

   if $action == ''{
      fail('service_ensure parameter must be running, stopped, restarted, reloaded or started and reloaded')
   }

   # Do what is needed for postgresql service.
   class {"pure_postgres::$action":
   }

}

