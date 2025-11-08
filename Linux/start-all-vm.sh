#!/bin/bash

set -e

VBoxManage list vms | while read -r line; do
  vm=$(echo "$line" | cut -d'"' -f2)
  echo "Starting $vm..."
  VBoxManage startvm "$vm" --type headless
done

