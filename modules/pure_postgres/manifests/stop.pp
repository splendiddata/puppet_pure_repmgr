# == Class: pure_postgres::stop
#
# Manages service of postgres installed from pure repo

class pure_postgres::stop()
{
   # Do what is needed for postgresql service.
   exec { "service postgres stop":
      user     => $pure_postgres::postgres_user,
      command  => "/etc/init.d/postgres stop",
      onlyif   => "/bin/test -f $pg_pid_file"
   }
}

