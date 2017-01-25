# == Class: pure_postgres::start
#
# Manages service of postgres installed from pure repo

class pure_postgres::start()
{

   $cmd = shellquote( 'bash', '-c', "for ((i=0;i<5;i++)); do echo 'select datname from pg_database' | psql -q -t > /dev/null 2>&1 && break; sleep 1; done" )

   # Do what is needed for postgresql service.
   exec { "service postgres start":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres start",
      creates => '/var/pgpure/postgres/9.6/data/postmaster.pid',
   } ->

   exec { "wait for postgres to finish starting":
      user     => $pure_postgres::postgres_user,
      command  => $cmd,
      path     => '/bin:/usr/pgpure/postgres/9.6/bin',
      loglevel => 'debug',
   }
}

