#!/bin/bash

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd)

sudo qemu-system-x86_64 \
  -drive file=$1,format=raw,if=virtio \
  -drive if=pflash,format=raw,readonly=on,file="$BASEDIR"/ovmf/OVMF.4m.fd \
  -drive if=pflash,format=raw,file="$BASEDIR"/ovmf/OVMF_VARS.4m.fd