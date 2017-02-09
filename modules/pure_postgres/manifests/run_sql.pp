# == Deinition: pure_postgres::run_sql
define pure_postgres::run_sql (
  $sql,
  $unless = undef,
) {

   assert_private("run_sql is for internal pure_postgres purposes only")

#   $run_sql    = shellquote("$sql")
   $run_cmd    = shellquote("${pure_postgres::pg_bin_dir}/psql", "-c", $sql)
   if $unless {
      $unless_sql = shellquote( "$unless" )
      $unless_cmd = "/bin/test $(${pure_postgres::pg_bin_dir}/psql --quiet --tuples-only -c $unless_sql | wc -l) -gt 1"
   }  else {
      $unless_cmd = undef
   }

   exec { "psql $sql":
      user     => $pure_postgres::postgres_user,
      command  => $run_cmd,
      unless   => $unless_cmd,
      onlyif   => "/bin/test -f ${pure_postgres::pg_data_dir}/PG_VERSION",
      cwd      => $pure_postgres::pg_data_dir,
   }

}
