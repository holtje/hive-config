#!/bin/sh
set -e

# Workaround. Should be fixed/fixable in Chart 8.9.0?
umask 022
if [ -d /data/ ]; then
  chmod 0600 /data/*.json
fi

exec /entrypoint.sh "$@"
