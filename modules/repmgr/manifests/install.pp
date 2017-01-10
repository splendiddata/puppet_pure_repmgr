# == Class repmgr::install
# Private class
class repmgr::install
{
  package { $repmgr::common_package_name: ensure => $repmgr::common_package_version }
  package { $repmgr::pg_package_name: ensure => $repmgr::pg_package_version }
  package { $repmgr::additional_packages: ensure => installed }
}