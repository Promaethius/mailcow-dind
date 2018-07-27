#!/bin/sh

# Adapted from https://stackoverflow.com/questions/14203122/create-a-regular-expression-for-cron-statement#comment62684417_17858524
CRON_REGEX='/^(\*|((\*\/)?[1-5]?[0-9])) (\*|((\*\/)?[1-5]?[0-9])) (\*|((\*\/)?(1?[0-9]|2[0-3]))) (\*|((\*\/)?([1-9]|[12][0-9]|3[0-1]))) (\*|((\*\/)?([1-9]|1[0-2]))) (\*|((\*\/)?[0-6]))$/'
# Adapted from https://stackoverflow.com/a/106223
HOSTNAME_REGEX='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'

# Makes things so much easier to debug. Logs actually stick around.
delay_exit() {
  sleep 1m
  exit 1
}

init_check() {
  if [ ! -z $HOSTNAME ]; then
    echo "Add HOSTNAME env var for mailcow."
    delay_exit
  else
    if [[ ! "$HOSTNAME" =~ "$HOSTNAME_REGEX" ]]; then
      echo "Incorrect format for HOSTNAME."
      delay_exit
    fi
  if [ ! -z $MAILCOW_TZ ]; then
    echo "Add MAILCOW_TZ env var for mailcow."
    delay_exit
  fi
  if [ ! -z $MAILCOW_SKIPENCRYPT ]; then
    echo "Removing ACME. This will create STARTTLS problems if you don't have your own certificates mounted at /mailcow/data/assets/ssl in the forms cert.pem and key.pem"
  fi
}

priv_check() {
  ip link add dummy0 type dummy >/dev/null
  if [ $? -eq 0 ]; then
    ip link delete dummy0 >/dev/null
  else
    echo "This container must be privileged."
    delay_exit
  fi
}

cron_check() {
  if [ ! -z $CRON_BACKUP ]; then
    echo "CRON_BACKUP must be set in cron format for consistent backups."
    delay_exit
  else
    if [ ! "CRON_BACKUP" =~ "$CRON_REGEX" ]
      echo "Incorrect Cron expression for CRON_BACKUP."
      delay_exit
    fi
  fi
  if [ ! -z $CRON_UPDATE ]; then
    echo "CRON_UPDATE is not set. This requires manual updates."
  else
    if [ ! "CRON_UPDATE" =~ "$CRON_REGEX" ]
      echo "Incorrect Cron expression for CRON_UPDATE."
      delay_exit
    fi
  fi
}

init_cron() {
  cron_check
  echo "$CRON_BACKUP root BACKUP_LOCATION=/mailcow-backup /mailcow/helper-scripts/backup_and_restore.sh backup all" | crontab -
  if [ -z $CRON_UPDATE ]; then
    echo "CRON_UPDATE is not currently supported. Look for this in future versions."
  fi
}  

init_mailcow() {
  init_check
  git clone https://github.com/mailcow/mailcow-dockerized.git /mailcow
  cd /mailcow
  /bin/sh /mailcow/generate_config.sh
  if [ -z $MAILCOW_SKIPENCRYPT ]; then
    sed -i 's/SKIP_LETS_ENCRYPT=n/SKIP_LETS_ENCRYPT=y/g' /mailcow/mailcow.conf
  fi
  sed -i 's/SKIP_IP_CHECK=n/SKIP_LETS_ENCRYPT=y/g' /mailcow/mailcow.conf
  sed -i 's/SYSCTL_IPV6_DISABLED=0/SYSCTL_IPV6_DISABLED=1/g' /mailcow/mailcow.conf
}

start_mailcow() {
  cd /mailcow
  docker-compose up
}

start_stack() {
  crond &
  start_mailcow
}

priv_check
init_cron

if [ -z /mailcow/mailcow.conf ]; then
  echo "Mailcow configuration exists probably from another installation. Attempting startup."
  start_stack  
else
  init_mailcow
  start_stack
fi
  
