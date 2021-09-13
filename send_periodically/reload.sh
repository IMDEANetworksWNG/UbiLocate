#!/bin/sh

cd "$(dirname "$0")"

/sbin/rmmod dhd ; /sbin/insmod ./dhd.ko
