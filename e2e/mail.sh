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
  #Test port
  #Test index to init database
  #Test cert with openssl
  #Test logging in
  #Test SOGo response
}

http_test() {
  #Only test redirect status
}

until docker run -e HOSTNAME='example.com' -e CRON_BACKUP='* * * * * *' -e TIMEZONE='PDT' -v /home/travis/dind:/var/lib/docker -v /home/travis/mailcow:/mailcow -v /home/travis/mailcow-backup:/mailcow-backup --name mailcow-dind --privileged --net=host -d mailcow-dind
do
  #If all these tests return true
  http_test
  https_test
  pop_test
  smtp_test
  imap_test
  #Kill the mailcow-dind container
done

#Go on your merry way and push the image.
