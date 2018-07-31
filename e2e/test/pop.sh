#!/bin/bash

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
