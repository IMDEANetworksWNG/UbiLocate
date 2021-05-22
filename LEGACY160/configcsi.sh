#!/bin/sh

CHAN1=$1
CHAN2=$2

IFACE="eth6"
WL="/usr/sbin/wl -i ${IFACE}"
IFCONFIG="/sbin/ifconfig ${IFACE}"
CHANSPEC=${CHAN1}"/"${CHAN2}
COUNTRY=UG

$WL up
$WL country ${COUNTRY}
$WL radio on
$WL infra 1
$WL chanspec ${CHANSPEC}
$WL monitor 1
$IFCONFIG up

echo "Interface ${IFACE} is monitor only on channel ${CHANSPEC}"
