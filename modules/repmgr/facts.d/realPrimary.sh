#!/bin/bash

# Returns the hostname of the *current* primary node of the node facter is being
# run on. The value will be a hostname or 'iamtheprimary' if facter is being run
# on the current primary. The result is derived from the live repmgr database,
# NOT the puppet/hiera configuration.

# This fact is called by the perform_failover.sh script, and supplies the info
# required for the fencing/STONITH mechanism.

cd /tmp \
|| { echo 'Unable to cd to /tmp. Exiting.'; exit 0; }

locate_cmd=$(which locate 2>/dev/null) \
|| { echo 'locate command not available. Exiting.'; exit 0; }

repmgrConfFile=$($locate_cmd repmgr.conf | grep -v sample)
[[ -n $repmgrConfFile ]] \
|| { echo 'Cannot find repmgr.conf. Exiting.'; exit 0; }

clusterName=$(grep 'cluster=' $repmgrConfFile | sed 's/^.*=//')
[[ -n $clusterName ]] \
|| { echo 'Cannot determine cluster name. Exiting.' exit 0; }

if [[ -x '/etc/init.d/postgresql' ]]; then
  postgresStatus=$(service postgresql status | grep -Eo '(down|online)')
  [[ -n $postgresStatus ]] || { echo 'Cannot determine postgresql status. Exiting.'; exit 0; }
else
  echo 'postgresql init script not available so assuming postgresql not installed. Exiting.'
  exit 0
fi

if [[ $postgresStatus == 'online' ]]; then
  repmgrDbExistCheck=$(sudo -u postgres psql -c 'select datname from pg_database where datistemplate = false' | grep -o repmgr)
  if [[ -z $repmgrDbExistCheck ]]; then
    echo 'There appears to be no repmgr database on this node. Cannot complete on this occasion. Exiting.'
    exit 0
  fi
elif [[ $postgresStatus == 'down' ]]; then
  echo 'PostgreSQL is not running on this node. Cannot complete on this occasion. Exiting.'
  exit 0
fi

initId=$(sudo -u postgres psql -c "select * from repmgr_${clusterName}.repl_nodes" repmgr | grep $(hostname) | awk '{print $5}') \
|| { echo 'Failed to retrieve upstream node ID. Exiting.'; exit 0; }

if [[ $initId == '|' ]]; then
  finId='0'
else
  finId=$initId
fi

initHostname=$(sudo -u postgres psql -c "select * from repmgr_${clusterName}.repl_nodes" repmgr | grep -E "^  ${finId}" | awk '{print $8$9}' | sed 's/|//') \
|| { echo 'Failed to retrieve upstream hostname. Exiting.'; exit 0; }

if [[ -z $initHostname ]]; then
  finHostname='iamtheprimary'
else
  finHostname=$initHostname
fi

echo "real_primary=${finHostname}"
