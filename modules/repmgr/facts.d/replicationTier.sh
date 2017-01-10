#!/bin/bash
# Returns 'primary', 'secondary', 'unknown', or 'notier'.

if [[ -z "$(which repmgr)" ]] || [[ ! -x '/etc/init.d/postgresql' ]]; then
  echo 'replication_tier=unknown'
  exit 0
fi

repmgrConfFile=$(locate repmgr.conf | grep -v sample) \
|| { echo "Can't find repmgr conf file. Exiting."; exit 1; }

tier=$(sudo repmgr -f ${repmgrConfFile} cluster show | grep $(hostname) | grep -Eo '(master|standby)')
f_tier='notier'

if [[ "$tier" = "master" ]]; then
  f_tier='primary'
elif [[ "$tier" = "standby" ]]; then
  f_tier='secondary'
fi

echo "replication_tier=${f_tier}"