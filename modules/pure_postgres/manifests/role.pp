# == Define: pure_postgres::role
#
# Creates a postgres role
define pure_postgres::role
(
  $with_db       = false,
  $password_hash = undef,
  $superuser     = false,
  $searchpath    = undef,
  $replication   = false,
) 
{

   if $password_hash {
      $pwsql = "password '$password_hash' LOGIN"
   } else {
      $pwsql = ''
   }

   if $with_db {
      pure_postgres::db { $name:
      }
   }

   pure_postgres::run_sql { "create role $name":
      sql     => "CREATE ROLE $name $pwsql;",
      unless  => "SELECT * FROM pg_roles where rolname = '$name'",
   }

   if $with_db {
      pure_postgres::run_sql { "database $name owner $owner":
         sql      => "ALTER DATABASE $name OWNER TO $name;",
         unless   => "SELECT * FROM pg_database where datname = '$name' and datdba in (select oid from pg_roles where rolname = '$name');",
         require  => [ Pure_postgres::Db[$name], Pure_postgres::Run_sql["create role $name"] ],
      }
   }

   if $superuser {
      pure_postgres::run_sql { "role $name with superuser":
         sql     => "ALTER ROLE $name SUPERUSER;",
         unless  => "SELECT * FROM pg_roles where rolname = '$name' and rolsuper;",
      }      
   }

   if $replication {
      pure_postgres::run_sql { "role $name with replication":
         sql => "ALTER ROLE $name REPLICATION;",
         unless  => "SELECT * FROM pg_roles where rolname = '$name' and rolreplication;",
      }
   }

   if $searchpath {
      $sql_searchpath = join($searchpath, ',')
      pure_postgres::run_sql { "searchpath $name":
         sql => "ALTER ROLE $name SET search_path TO $sql_searchpath;",
      }
   }

}
