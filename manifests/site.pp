node default {
   #include pure_repo_old
   include pure
}

class pure_repo_old{
   yumrepo { "PostgresPURE":
      baseurl => "http://base.splendiddata.com/postgrespure/4/$operatingsystemrelease/$architecture",
      descr => "Postgres PURE",
      enabled => 1,
      gpgcheck => 0
   }
}

