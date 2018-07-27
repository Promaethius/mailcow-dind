#!/bin/sh

# Makes things so much easier to debug. Logs actually stick around.
delay_exit() {
  sleep 1m
  exit 1
}

init_check() {
  if [ ! -z $HOSTNAME ]; then
    echo "Add HOSTNAME env var for mailcow."
    delay_exit
  fi
  if [ ! -z $MAILCOW_TZ ]; then
    echo "Add MAILCOW_TZ env var for mailcow."
    delay_exit
  fi
}

priv_check() {
  ip link add dummy0 type dummy >/dev/null
  if [[ $? -eq 0 ]]; then
      ip link delete dummy0 >/dev/null
      return 0
  else
      return 1
  fi
}

init_mailcow() {
  init_check
  git clone https://github.com/mailcow/mailcow-dockerized.git /mailcow
  cd /mailcow
  /bin/sh /mailcow/generate_config.sh
}

start_mailcow() {
  cd /mailcow
  docker-compose up
}

if [ ! $(priv_check) ]; then
  echo "This container must be privileged."
  delay_exit
fi

if [ -z /mailcow/mailcow.conf ]; then
  echo "Mailcow configuration exists probably from another installation. Attempting startup."
  start_mailcow  
else
  init_mailcow
  start_mailcow
fi
  
