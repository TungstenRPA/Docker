#!/usr/bin/env bash

printUsage() {
  echo "Usage:"
  echo
  echo "restore.sh [options]"
  echo
  echo "Options:"
  echo " -u, --username <username>      The username to use, when calling the Management Console"
  echo " -p, --password <password>      The password to use, when calling the Management Console"
  echo " -h, --host <host>              The host name for the Management Console (default: localhost)"
  echo " -f, --filename <filename>      The name of the backup file to restore"
  echo " -a, --path <path>              The path to the backup file to restore (default: /kapow/backup/)"
  echo " -m, --mode <mode>              The mode for restore. Reset or Merge (default: Reset)"
  echo
}

OPTS=`getopt -o u:p:f:a:h:m: --long username:,password:,filename:,path:,host:,mode:,help -n 'restore.sh' -- "$@"`

eval set -- "$OPTS"

HOST="localhost"
USERNAME=""
PASSWORD=""
FILENAME=""
FILEPATH="/kapow/backup/"
RESTOREMODE="Reset"

while true; do
  case "$1" in
    -u | --username ) USERNAME=$2; shift; shift ;;
    -p | --password ) PASSWORD=$2; shift; shift ;;
    -h | --host     ) HOST=$2; shift; shift ;;
    -f | --filename ) FILENAME=$2; shift; shift ;;
    -a | --path     ) FILEPATH=$2; shift; shift ;;
    -m | --mode     ) RESTOREMODE=$2; shift; shift ;;
    --help) printUsage; exit 1 ;;
    -- ) shift; break ;;
    *) echo "Unknown option: $1"; printUsage; exit 1;
  esac
done

if [ "x" == "x$FILENAME" ]; then
  echo "Error, a filename must be set"
  echo
  printUsage
  exit 1
fi


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

waitForManagementConsole() {
    for i in `seq 1 $TIMEOUT` ; do
      HTTP_RESPONSE_CODE=`curl -s -o /dev/null -I "http://${HOST}:8080/Ping" -w "%{http_code}"`;
      if [ "$HTTP_RESPONSE_CODE" == "200" ] ; then break; fi;
        echo "Waiting for Management Console to become ready"
      sleep 5;
    done
}

echo "restoring backup from ${FILEPATH}${FILENAME}"

restoreFromBackup() {
  curl -u ${USERNAME}:${PASSWORD} -F fileField=@${FILEPATH}${FILENAME} -F restoreMode=${RESTOREMODE} -X POST "http://${HOST}:8080/secure/Restore" 1>/dev/null 2>&1
  rc=$?; if [[ $rc != 0 ]]; then
    echo "restore failed with code: ${rc}"
    exit 1
  fi
}

waitForManagementConsole
restoreFromBackup

echo "restoring backup complete."