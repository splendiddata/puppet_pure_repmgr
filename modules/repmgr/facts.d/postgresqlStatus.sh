#!/bin/bash
# Returns 'unknown', 'down', 'online', 'recovery', or a combination string with
# no spaces (eg. 'downrecovery').

status='unknown'

if [[ -x /etc/init.d/postgresql ]]; then
  status=$(/etc/init.d/postgresql status | grep -Eo '(down|online|recovery)' | tr -d '\n')
fi

echo "postgresql_status=${status}"