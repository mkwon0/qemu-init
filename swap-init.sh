#!/bin/bash

awk '$4 ~ /private/ {print substr($0,2);} $4 !~/private/ {print }' /etc/fstab > /etc/fstab.bak && mv /etc/fstab.bak /etc/fstab
cat /etc/fstab | grep private

/home/mkwon/util-linux-swap/swapon -a
cat /proc/swaps | grep private

awk '$4 ~ /private/ {print "#"$0} $4 !~/private/ {print }' /etc/fstab > /etc/fstab.bak && mv /etc/fstab.bak /etc/fstab
cat /etc/fstab | grep private
