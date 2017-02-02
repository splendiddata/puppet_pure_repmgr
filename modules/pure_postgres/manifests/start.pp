# == Class: pure_postgres::start
#
# Manages service of postgres installed from pure repo

class pure_postgres::start
(
) inherits pure_postgres
{

   $cmd = shellquote( 'bash', '-c', "for ((i=0;i<5;i++)); do echo 'select datname from pg_database' | psql -q -t > /dev/null 2>&1 && break; sleep 1; done" )

   # Do what is needed for postgresql service.
   exec { "service postgres start":
      user    => $postgres_user,
      command => "/etc/init.d/postgres start",
      creates => "$pg_pid_file",
      onlyif  => "test -f $pg_data_dir/PG_VERSION",
      path     => '$pg_bin_dir:/usr/local/bin:/bin',
   } ->

   exec { "wait for postgres to finish starting":
      user     => $postgres_user,
      command  => $cmd,
      path     => '$pg_bin_dir:/usr/local/bin:/bin',
      loglevel => 'debug',
   }
}

