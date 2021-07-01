#!/bin/sh
     
cd "$(dirname "$0")"
     
./starttxrx80fastng_2.sh >/tmp/logout 2>/tmp/logerr &
