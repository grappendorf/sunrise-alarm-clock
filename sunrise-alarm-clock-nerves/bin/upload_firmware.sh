#!/usr/bin/env bash

IP=${1:-192.168.1.60}

curl -vX POST http://$IP:8988/firmware\
  -H "Content-Type: application/x-firmware"\
  -H "X-Reboot: true"\
  --data-binary "@_images/rpi/fw.fw"\
