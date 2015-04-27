#!/bin/bash
# Fruit-FiScan.sh
# Made by Mr-Protocol
# 2013-12-12
# Updated by Tolsi in 2014

scan_result=/tmp/ScannedAPs_Parsed.MP
. connect_to_ap.sh

#### Scan area for networks and parse into a file in the format: BSS SSID CHAN ####
function scan () {
    local interface="$1"
    if [ -e /tmp/ScannedAPs_Parsed.MP ]; then
        rm /tmp/ScannedAPs_Parsed.MP
    fi

	local wlan_exists=$( ifconfig | grep "$interface" | wc -l )
	if (( $"wlan_exists" == 0 )); then 
		connect_to_ap scan
		sleep 2
	fi
    iwinfo wlan0 scan > /tmp/ScannedAPs.MP

    local BSS=()
    local SSID=()
    local CHAN=()
    local SIGNAL=()

    grep Address /tmp/ScannedAPs.MP | awk '{print $5}' | tr 'a-f' 'A-F' > /tmp/BSS.MP
    grep ESSID /tmp/ScannedAPs.MP | awk '{print $2}' | sed 's/"//g' > /tmp/SSID.MP
    grep Channel /tmp/ScannedAPs.MP | awk '{print $4}' > /tmp/CHAN.MP
    grep Quality /tmp/ScannedAPs.MP | awk '{print $5}' | sed 's/\/70//' > /tmp/SIGNAL.MP

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

    local count=$(( $(grep -c Address /tmp/ScannedAPs.MP) - 1 ))
    for index in $(seq 0 $count)
    do
        echo "${BSS[index]}|${SSID[index]}|${SIGNAL[index]}|${CHAN[index]}" >> "$scan_result"
    done
}

#scan wlan0