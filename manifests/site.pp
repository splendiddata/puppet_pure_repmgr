node default {
   class { 'pure':
      repo => 'http://base.dev.splendiddata.com/postgrespure',
   }

   class { 'postgresql::server':
      package_name               => 'postgres-9.6',
      client_package_name        => 'postgres-9.6-client',

      plperl_package_name        => 'postgres-9.6',
      plpython_package_name      => 'postgres-9.6',

      initdb_path                => '/usr/pgpure/postgres/9.6/bin/initdb',
      createdb_path              => '/usr/pgpure/postgres/9.6/bin/createdb',
      psql_path                  => '/usr/pgpure/postgres/9.6/bin/psql',
      pg_hba_conf_path           => '/etc/pgpure/postgres/9.6/data/pg_hba.conf',
      pg_ident_conf_path         => '/etc/pgpure/postgres/9.6/data/pg_ident.conf',
      postgresql_conf_path       => '/etc/pgpure/postgres/9.6/data/postgresql.conf',
      recovery_conf_path         => '/etc/pgpure/postgres/9.6/data/recovery.conf',

      service_manage             => false,

      datadir                    => '/var/pgpure/postgres/9.6/data',
      xlogdir                    => '/var/pgpure/postgres/9.6/data/pg_xlog',
      logdir                     => '/var/log/pgpure/postgres/',

      user                       => 'postgres',
      group                      => 'postgres',

      needs_initdb               => false,

      manage_pg_hba_conf         => false,
      manage_pg_ident_conf       => false,
      manage_recovery_conf       => false,
  }
}
