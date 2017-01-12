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
   class { 'pure::repo':
      repo              => $repo,
      version           => $version,
      package_name      => $package_name,
      package_version   => $package_version
   }
   class { 'pure::postgresql':
      pg_version        => $pure::params::pg_version
   }

}

