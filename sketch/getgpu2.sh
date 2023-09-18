#!/bin/bash
# neofetch 

gpus=$(lspci -vmm | grep -A1  "VGA compatible controller" | grep -v "^Class:" | cut -d ':' -f 2-  | tr -d '\t' | cut -d ' ' -f 1 | tr '[:upper:]' '[:lower:]' | uniq)
echo "$gpus"
