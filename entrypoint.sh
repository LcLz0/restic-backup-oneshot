#!/bin/bash
set -e

if [ "$#" -ge 1 ]; then
  exec $1
  exit 0
fi

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo "AWS_ACCESS_KEY_ID not set. Exiting"
  exit 1
elif [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "AWS_SECRET_ACCESS_KEY not set. Exiting"
  exit 1
elif [ -z "${RESTIC_REPOSITORY}" ]; then
  echo "RESTIC_REPOSITORY not set. Exiting"
  exit 1
elif [ -z "${RESTIC_PASSWORD}" ]; then
  echo "RESTIC_PASSWORD not set. Exiting"
  exit 1
elif [ -z "${APP_NAME}" ]; then
  echo "APP_NAME not set. Set to application name. Exiting"
  exit 1
fi

if [ -n "${PSQL_HOST}" ]; then
  echo "Found psql target. Taking psql dump"
  /usr/local/bin/psql_dump.sh || (
    echo "Error in psql dump. Exiting"
    exit 2
  )
fi

restic backup --tag "${APP_NAME}" /backup
restic forget --tag "${APP_NAME}" --prune --keep-daily 7 --keep-weekly 4
restic check
