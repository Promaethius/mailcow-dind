#!/bin/bash

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
