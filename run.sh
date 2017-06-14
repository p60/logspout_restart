#!/bin/sh
set -e

last_logbytes=0

while true
do

  # Sum up size of all log files
  logbytes=`ls -s /var/lib/docker/containers/*/*.log | awk '{sum+=$1;} END {print sum;}'`

  if [ $logbytes -lt $last_logbytes ]; then

    # Size has been reduced since last poll; Restart logspout
    container_url=${SAURON_PRODUCTION_LOGSPOUT_ENV_DOCKERCLOUD_CONTAINER_API_URL}

    echo "Restarting Logspout..."
    echo "Hitting endpoint ${container_url}"

    curl -sS -X POST -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${container_url}stop/
    sleep 10
    curl -sS -X POST -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${container_url}start/
    echo ""

  fi

  last_logbytes=$logbytes

  sleep 10

done
