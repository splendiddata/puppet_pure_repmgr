# == Class: pure_postgres::restart
#
# Manages service of postgres installed from pure repo

class pure_postgres::restart()
{
   class {'pure_postgres::stop':
   } ->

   class ('pure_postgres::start':
   }
}

