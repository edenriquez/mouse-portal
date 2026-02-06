#!/bin/bash
cd "/Users/eduardoenriquez/dev/github/mouse"
swift run inputshare send \
  --host 192.168.68.101 \
  --port 4242 \
  --identity-p12 .certs/device-b.p12 \
  --identity-pass inputshare-dev \
  --pin-sha256 8f158a7c0e17e88ea7873c8fa69fd0de3e45c84ca24c46b855d7eee8d12a2dd7
