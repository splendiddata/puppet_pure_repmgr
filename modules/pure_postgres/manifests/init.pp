# == Class: pure_postgres
#
# Module for doing postgres stuff with pure distribution.
class pure_postgres
(
  $repo              = $pure_postgres::params::repo,
  $version           = $pure_postgres::params::version,
  $package_name      = $pure_postgres::params::package_name,
  $package_version   = $pure_postgres::params::package_version,
  $do_initdb         = $pure_postgres::params::do_initdb,
) inherits pure_postgres::params
{
}

