#!/bin/bash

scanned_file="/tmp/ScannedAPs_Parsed.MP"

#Фильтруем только разрешённые точки с индексом, меньше аргумента (меньше индекс - больше аргумент)
# priority
function accepted () {
    local priority=$1
    if [ -z "${priority}" ]; then priority=999999; fi

    local accepted=()
    if (( "${priority}" > "0" )); then 
        local line_index=0
        
        while read -r line; do
            if (( "$line_index" < "$priority" )); then
                if grep -Fq "$line" "$scanned_file"; then
                    accepted+=("$line_index:$line")
                fi
            fi
            (( line_index += 1 ))
        done < aps.conf
    fi
    
    declare -p accepted
}

#echo `accepted`
