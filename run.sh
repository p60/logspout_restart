#!/bin/sh
set -e

last_logbytes=0

while true
do

  # Sum up size of all log files
  logbytes=`ls -s /var/lib/docker/containers/*/*.log | awk '{sum+=$1;} END {print sum;}'`

  if [ $logbytes -lt $last_logbytes ]; then

    # Size has been reduced since last poll; Restart logspout

    # We are assuming that the logspout service is named LOGSPOUT.
    service_url=${SAURON_PRODUCTION_LOGSTASH_ENV_DOCKERCLOUD_SERVICE_API_URL}

    echo "Restarting Logspout..."
    curl -sS -X POST -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${service_url}stop/
    sleep 5
    curl -sS -X POST -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${service_url}start/
    echo ""

  fi

  last_logbytes=$logbytes

  sleep 10

done
