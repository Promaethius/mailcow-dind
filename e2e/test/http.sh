#!/bin/bash

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
