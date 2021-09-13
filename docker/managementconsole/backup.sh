#!/usr/bin/env bash

printUsage() {
  echo "Usage:"
  echo
  echo "backup.sh [options]"
  echo
  echo "Options:"
  echo " -u, --username <username>      The username to use, when calling the Management Console"
  echo " -p, --password <password>      The password to use, when calling the Management Console"
  echo " -h, --host <hostname>          The hostname for the Management Console (default: localhost)"
  echo " -i, --projectId <projectId>    For backing up (only) a specific project"
  echo " -c, --configurationOnly Id>    Back-up only the configuration and no project data"
  echo " -n, --postfix <postfix>        Set the postfix for the created backup file (default: datetime)"
  echo
}

OPTS=`getopt -o u:p:h:i:cn --long username:,password:,host:,projectId:,configurationOnly,postFix,help -n 'backup.sh' -- "$@"`

eval set -- "$OPTS"

HOST="localhost"
QUERYSTRING=""
USERNAME=""
PASSWORD=""
TIMESTAMP=$(date +"%Y%m%d%H%M")

while true; do
  case "$1" in
    -u | --username ) USERNAME=$2; shift; shift ;;
    -p | --password ) PASSWORD=$2; shift; shift ;;
    -h | --host     ) HOST=$2; shift; shift ;;
    -i | --projectId) QUERYSTRING = "projectId=$2"; shift; shift ;;
    -c | --configurationOnly) QUERYSTRING = "includeProjects=false"; shift ;;
    -n | --postfix) TIMESTAMP=$2; shift; shift ;;
    --help) printUsage; exit 1 ;;
    -- ) shift; break ;;
    *) echo "Unknown option: $1"; printUsage; exit 1;
  esac
done

if [ "x" == "x$USERNAME" ]; then
  echo "Error, a username must be set"
  echo
  printUsage
  exit 1
fi

if [ "x" == "x$PASSWORD" ]; then
  echo "Error, a password must be set"
  echo
  printUsage
  exit 1
fi

echo "starting backup..."

curl -s -u ${USERNAME}:${PASSWORD} -X GET "http://${HOST}:8080/secure/Backup?${QUERYSTRING}" --output /kapow/backup/backup-${TIMESTAMP}.zip 1>/dev/null 2>&1

rc=$?; if [[ $rc != 0 ]]; then
  echo "backup failed with code: ${rc}"
  exit 1
fi

echo "backup complete:"

ls -l /kapow/backup/backup-${TIMESTAMP}.zip