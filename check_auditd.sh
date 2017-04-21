#!/bin/bash

STATUS=$(/sbin/auditctl -s)
TOK=($STATUS)
EX=0
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
#Sample $STATUS output:
#AUDIT_STATUS: enabled=1 flag=0 pid=8386 rate_limit=100 backlog_limit=320 lost=10534 backlog=0

if [[ ${TOK[1]} != 'enabled=1' ]]; then
    echo "audit has been disabled."
    EX=2
fi

if [[ ${TOK[3]} == 'pid=0' ]]; then
    echo "auditd process died or non-responsive."
    EX=2
fi

# audisp-json is installed, so we expect it to be running, vs audisp-cef
if [[ ! $(pidof audisp-json) ]]; then
    echo "audisp-json process not present, but should be."
    EX=2
fi

if [[ $EX -eq 0 ]]; then
    echo "audit is happy and running"
fi

exit $EX
