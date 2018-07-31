#!/bin/bash

set -ex

telnet() {
  return $(telnet localhost "$1")
}

difference() {
  return $(sdiff -B -b -s <("$1") <("$2") | wc)
}

cert() {
  CERT_REMOTE=$(openssl s_client -showcerts -servername example.org -connect localhost:$1 2>/dev/null | openssl x509 -inform pem -noout -text)
  CERT_LOCAL=$(openssl x509 -inform pem -noout -text -in /home/travis/mailcow/data/assets/ssl/cert.pem)
  return $(difference "$CERT_REMOTE" "$CERT_LOCAL")
}

port() {
  echo "Testing port $1."
  return $(nc -zv 127.0.0.1 "$1")
}

response(){
  if [ -n $(echo $1 | grep "https") ]; then
    echo "Testing status code of https://127.0.0.1${2}"
    return $(curl -s -k -o /dev/null -w "%{http_code}" "https://127.0.0.1${2}")
  else
    echo "Testing status code of http://127.0.0.1${2}"
    return $(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1${2}")
  fi
}

body() {
  return $(difference "$(curl -sbk $1)" "$(curl -sb $2)")
}

app_test() {
  #Test reponse body
  #Init database by making a request to index.php
  #Use API to create two domains and one user for each.
  #Have those two users mail each other through telnet.
}

imap_test() {
  if [ -z $(port "143 993") ]; then return 1; fi
  if [ $(cert "993") > 0 ]; then return 1; fi
  #Test TELNET response
}

smtp_test() {
  if [ -z $(port "25 465") ]; then return 1; fi
  if [ $(cert "465") > 0 ]; then return 1; fi
  #Test TELNET response
}

pop_test() {
  if [ -z $(port "110  995") ]; then return 1; fi
  if [ $(cert "995") > 0 ]; then return 1; fi
  #Test TELNET response
}

https_test() {
  if [ -z $(port "443") ]; then return 1; fi
  if [ $(cert "443") > 0 ]; then return 1; fi
}

http_test() {
  if [ -z $(port "80") ]; then return 1; fi
  if [ $(response) != "301" ]; then return 1; fi
}

until docker run -e HOSTNAME='example.com' -e CRON_BACKUP='* * * * * *' -e TIMEZONE='PDT' -v /home/travis/dind:/var/lib/docker -v /home/travis/mailcow:/mailcow -v /home/travis/mailcow-backup:/mailcow-backup --name mailcow-dind --privileged --net=host -d mailcow-dind
do
  PROGRESS=0
  if [ -z $(http_test) ]; let "PROGRESS++"; fi
  if [ -z $(https_test) ]; let "PROGRESS++"; fi
  if [ -z $(pop_test) ]; let "PROGRESS++"; fi
  if [ -z $(smtp_test) ]; let "PROGRESS++"; fi
  if [ -z $(imap_test) ]; let "PROGRESS++"; fi
  if [ -z $(app_test) ]; let "PROGRESS++"; fi
  if [ $PROGRESS == 6 ]; then docker stop mailcow-dind && exit 0; fi
  sleep 30s
done

exit 1
