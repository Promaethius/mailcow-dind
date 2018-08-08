#!/bin/bash

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
