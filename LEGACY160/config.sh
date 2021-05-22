#!/bin/sh

IFACE="eth6"
WL="/usr/sbin/wl -i ${IFACE}"
IFCONFIG="/sbin/ifconfig ${IFACE}"
CHANSPEC="44/160"
COUNTRY=UG

$WL up
$WL country ${COUNTRY}
$WL radio on
$WL infra 1
$WL chanspec ${CHANSPEC}
$WL monitor 1
$IFCONFIG up

echo "Interface ${IFACE} is monitor only on channel ${CHANSPEC}"
