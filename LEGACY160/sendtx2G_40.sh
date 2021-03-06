#!/bin/bash

BW=$1
if [ "$BW" = "" ]; then
  echo "Missing bandwidth"
  exit 1
fi
case $BW in
20)
  B=1
  ;;
40)
  B=2
  ;;
80)
  B=3
  ;;
160)
  B=4
  ;;
*)
  echo "Invalid bandwitdh"
  exit 1
  ;;
esac


cd "$(dirname "$0")"

if [ "$2" != "" ]; then
  REPEAT=$2
else
  REPEAT=1
fi

while [ "$REPEAT" != "0" ]; do
./nexutil -I eth5 -s 505 -b -l 574 -v `printf "\
\x10\x00\x0${B}\x01\
\x88\x02\x00\x00\
\xff\xff\xff\xff\xff\xff\
\x00\x12\x34\x56\x78\x9b\
\x00\x11\x22\x33\x44\x55\
\x00\x00\
\x00\x00\
\xaa\xaa\x03\x00\x00\x00\x08\x00\
\x45\x00\x00\x26\xc5\x16\x40\x00\x40\x11\
\xe0\x4a\xc0\xa8\x0a\x14\xc0\xa8\x0a\x01\
\x9a\x30\x0e\xfe\x00\x12\xa6\xcf\
\x66\x69\x63\x61\x70\x65\x6c\x6f\
\x73\x61\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\xde\xad\xbe\xef\
" | /usr/sbin/openssl enc -base64 | tr -d "\n"`
REPEAT=$((REPEAT-1))
#usleep 1000
done
