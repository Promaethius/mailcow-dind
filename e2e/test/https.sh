#!/bin/bash

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
  if [ $(response "https" "example.com") != "200" ]; then return 1; fi
  block "Finished HTTPS Test block."
}
