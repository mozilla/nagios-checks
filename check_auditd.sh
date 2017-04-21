#!/bin/bash

# Sample $STATUS output on Ubuntu 14:
# AUDIT_STATUS: enabled=1 flag=1 pid=7187 rate_limit=1000 backlog_limit=32768 lost=1430139 backlog=7
# Sample $STATUS output on Ubuntu 16:
# enabled 1
# failure 1
# pid 1604
# rate_limit 1000
# backlog_limit 32768
# lost 11652
# backlog 0
# backlog_wait_time 15000
# loginuid_immutable 0 unlocked

PATH="/sbin:/bin:/usr/sbin:/usr/bin"
EX=0
STATUS=($(/sbin/auditctl -s))

if [[ ${STATUS[@]:0:1} == 'AUDIT_STATUS:' ]]; then
    if [[ ${STATUS[@]:1:1} != 'enabled=1' ]]; then
        echo "audit has been disabled."
        EX=$(($EX+2))
    fi
else
    if [[ ${STATUS[@]:0:1} != 'enabled' && ${STATUS[@]:1:1} != '1' ]]; then
        echo "audit has been disabled."
        EX=$(($EX+2))
    fi
    if [[ ${STATUS[@]:4:1} == 'pid' && ${STATUS[@]:5:1} == '0' ]]; then
        echo "auditd process died or non-responsive."
        EX=$(($EX+3))
    fi
fi

# audisp-json is installed, so we expect it to be running, vs audisp-cef
if [[ ! $(pidof audisp-json) ]]; then
    echo "audisp-json process not present, but should be."
    EX=$(($EX+5))
fi

if [[ $EX -eq 0 ]]; then
    echo "audit is happy and running"
fi

exit $EX

