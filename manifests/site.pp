class postgrespure_repo {

  package { 'http://base.splendiddata.com/postgrespure/4/centos/7/noarch/postgrespure-release-latest.rpm':
    ensure => 'installed',
  }
}

class which {

  package { 'which':
    ensure => 'installed',
  }

}

class mlocate {

  package { 'mlocate':
    ensure => 'installed',
  }

}

#repmgr module uses locate???
class { 'which': }
class { 'mlocate': }

exec { 'updatedb':                # update locate db
  command => '/usr/bin/updatedb'  # command this resource will run
}

#Below has issues (first time it installs, after that it wines that package is already installed. How idempotent is that???
#class { 'postgrespure_repo': }

