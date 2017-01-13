# == Class: pure_postgres::repo
#
# Installs pure repo
class pure_postgres::repo
(
  $repo              = $pure_postgres::params::repo,
  $version           = $pure_postgres::params::version,
  $package_name      = $pure_postgres::params::package_name,
  $package_version   = $pure_postgres::params::package_version
) inherits pure_postgres::params
{
  $dist              = $::operatingsystem ?
  {
    'Centos' => 'centos'
  }
  $dist_version      = $facts['os']['release']['major']

  $repo_url       = "${repo}/${version}/${dist}/${dist_version}/"

  yumrepo { "PostgresPURE":
      baseurl => "${repo_url}",
      descr => "Postgres PURE",
      enabled => 1,
      gpgcheck => 0
    }

}

