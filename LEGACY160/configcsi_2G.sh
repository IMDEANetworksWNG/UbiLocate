#!/bin/bash
cd "$(dirname "$0")"

BW=20

# equivalent to configcsiblablabla.sh
/usr/sbin/wl -i eth5 up
/usr/sbin/wl -i eth5 radio on
/usr/sbin/wl -i eth5 country UG
/usr/sbin/wl -i eth5 chanspec 6/20
/usr/sbin/wl -i eth5 monitor 1
/sbin/ifconfig eth5 up


