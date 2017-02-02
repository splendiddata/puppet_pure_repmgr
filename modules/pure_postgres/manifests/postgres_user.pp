# == Class: pure_postgres::postgres_user
#
# Create postgres user and groups
class pure_postgres::postgres_user
(
) inherits pure_postgres
{

   group { 'pgpure':
      ensure               => present,
   } ->

   user { $postgres_user:
      ensure               => present,
      comment              => "postgres server",
      groups               => "pgpure",
      home                 => "/home/$postgres_user",
      managehome           => true,
      shell                => '/bin/bash',
      system               => true,
   } ->

   exec { 'Generate ssh keys for postgres user':
      user    => $postgres_user,
      command => '/usr/bin/ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa',
      creates => "/home/$postgres_user/.ssh/id_rsa",
   }


} 

