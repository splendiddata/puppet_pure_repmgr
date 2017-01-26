# == Class: pure_postgres::postgres_user
#
# Installs postgres from pure repo in a bare format (without running initdb on /var/pgpure/postgres/9.6/data)
class pure_postgres::postgres_user
(
) inherits pure_postgres
{

   group { 'pgpure':
      ensure               => present,
   } ->

   user { 'postgres':
      ensure               => present,
      comment              => "postgres server",
      groups               => "pgpure",
      home                 => "/home/postgres",
      managehome           => true,
      shell                => '/bin/bash',
      system               => true,
   } ->

   exec { 'Generate ssh keys for postgres user':
      user    => 'postgres',
      command => '/usr/bin/ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa',
      creates => '/home/postgres/.ssh/id_rsa',
   }


} 

