# == Class: pure_postgres::service
#
# Manages service of postgres installed from pure repo

class pure_postgres::service_start()
{

   $cmd = shellquote( 'bash', '-c', "for ((i=0;i<5;i++)); do echo 'select datname from pg_database' | psql -q -t > /dev/null 2>&1 && break; sleep 1; done" )

   # Do what is needed for postgresql service.
   exec { "service postgres start":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres start",
      loglevel => 'debug',
   } ->

   exec { "wait for postgres to finish starting":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      path     => '/bin:/usr/pgpure/postgres/9.6/bin',
      loglevel => 'debug',
   }
}

class pure_postgres::service_stop()
{
   # Do what is needed for postgresql service.
   exec { "service postgres stop":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres stop",
      loglevel => 'debug',
   }
}

class pure_postgres::service_reload()
{
   # Do what is needed for postgresql service.
   exec { "service postgres reload":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres reload",
      loglevel => 'debug',
   }
}

class pure_postgres::service_restart()
{
   pure_postgres::service_start {'postgres service_restart start':
   } ->

   pure_postgres::service_stop {'postgres service_restart stop':
   }
}

class pure_postgres::service_startreload()
{
   pure_postgres::service_start {'postgres service_startreload start':
   } ->

   pure_postgres::service_reload {'postgres service_startreload reload':
   }
}



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
   class {"pure_postgres::service_$action":
   }

}

