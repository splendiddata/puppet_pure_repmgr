# == Class pure::install
# Private class
class pure::install
{
  package { $pure::common_package_name: ensure => $pure::common_package_version }
  package { $pure::pg_package_name: ensure => $pure::pg_package_version }
  package { $pure::additional_packages: ensure => installed }
}
