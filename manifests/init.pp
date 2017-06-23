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

# == Class: pure_repmgr
#
# Module for doing repmgr stuff with pure distribution.
class pure_repmgr
(
  $dnsname              = undef,
  $initial_master       = false,
  $cluster_logger       = $pure_repmgr::params::cluster_logger,
  $pg_data_dir          = $pure_postgres::params::pg_data_dir,
  $pg_xlog_dir          = $pure_postgres::params::pg_xlog_dir,
  $repmgr_password      = $pure_repmgr::params::repmgr_password,
  $replication_password = $pure_repmgr::params::replication_password,
  $buffercache          = $pure_repmgr::params::buffercache,
  $barman_server        = undef,
  $autorestart          = $pure_postgres::params::autorestart,
) inherits pure_repmgr::params
{

  $repmgr_cluster_name = regsubst($dnsname, '\..*', '')

  include pure_postgres::params

  class { 'pure_repmgr::install':
  } ->

  class { 'pure_repmgr::config':
  }

}

