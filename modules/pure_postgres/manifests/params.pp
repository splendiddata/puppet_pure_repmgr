# == Class pure_postgres::params
class pure_postgres::params
{
  $repo                 = 'http://base.splendiddata.com/postgrespure'
  $version              = '4'
  $package_name         = 'postgrespure-release'
  $package_version      = 'latest'
  $pg_version           = $version ?
  {
    '1' => '9.3',
    '2' => '9.4',
    '3' => '9.5',
    '4' => '9.6',
  }  

  $pg_etc_dir           = "/etc/pgpure/postgres/$pg_version/data"
  $pg_data_dir          = "/var/pgpure/postgres/$pg_version/data"
  $pg_bin_dir           = "/usr/pgpure/postgres/$pg_version/bin"
  $pg_log_dir           = "/var/log/pgpure/postgres"

  $do_initdb            = true
  $pg_hba_conf          = "$pg_etc_dir/pg_hba.conf"
  $pg_ident_conf        = "$pg_etc_dir/pg_ident.conf"
  $postgresql_conf      = "$pg_etc_dir/postgresql.conf"
  $pg_pid_file          = "$pg_data_dir/postmaster.pid"

  $postgres_user        = 'postgres'
  $postgres_group       = 'postgres'

}

