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
  $do_initdb            = true
}

