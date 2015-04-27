#!/bin/bash

scanned_file="/tmp/ScannedAPs_Parsed.MP"

#Фильтруем только разрешённые точки с индексом, меньше аргумента (меньше индекс - больше аргумент)
# priority

function accepted () {
    local priority=$1
    if [ -z "${priority}" ]; then priority=999999; fi

    local accepted=()
	local line_index=0
	
	while read -r line; do
		IFS=$'\t' read -a ap <<< "$line"
		local BSSID="${ap[0]}"
		local connect_to_better="${ap[1]}"
		if (( "$line_index" < "$priority" )); then
			if grep -Fq "$BSSID" "$scanned_file"; then
				accepted+=("$line_index|$BSSID|$connect_to_better")
			fi
		fi
		(( line_index += 1 ))
	done < /etc/wman/aps.conf
    
    declare -p accepted
}

#echo `accepted`
