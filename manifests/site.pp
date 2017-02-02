node puppet {
   class { 'puppetdb':
   }

   class { 'puppetdb::master::config':
   }
}

node default {
   class { 'pure_postgres::repo':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
   } ->
   class { 'pure_repmgr':
      primarynetwork      => '172.17.0.0/24',
      dnsname             => 'testdb.test',
   }
}
