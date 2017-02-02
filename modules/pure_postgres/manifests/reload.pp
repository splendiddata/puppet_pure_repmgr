# == Class: pure_postgres::reload
#
# Manages service of postgres installed from pure repo

class pure_postgres::reload()
{
   # Do what is needed for postgresql service.
   exec { "service postgres reload":
      user    => $pure_postgres::postgres_user,
      command => "/etc/init.d/postgres reload",
      loglevel => 'debug',
      onlyif   => "/bin/test -f $pg_pid_file"
   }
}

