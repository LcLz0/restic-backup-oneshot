#!/bin/ash
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

if [ -n "${PSQL_DATABASE}" ]; then
  echo "Found psql target. Taking psql dump"
  if [ -z "${PSQL_USER}" ]; then
    echo "PSQL_USER not set. Exiting"
    exit 2
  elif [ -z "${PSQL_PASS}" ]; then
    echo "PSQL_PASS not set. Exiting"
    exit 2
  fi
  echo "localhost:5432:${PSQL_DATABASE}:${PSQL_USER}:${PSQL_PASS}" >~/.pgpass
  chmod 0600 ~/.pgpass
  pg_dump --clean -h localhost -U "${PSQL_USER}" "${PSQL_DATABASE}" >"/backup/${PSQL_DATABASE}.dump" || (
    echo "Error in psql dump. Exiting"
    exit 2
  )
  echo "psql dump successful"
fi

env >/backup/env.file

restic backup --tag "${APP_NAME}" /backup
restic forget --tag "${APP_NAME}" --prune --keep-daily 7 --keep-weekly 4
restic check
