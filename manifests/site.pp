node default {
   class { 'pure_postgres':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
      do_initdb => false,
   }

}
