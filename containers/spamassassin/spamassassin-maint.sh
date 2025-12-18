#!/bin/sh

sa-update
result=$?
case $result in
  0)
    sa-compile
    exit $?
    ;;
  1)
    echo "No updates available"
    exit 0
    ;;
  2)
    spamassassin -- --debug --lint 2>&1
    exit 1
    ;;
  *)
    echo "sa-update failed for unknown reasons" 1>&2
    exit $result
    ;;
esac
