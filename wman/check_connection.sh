#!/bin/bash

function check_connection() {
    local count=3                                # Maximum number to try.
    while [[ $count -ne 0 ]] ; do
        ping -c 1 -W 5 -I "$1" 8.8.8.8 > /dev/null       # Try once.
        local rc=$?
        if [[ $rc -eq 0 ]] ; then
            count=1                         # If okay, flag to exit loop.
        fi
        ((count = count - 1))               # So we don't go forever.
    done

    if [[ $rc -eq 0 ]] ; then               # Make final determination.
        echo 1
    else
        echo 0
    fi
}

#echo `check_connection wlan0`
