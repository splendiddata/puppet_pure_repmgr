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

# == Definition: pure_repmgr::config::clone_standby
# Private class
define pure_repmgr::config::clone_standby(
  $upstreamhost       = undef,
  $datadir            = $pure_postgres::pg_data_dir,
)
{

  $check_cmd = shellquote( '/bin/ssh', '-o', 'NumberOfPasswordPrompts 0', $upstreamhost, 'ls' )
  $clone_cmd = shellquote( "${pure_postgres::pg_bin_dir}/repmgr_clone.py", '-f', $pure_repmgr::repmgr_conf, '-H', $upstreamhost,
                            '-D', $datadir )

  #clone.py is a smart script that connects locally, finds replication config, connects to master, checks necessity
  #for registering, registers, creates a repmgr.conf usable for cloning and runs clone command.
  #On next run, nodeid will be read as a fact and added to the main repmgr.conf.
  file { 'clone.py':
    ensure  => 'file',
    path    => "${pure_postgres::pg_bin_dir}/repmgr_clone.py",
    content => epp('pure_repmgr/clone.epp'),
    owner   => $pure_postgres::postgres_user,
    group   => $pure_postgres::postgres_group,
    mode    => '0750',
  }

  -> exec { 'clone':
    user    => $pure_postgres::postgres_user,
    command => $clone_cmd,
    unless  => "/bin/test -f '${pure_postgres::pg_pid_file}'",
    onlyif  => $check_cmd,
    cwd     => $pure_postgres::pg_bin_dir,
  }

}
