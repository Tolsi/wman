#!/bin/bash

#imports
. scan.sh
. accepted.sh
. ap.sh

#variables
wlan_interface="wlan0"



function main()
{
    `scan $wlan_interface`
    # TODO индекс текущей точки
    eval `accepted`
    
	# for-each пока у них нет интернета
    local first_hight_priority_ap="$(accepted[0])"
    IFS=', ' read -a ap <<< "$first_hight_priority_ap"
    local priority="$ap[0]";
    local BSSID="$ap[1]";
    
    #сортировать по силе сигнала
    #sort -t '`' -k3nr /tmp/ScannedAPs_Parsed.MP -o /tmp/ScannedAPs_Parsed.MP
    
    #фильтрация свойств только нужных точек
    #cat /tmp/ScannedAPs_Parsed.MP | grep '7094\|555'
    
    #AP 'ap1' o1:3f:33 Ololo -42 3
    #$ap1_show
    #$ap1_connect
}

main