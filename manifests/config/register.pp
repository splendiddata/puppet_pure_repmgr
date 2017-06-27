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

# == Class: pure_repmgr::config::register
# Private class
class pure_repmgr::config::register(
)
{

  #This unless command helps to determine if register.py should be run.
  #register.py is smart enough to detect that himselve, but puppet would leave a notice line every run.
  #adding this unless command suppresses running register.py and that notice line if running isn't necessary.
  $unless    = shellquote( "${pure_postgres::params::pg_bin_dir}/psql", '-d', 'repmgr', '--quiet', '--tuples-only',
                      '-c', "select * from repmgr_${pure_repmgr::repmgr_cluster_name}.repl_nodes where name='${facts['fqdn']}'" )

  #register.py is a smart script that connects locally, finds replication config, connects to master, checks necessity
  #for registering, creates a repmgr.conf usable for registering and runs register command.
  #On next run, nodeid will be read as a fact and added to the main repmgr.conf.
  file { 'register.py':
    ensure  => 'file',
    path    => "${pure_postgres::pg_bin_dir}/repmgr_register.py",
    content => epp('pure_repmgr/register.epp'),
    owner   => $pure_postgres::postgres_user,
    group   => $pure_postgres::postgres_group,
    mode    => '0750',
  }

  -> exec { 'register':
    user    => $pure_postgres::postgres_user,
    command => "${pure_postgres::pg_bin_dir}/repmgr_register.py",
    unless  => "/bin/test $(${unless} | wc -l) -gt 1",
    onlyif  => "/bin/test -f '${pure_postgres::pg_pid_file}'",
    cwd     => $pure_postgres::pg_bin_dir,
  }

}
