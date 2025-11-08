#!/bin/bash

set -e

VBoxManage list runningvms | while read -r line; do
  vm=$(echo "$line" | cut -d'"' -f2)
  echo "Force power off $vm..."
  VBoxManage controlvm "$vm" poweroff
done

