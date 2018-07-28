#!/bin/bash

set -ex

telnet() {

}

response() {

}

imap_test() {
  #Test port response
  #Test TELNET response
}

smtp_test() {
  #Test port response
  #Test TELNET response
}

pop_test() {
  #Test port response
  #Test TELNET response
}

https_test() {
  #Test index to init database
  #Test logging in
  #Test SOGo response
}

http_test() {
  #Only test redirect status
}

until docker run -e HOSTNAME='example.com' -e CRON_BACKUP='* * * * * *' -e TIMEZONE='PDT' -v /home/travis/dind:/var/lib/docker -v /home/travis/mailcow:/mailcow -v /home/travis/mailcow-backup:/mailcow-backup --name mailcow-dind --privileged --net=host -d mailcow-dind
do
  
