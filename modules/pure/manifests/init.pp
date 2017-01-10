# == Class: pure
#
# Installs purerepo from rpm on url
class pure
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
# $dist_version      = $::osreleasemajor

#  $package_url       = "${repo}/${version}/${dist}/${dist_version}/noarch/${package_name}-${package_version}.rpm"
  $repo_url       = "${repo}/${version}/${dist}/${dist_version}/"
#  $repo_url       = "http://base.splendiddata.com/postgrespure/4/centos/7/"
#  $repo_url       = "http://base.splendiddata.com/postgrespure/${version}/${dist}/${dist_version}/"

  yumrepo { "PostgresPURE":
      baseurl => "${repo_url}",
      descr => "Postgres PURE",
      enabled => 1,
      gpgcheck => 0
    }

}
