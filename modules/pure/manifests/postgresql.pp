# == Class: pure::postgresql
#
# Installs postgres from pure repo
class pure::postgresql
(
  $pg_version           = $pure::params::version,
) inherits pure::params
{
   $pg_package_name    = "postgres-${pg_version}"
   $pg_bin_path        = "/usr/pgpure/postgres/${pg_version}/bin"
   $pg_etc_path        = "/etc/pgpure/postgres/${pg_version}/data"
   $pg_data_path       = "/var/pgpure/postgres/${pg_version}/data"
   $pg_log_dir         = "/var/log/pgpure/postgres"

   class { 'postgresql::server':
      package_name               => $pg_package_name,
      client_package_name        => "${pg_package_name}-client",

      plperl_package_name        => pg_package_name,
      plpython_package_name      => pg_package_name,

      initdb_path                => "${pg_bin_path}/initdb",
      createdb_path              => "${pg_bin_path}/createdb",
      psql_path                  => "${pg_bin_path}/psql",
      pg_hba_conf_path           => "${pg_etc_path}/pg_hba.conf",
      pg_ident_conf_path         => "${pg_etc_path}/pg_ident.conf",
      postgresql_conf_path       => "${pg_etc_path}/postgresql.conf",
      recovery_conf_path         => "${pg_etc_path}/recovery.conf",

      service_manage             => false,

      datadir                    => $pg_data_path,
      xlogdir                    => "${pg_data_path}/pg_xlog",
      logdir                     => "${pg_log_dir}",

      user                       => 'postgres',
      group                      => 'postgres',

      needs_initdb               => false,

      manage_pg_hba_conf         => false,
      manage_pg_ident_conf       => false,
      manage_recovery_conf       => false,
  }
}
