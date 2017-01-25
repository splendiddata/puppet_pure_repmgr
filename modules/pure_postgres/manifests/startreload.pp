# == Class: pure_postgres::startreload
#
# Manages service of postgres installed from pure repo

class pure_postgres::startreload()
{
   class {'pure_postgres::start':
   } ->

   class {'pure_postgres::reload':
   }
}
