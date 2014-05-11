#!/bin/bash

wman_folder="/etc/wman"
 
# Base class. (1)
function AP()
{
    # A pointer to this Class. (2)
    base=$FUNCNAME
    this=$1
 
    # Declare Properties. (4)
    export ${this}_ESSID=$2
    export ${this}_BSSID=$3
    export ${this}_TXPOWER=$4
    export ${this}_CHANNEL=$5
 
    # Declare methods. (5)
    for method in $(compgen -A function)
    do
        export ${method/#$base\_/$this\_}="${method} ${this}"
    done
}
 
# Human readable representation of the vector. (6)
function AP_show()
{
    # (7)
    base=$(expr "$FUNCNAME" : '\([a-zA-Z][a-zA-Z0-9]*\)')
    this=$1
 
    ESSID=$(eval "echo \$${this}_ESSID")
    BSSID=$(eval "echo \$${this}_BSSID")
    TXPOWER=$(eval "echo \$${this}_TXPOWER")
    CHANNEL=$(eval "echo \$${this}_CHANNEL")
 
    echo "$this (ESSID:$ESSID, BSSID:$BSSID, TXPOWER:$TXPOWER, CHANNEL:$CHANNEL)"
}

function AP_connect()
{
    # (7)
    base=$(expr "$FUNCNAME" : '\([a-zA-Z][a-zA-Z0-9]*\)')
    this=$1

    local template_filename="$wman_folder/wireless.conf.template"
    local temp_template_filename="/tmp/wireless.conf"
    local config_file="/etc/config/wireless"
    ESSID=$(eval "echo \$${this}_ESSID")
    BSSID=$(eval "echo \$${this}_BSSID")
    
    local filename="$wman_folder/$BSSID.conf"

    sed -e '/<SETTINGS>/{r '$filename'' -e 'd}' $template_filename  > $temp_template_filename
    cp -f $temp_template_filename $config_file
    echo "connect to $filename ($temp_template_filename)"
    #rm $temp_template_filename
    #wifi
}