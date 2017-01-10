# == Class: pure::postgresql
#
# Installs postgres from pure repo
class pure::postgresql
(
  $pg_version           = $pure::params::version,
) inherits pure::params
{
   $pg_package_name     = "postgres-${pg_version}"

   package { $pg_package_name:
      ensure => 'installed',
   }

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
