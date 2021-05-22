#!/bin/sh

echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger

