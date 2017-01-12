#!/bin/bash
# Returns 'unknown', 'down', 'online', 'recovery', or a combination string with
# no spaces (eg. 'downrecovery').

if [[ -x /etc/init.d/postgresql ]]; then
  status=$(/etc/init.d/postgresql status 2>/dev/null | grep -Eo '(down|online|recovery)' | tr -d '\n')
elif [[ -x /etc/init.d/postgres ]]; then
  status=$(/etc/init.d/postgres status 2>/dev/null | grep -Eo '(down|online|recovery)' | tr -d '\n')
fi

[[ "$status" ]] || status=unknown

echo "postgresql_status=${status}"
