node default {
   class { 'pure_repmgr':
      primarynetwork      => '172.17.0.0/24',
      dnsname             => 'testdb.test',
   }
}
