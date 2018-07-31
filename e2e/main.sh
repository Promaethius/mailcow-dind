#!/bin/bash

set -ex

export DIR=$HOME

error() {
  echo -e "\e[31m${1}"
}

msg() {
  echo -e "\e[32m${1}"
}

block() {
  echo -e "\e[34m${1}"
}

telnet() {
  return $(telnet localhost "$1")
}

difference() {
  return $(sdiff -B -b -s <("$1") <("$2") | wc)
}

cert() {
  CERT_REMOTE=$(openssl s_client -showcerts -servername example.com -connect 127.0.0.1:$1 2>/dev/null | openssl x509 -inform pem -noout -text)
  CERT_LOCAL=$(openssl x509 -inform pem -noout -text -in $DIR/mailcow/data/assets/ssl/cert.pem)
  return $(difference "$CERT_REMOTE" "$CERT_LOCAL")
}

port() {
  echo "Testing port $1."
  return $(nc -zv 127.0.0.1 "$1")
}

response(){
  if [ -n $(echo $1 | grep "https") ]; then
    echo "Testing status code of https://127.0.0.1${2}"
    return $(curl -s -H "Host: example.com" -k -o /dev/null -w "%{http_code}" "https://127.0.0.1${2}")
  else
    echo "Testing status code of http://127.0.0.1${2}"
    return $(curl -s -H "Host: example.com" -o /dev/null -w "%{http_code}" "http://127.0.0.1${2}")
  fi
}

body() {
  return $(difference "$(curl -sbk $1)" "$(curl -sb $2)")
}

app_test() {
  block "Starting APP Test block."
  local X=1
  local Y=4
  msg "Testing APP::Body $X/$Y"
  #Test reponse body
  let "X++"
  msg "Testing APP::Init $X/$Y"
  #Init database by making a request to index.php
  let "X++"
  msg "Testing APP::Domain $X/$Y"
  #Use API to create two domains.
  let "X++"
  msg "Testing APP::User $X/$Y"
  #Create one user per domain.
  let "X++"
  msg "Testing APP::Mail $X/$Y"
  #Have those to users mail each other.
  block "Finished APP Test block."
}

imap_test() {
  block "Starting IMAP Test block."
  local X=1
  local Y=3
  msg "Testing IMAP::Port $X/$Y"
  if [ -z $(port "143 993") ]; then return 1; fi
  let "X++"
  msg "Testing IMAP::Cert $X/$Y"
  if [ -n $(cert "993") ]; then return 1; fi
  let "X++"
  msg "Testing IMAP::Response $X/$Y"
  #Test TELNET response
  block "Finished IMAP Test block."
}

smtp_test() {
  block "Starting SMTP Test block."
  local X=1
  local Y=3
  msg "Testing SMTP::Port $X/$Y"
  if [ -z $(port "25 465") ]; then return 1; fi
  let "X++"
  msg "Testing SMTP::Cert $X/$Y"
  if [ -n $(cert "465") ]; then return 1; fi
  let "X++"
  msg "Testing SMTP::Response $X/$Y"
  #Test TELNET response
  block "Finished SMTP Test block."
}

pop_test() {
  block "Starting POP Test block."
  local X=1
  local Y=3
  msg "Testing POP::Port $X/$Y"
  if [ -z $(port "110  995") ]; then return 1; fi
  let "X++"
  msg "Testing POP::Cert $X/$Y"
  if [ -n $(cert "995") ]; then return 1; fi
  let "X++"
  msg "Testing POP::Response $X/$Y"
  #Test TELNET response
  block "Finished POP Test block."
}

https_test() {
  block "Starting HTTPS Test block."
  local X=1
  local Y=3
  msg "Testing HTTPS::Port $X/$Y"
  if [ -z $(port "443") ]; then return 1; fi
  let "X++"
  msg "Testing HTTPS::Cert $X/$Y"
  if [ -n $(cert "443") ]; then return 1; fi
  let "X++"
  msg "Testing HTTPS::Response $X/$Y"
  if [ $(response "https") != "200" ]; then return 1; fi
  block "Finished HTTPS Test block."
}

http_test() {
  block "Starting HTTP Test block."
  local X=1
  local Y=2
  msg "Testing HTTP::Port $X/$Y"
  if [ -z $(port "80") ]; then error "HTTP::Port Failed" && return 1; fi
  let "X++"
  msg "Testing HTTP::Response $X/$Y"
  if [ $(response) != "301" ]; then error "HTTP::Response Failed" && return 1; fi
  block "Finished HTTP Test block."
}

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
  if [ $PROGRESS == 6 ]; then docker stop mailcow-dind && msg "Testing Complete" && exit 0; fi
  error "Testing Failed. Re-attempting in 30 seconds."
  sleep 30s
done

error "The Mailcow Container exited for an unknown reason."
exit 1
