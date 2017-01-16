node default {
   class { 'pure_postgres':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
      do_initdb => false,
   }

   class { 'pure_repmgr':
      primarynetwork      => '172.17.0.0/24',
      dnsname             => 'testdb.test',
   }
}
