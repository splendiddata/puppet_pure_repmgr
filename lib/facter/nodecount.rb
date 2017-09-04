# Copyright (C) 2017 Collaboration of KPN and Splendid Data
#
# This file is part of puppet_pure_postgres.
#
# puppet_pure_postgres is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with puppet_pure_postgres.  If not, see <http://www.gnu.org/licenses/>.

require 'facter'

Facter.add("pure_postgres_node_count") do
  confine do
    File.exist? '/etc/pgpure/postgres'
  end
  setcode do
      repmgrout = Facter::Util::Resolution.exec('su -l postgres -c "repmgr cluster show|grep -c \"host=\""')
      repmgrout == "" ? 0 : repmgrout
  end
end
