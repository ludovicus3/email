#!/bin/sh

if [ -n "${UPDATE_MAPS}"]; then
  IFS=',' read -r -a maps_array <<< "${UPDATE_MAPS}"
  for map in "${maps_array[@]}"; do
    echo "hashing map $map"
    /usr/sbin/postmap $map
  done
fi

echo "updating aliases"
/usr/bin/newaliases

exec $@
