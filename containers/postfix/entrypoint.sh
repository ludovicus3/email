#!/bin/bash

shopt -s nullglob

for map in /etc/postfix/maps.d/*; do
  echo "hashing map $map"
  /usr/sbin/postmap $map
done

echo "updating aliases"
/usr/bin/newaliases

exec $@
