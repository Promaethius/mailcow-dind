#!/bin/bash

error() {
  echo -e "\e[31m${1}"
}

msg() {
  echo -e "\e[32m${1}"
}

block() {
  echo -e "\e[34m${1}"
}
