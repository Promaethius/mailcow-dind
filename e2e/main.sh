#!/bin/bash

set -e

#Adapted from https://stackoverflow.com/a/246128
export SH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export DIR=$HOME

. $SH_DIR/util/*.sh
. $SH_DIR/test/*.sh

until docker run -e HOSTNAME='example.com' -e CRON_BACKUP='* * * * * *' -e TIMEZONE='PDT' -v $DIR/dind:/var/lib/docker -v $DIR/mailcow:/mailcow -v $DIR/mailcow-backup:/mailcow-backup -v /lib/modules:/lib/modules:ro --name mailcow-dind --privileged --net=host -d mailcow-dind
do
  PROGRESS=0
  block "Starting Tests"
  if [ -z $(http_test) ]; let "PROGRESS++"; fi
  if [ -z $(https_test) ]; let "PROGRESS++"; fi
  if [ -z $(pop_test) ]; let "PROGRESS++"; fi
  if [ -z $(smtp_test) ]; let "PROGRESS++"; fi
  if [ -z $(imap_test) ]; let "PROGRESS++"; fi
  if [ -z $(app_test) ]; let "PROGRESS++"; fi
  if [ $PROGRESS == 6 ]; then docker stop mailcow-dind && block "Testing Complete" && exit 0; fi
  error "Testing Failed. Re-attempting in 30 seconds."
  sleep 30s
done

error "The Mailcow Container exited for an unknown reason."
exit 1
