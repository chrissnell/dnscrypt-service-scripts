#! /usr/bin/env bash

systemctl -q is-active dnscrypt-wrapper@a
A_RUNNING=$?

systemctl -q is-active dnscrypt-wrapper@b
B_RUNNING=$?

if [[ $A_RUNNING -eq 0 && $B_RUNNING -gt 0 ]]; then
    echo "Preparing to replace dnscrypt-wrapper@a.service with dnscrypt-wrapper@b.service ..."
    echo "Startring dnscrypt-wrapper@b.service ..."
    systemctl start dnscrypt-wrapper@b.service
    sleep 5
    echo "Shutting down dnscrypt-wrapper@a.service ..."
    systemctl stop dnscrypt-wrapper@a.service
fi

if [[ $A_RUNNING -gt 0 && $B_RUNNING -eq 0 ]]; then
    echo "Preparing to replace dnscrypt-wrapper@b.service with dnscrypt-wrapper@a.service ..."
    echo "Startring dnscrypt-wrapper@a.service ..."
    systemctl start dnscrypt-wrapper@a.service
    sleep 5
    echo "Shutting down dnscrypt-wrapper@b.service ..."
    systemctl stop dnscrypt-wrapper@b.service
fi 

if [[ $A_RUNNING -gt 0 && $B_RUNNING -gt 0 ]]; then
    echo "Neither dnscrypt-wrapper@a.service or dnscrypt-wrapper@b.service are running."
    echo "Startring dnscrypt-wrapper@a.service ..." 
    systemctl start dnscrypt-wrapper@a.service 
fi
