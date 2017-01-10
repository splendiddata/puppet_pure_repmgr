# == Class: pure::repo
#
# Installs purerepo from rpm on url
class pure::repo
(
  $repo              = $pure::params::repo,
  $version           = $pure::params::version,
  $package_name      = $pure::params::package_name,
  $package_version   = $pure::params::package_version
) inherits pure::params
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
