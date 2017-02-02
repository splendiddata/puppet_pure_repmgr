# == Class: pure_postgres::config
#
# Configs postgres after being installed from pure repo
class pure_postgres::config
(
) inherits pure_postgres 
{
   # create a directory      
   file { "${pg_etc_dir}/conf.d":
      ensure   => 'directory',
      owner    => $postgres_user,
      group    => $postgres_group,
      mode     => '0750',
      require  => Package["postgresql-server"],
   }

   #Add conf.d to postgres.conf
   file_line { 'confd':
      path => "$pg_etc_dir/postgresql.conf",
      line => "include_dir = 'conf.d'",
      require  => Package["postgresql-server"],
   } ->

   file { "$pg_bin_dir/modify_pg_hba.py":
      ensure  => 'present',
      owner   => $postgres_user,
      group   => $postgres_group,
      mode    => '0750',
      source  => 'puppet:///modules/pure_postgres/pg_hba.py',
   }

   class { "pure_postgres::postgresql_server":
   }
}

