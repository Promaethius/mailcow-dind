#!/bin/bash

USER_TEMP='{"local_part":"USER","domain":"DOMAIN","name":"John Doe","quota":"100","password":"moohoo","password2":"moohoo","active":"1"}'
DOMAIN_TEMP='{"domain":"DOMAIN","description":"demo+domain","aliases":"20","mailboxes":"20","maxquota":"3072","quota":"10240","active":"1"}'

data() {
  #Object Domain
  case $1 in
  "USER")
    TEMP=$USER_TEMP
    ;;
  "DOMAIN")
    TEMP=$DOMAIN_TEMP
    ;;
  *)
    error "Unsupported Data Type"
    ;;
  esac
}  

api() {
  if [ -d $DIR/mailcow ]; then
    . $DIR/mailcow/mailcow.conf
  else
    error "$DIR/mailcow/mailcow.conf not found."
    echo 0
  fi
  
  #Action Domain
  case $1 in
  "CREATE")
    ACTION="add"
    ;;
  *)
    error "Unsupported API Action"
    ;;
  esac
  
  #Object Domain
  case $2 in
  "USER")
    OBJECT="user"
    ;;
  "DOMAIN")
    OBJECT="domain"
    ;;
  *)
    error "Unsupported API Object"
    ;;
  esac
  
  curl -X POST -k https://127.0.0.1/api/v1/$ACTION/$OBJECT -d attr="$DATA" -H "X-API-Key: $API_KEY" -H "Host: $MAILCOW_HOSTNAME"
}
