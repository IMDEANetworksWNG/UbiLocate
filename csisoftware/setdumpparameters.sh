#!/bin/sh

BLOCKS=$1
STARTREG=$2

if [ "$BLOCKS" = "" ]; then
  echo "Missing block number"
  exit 1
fi

if [ "$STARTREG" = "" ]; then
  echo "Missing start register"
  exit 1
fi

/usr/sbin/wl -i eth6 shmem 0x172a $BLOCKS
/usr/sbin/wl -i eth6 shmem 0x172c $STARTREG
