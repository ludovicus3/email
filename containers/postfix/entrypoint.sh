#!/bin/bash

shopt -s nullglob

for override in /etc/postfix/overrides.d/*.cf; do
  echo "applying overrides from $override"
  /usr/sbin/postconf -e $(cat $override)
done

for map in /etc/postfix/maps.d/*; do
  echo "hashing map $map"
  /usr/sbin/postmap $map
done

echo "updating aliases"
/usr/bin/newaliases

exec $@
