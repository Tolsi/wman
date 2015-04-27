#!/bin/bash

wman_configs_folder="/etc/wman"

function connect_to_ap(){
    [[ -n "$1" ]] || {
        echo "usage: connect_to_ap <ap_name>"
        return 2
    }
    local ap_name=$1

    local template_filename="$wman_configs_folder/wireless.conf.template"
    local temp_template_filename="/tmp/wireless.conf"
    local config_file="/etc/config/wireless"
    
    local ap_config="$wman_configs_folder/$ap_name.conf"
    
    if [[ -f $ap_config ]]; then
        sed -e '/<SETTINGS>/{r '$ap_config'' -e 'd}' $template_filename  > $temp_template_filename
        echo "connecting to: $ap_name config: $ap_config"
        cp -f $temp_template_filename $config_file
        rm $temp_template_filename
        wifi
    else
        echo "Config file $ap_config not found!"
    fi
}

#connect_to_ap TEST