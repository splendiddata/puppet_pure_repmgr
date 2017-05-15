# == Class pure_repmgr::params
class pure_repmgr::params
{
  $repmgr_conf_dir       = '/etc'
  $repmgr_conf           = "${repmgr_conf_dir}/repmgr.conf"
  $wal_keep_segments     = 100
  $max_wal_senders       = 10
  $max_replication_slots = 4
  $cluster_logger        = true
  #You can generate a md5 password with 
  #python -c "import hashlib ; print('md5'+hashlib.md5('$MYPASSWORD$MYUSER'.encode()).hexdigest())"
  $repmgr_password       = 'md58ea99ab1ec3bd8d8a6162df6c8e1ddcd'
  $replication_password  = 'md5fea8040a27d261e5ce47cacd41b48a90'
  $buffercache           = true
}

