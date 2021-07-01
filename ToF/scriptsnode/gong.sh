#!/bin/sh
     
cd "$(dirname "$0")"
     
./starttxrx80fastng.sh >/tmp/logout 2>/tmp/logerr &
