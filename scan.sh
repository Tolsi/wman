#!/bin/bash
# Fruit-FiScan.sh
# Made by Mr-Protocol
# 2013-12-12
# Updated by Tolsi in 2014

scan_result=/tmp/ScannedAPs_Parsed.MP

#### Scan area for networks and parse into a file in the format: BSS SSID CHAN ####
function scan () {
    local interface="$1"
    if [ -e /tmp/ScannedAPs_Parsed.MP ]; then
        rm /tmp/ScannedAPs_Parsed.MP
    fi

    iw "$interface" scan | grep -v OBSS | grep 'signal\|SSID\|BSS\|DS\ Parameter\ set' > /tmp/ScannedAPs.MP

    local BSS=()
    local SSID=()
    local CHAN=()
    local SIGNAL=()

    grep BSS /tmp/ScannedAPs.MP | awk '{print $2}' | tr 'a-f' 'A-F' > /tmp/BSS.MP
    grep SSID /tmp/ScannedAPs.MP | awk '{print $2}' > /tmp/SSID.MP
    grep channel /tmp/ScannedAPs.MP | awk '{print $5}' > /tmp/CHAN.MP
    grep signal /tmp/ScannedAPs.MP | awk '{print $2}' | grep -o "^[-0-9]\+" > /tmp/SIGNAL.MP

    while read LINE
    do
        BSS+=("$LINE")
    done < /tmp/BSS.MP

    while read LINE
    do
        SSID+=("$LINE")
    done < /tmp/SSID.MP 

    while read LINE
    do
        SIGNAL+=("$LINE")
    done < /tmp/SIGNAL.MP


    while read LINE
    do
        CHAN+=("$LINE")
    done < /tmp/CHAN.MP

    local count=$(( $(grep -c BSS /tmp/ScannedAPs.MP) - 1 ))
    for index in $(seq 0 $count)
    do
        echo "${BSS[index]}\`${SSID[index]}\`${SIGNAL[index]}\`${CHAN[index]}" >> "$scan_result"
    done
}

#echo `scan wlan0`