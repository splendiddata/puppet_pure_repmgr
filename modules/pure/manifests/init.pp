# == Class: pure
#
# Installs purerepo from rpm on url
class pure
(
  $repo              = 'http://base.splendiddata.com/postgrespure'
  $version           = '4'
  $package_name      = 'postgrespure-release'
  $package_version   = 'latest'
)
{
  $dist              = $::operatingsystem ?
  {
    'Centos' => [ 'centos' ]
  }
  $dist_version      = $::osreleasemajor
  $package_url       = "${repo}/${version}/${dist}/${dist_version}/noarch/${package_name}-${package_version}.rpm"

  # Ensure packages are installed / up to date.
  class { 'pure::package_url':
  }
  contain 'pure::package_url'
}
