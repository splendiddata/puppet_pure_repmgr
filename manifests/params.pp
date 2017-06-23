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

# == Class pure_repmgr::params
class pure_repmgr::params
{
  $repmgr_conf_dir       = '/etc'
  $repmgr_conf           = "${repmgr_conf_dir}/repmgr.conf"
  $wal_keep_segments     = 100
  $max_wal_senders       = 10
  $max_replication_slots = 4
  $cluster_logger        = true
  #You can generate a md5 password with 
  #python -c "import hashlib ; print('md5'+hashlib.md5('$MYPASSWORD$MYUSER'.encode()).hexdigest())"
  $repmgr_password       = 'md58ea99ab1ec3bd8d8a6162df6c8e1ddcd'
  $replication_password  = 'md5fea8040a27d261e5ce47cacd41b48a90'
  $buffercache           = true
}

