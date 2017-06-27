# Copyright (C) 2017 Collaboration of KPN and Splendid Data
#
# This file is part of puppet_pure_postgres.
#
# puppet_pure_barman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# puppet_pure_postgres is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with puppet_pure_postgres.  If not, see <http://www.gnu.org/licenses/>.

# == Class: pure_repmgr::install
#
# Installs repmgr from pure repo
class pure_repmgr::install
(
  $pg_data_dir = $pure_repmgr::pg_data_dir,
  $pg_xlog_dir = $pure_repmgr::pg_xlog_dir,
) inherits pure_repmgr
{

  package {$pure_postgres::params::pg_package_libs:
    ensure => 'installed',
    before => Package['python-psycopg2', 'repmgr'],
  }

  package { 'python-psycopg2':
    ensure => 'installed',
  }

  package { 'repmgr':
    ensure => 'installed',
  }

  #By default don't initdb. For intial master, config will include initdb class himself.
  class { 'pure_postgres':
    do_initdb   => false,
    pg_data_dir => $pg_data_dir,
    pg_xlog_dir => $pg_xlog_dir,
    pg_ssl_cn   => $pure_repmgr::dnsname,
    autorestart => $pure_repmgr::autorestart,
  }

  if $pure_repmgr::config::cluster_logger {
    include pure_repmgr::config::cluster_logger
  }

}

