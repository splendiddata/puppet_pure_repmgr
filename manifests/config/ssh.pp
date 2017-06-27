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

# == Class: pure_repmgr::config::ssh
#
# Configure a replicated cluster with repmgr from pure repo 
class pure_repmgr::config::ssh
(
)
{

  if $facts['pure_postgres_ssh_public_key_key'] {
    @@ssh_authorized_key { "postgres@${::fqdn}":
      ensure => present,
      type   => $facts['pure_postgres_ssh_public_key_type'],
      key    => $facts['pure_postgres_ssh_public_key_key'],
      tag    => $pure_repmgr::dnsname,
      user   => 'postgres',
    }
  }

  Ssh_authorized_key <<| tag == $pure_repmgr::dnsname |>>

  class { 'pure_postgres::config::ssh':
    tags => [ $pure_repmgr::dnsname, $pure_repmgr::barman_server ],
  }

}

