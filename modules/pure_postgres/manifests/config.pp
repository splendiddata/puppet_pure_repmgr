# == Class: pure_postgres::config
#
# Configs postgres after being installed from pure repo
class pure_postgres::config
(
) inherits pure_postgres::params
{
   # create a directory      
   file { "${pg_etc_dir}/conf.d":
      ensure => 'directory',
      owner  => 'postgres',
      group  => 'postgres',
      mode   => '0750',
   }

  #Add conf.d to postgres.conf
  file_line { 'confd':
     path => "$pg_etc_dir/postgresql.conf",
     line => "include_dir = 'conf.d'",
  }

}

