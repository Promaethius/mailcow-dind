#!/bin/sh

CRON_REGEX='/^([0-59]|\*) ([0-23]|\*) ([1-31]|\*) ([1-12]|\*) ([0-6]|\*) ([1900-3000]|\*)$/'
# Adapted from https://stackoverflow.com/a/106223
HOSTNAME_REGEX='/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/'
# Adapted from https://stackoverflow.com/a/14880044
IPS_REGEX='/((25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)(,\n|,?$))/'
KEY_REGEX='/^[a-zA-Z0-9]*/'

# Makes things so much easier to debug. Logs actually stick around.
delay_exit() {
  sleep 10s
  exit 1
}

regex_check() {
  if [ -z $(echo "$1" | awk "$2") ]; then
    echo "Incorrect format for $1"
    delay_exit
  fi
}

init_check() {
  if [ -z "$HOSTNAME" ]; then
    echo "Add HOSTNAME env var for mailcow."
    delay_exit
  else
    regex_check "$HOSTNAME" "$HOSTNAME_REGEX"
  fi
  if [ -z "$TIMEZONE" ]; then
    echo "Add TIMEZONE env var for mailcow."
    delay_exit
  fi
}

api_check() {
  if [ -z "$API_IPS" ]; then
    echo "A comma separated list of IPs must be declared as API clients in API_IPS"
    delay_exit
  else
    regex_check "$API_IPS" "$IPS_REGEX"
    regex_check "$API_KEY" "$KEY_REGEX"
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
  if [ ! -d /lib/modules ]; then
    echo "This container requires a current /lib/modules to be mounted from the host i.e. -v /lib/modules:/lib/modules:ro"
    delay_exit
  fi
}

cron_check() {
  if [ -z "$CRON_BACKUP" ]; then
    echo "CRON_BACKUP must be set in cron format for consistent backups."
    delay_exit
  else
    regex_check "$CRON_BACKUP" "$CRON_REGEX"
  fi
  if [ -z "$CRON_UPDATE" ]; then
    echo "CRON_UPDATE is not set. This requires manual updates."
  else
    regex_check "$CRON_UPDATE" "$CRON_REGEX"
  fi
}

init_cron() {
  cron_check
  echo "$CRON_BACKUP root BACKUP_LOCATION=/mailcow-backup /mailcow/helper-scripts/backup_and_restore.sh backup all" | crontab -
  if [ -n "$CRON_UPDATE" ]; then
    echo "$CRON_UPDATE root cd /mailcow && echo 'y' | ./update.sh" | crontab -
  fi
}

init_api() {
  if [ -z "$API_KEY" ]; then
    echo "API is disabled."
  else
    api_check
    sed -i '/API_KEY=/c\API_KEY='"$API_KEY" /mailcow/mailcow.conf
    sed -i '/API_ALLOW_FROM=/c\API_ALLOW_FROM='"$API_IPS" /mailcow/mailcow.conf
  fi
}

init_volumes() {
  local VOLUMES=$(yq r /mailcow/docker-compose.yml 'volumes.' | sed 's/: null*//')
  for x in $VOLUMES; do
    if [ -z $(echo "$x" | grep "socket") ]; then
      yq d -i /mailcow/docker-compose.yml "volumes.$x"
      sed -i "s/$x/\/mnt\/$x/g" /mailcow/docker-compose.yml
      if [ -d "/mnt/$x" ]; then
        echo "Drive $x moved to mounted /mnt/$x"
      else
        mkdir /mnt/$x
        echo "Drive $x is moved to /mnt/$x"
      fi
    else
      echo "Skipping $x since it's a unix socket mount."
    fi
  done
}

init_mailcow() {
  init_check
  git clone https://github.com/mailcow/mailcow-dockerized.git /mailcow
  cd /mailcow
  MAILCOW_HOSTNAME=$HOSTNAME MAILCOW_TZ=$TIMEZONE . /mailcow/generate_config.sh
  if [ "$MAILCOW_SKIPENCRYPT" == "true" ]; then
    sed -i 's/SKIP_LETS_ENCRYPT=n/SKIP_LETS_ENCRYPT=y/g' /mailcow/mailcow.conf
    yq d -i /mailcow/docker-compose.yml services.acme-mailcow
    echo "Removing ACME. This will create STARTTLS problems if you don't have your own certificates mounted at /mailcow/data/assets/ssl in the forms cert.pem and key.pem"
  fi
  sed -i 's/SYSCTL_IPV6_DISABLED=0/SYSCTL_IPV6_DISABLED=1/g' /mailcow/mailcow.conf
  yq d -i /mailcow/docker-compose.yml services.*.sysctls
  yq d -i /mailcow/docker-compose.yml services.ipv6nat
  yq d -i /mailcow/docker-compose.yml networks.mailcow-network.enable_ipv6
  docker-compose pull
  init_api
  init_volumes
}

start_mailcow() {
  cd /mailcow
  docker-compose up -d
  docker-compose logs -f
}

priv_check
init_cron

if [ ! -d "/mnt" ]; then
  mkdir /mnt
fi

if [ -f /mailcow/mailcow.conf ]; then
  echo "Mailcow configuration exists probably from another installation. Attempting startup."
  start_mailcow  
else
  init_mailcow
  start_mailcow
fi
