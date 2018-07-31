#!/bin/bash

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
