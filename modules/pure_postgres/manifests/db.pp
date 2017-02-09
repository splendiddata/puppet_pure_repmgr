# == Define: pure_postgres::db
# Creates a postgres database
define pure_postgres::db (
  $owner   = undef,
) 
{
   pure_postgres::run_sql { "create database $name":
      sql     => "CREATE DATABASE $name;",
      unless  => "SELECT * FROM pg_database where datname = '$name';",
   }

   if $owner {
      pure_postgres::run_sql { "database $name owner $owner":
         sql      => "ALTER DATABASE $name OWNER TO $owner;",
         require => pure_postgres::run_sql["create database $name"],
      }
   }

}

