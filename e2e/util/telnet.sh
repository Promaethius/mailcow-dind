#!/bin/bash

telnet() {
  return $(telnet localhost "$1")
}
