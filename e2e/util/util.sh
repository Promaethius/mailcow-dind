#!/bin/bash

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
