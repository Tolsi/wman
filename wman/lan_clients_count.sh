#!/bin/bash

function lan_clients_count() {
	# TODO массив строк с диапазонами в параметры
    local count=$( nmap -sn 192.168.0.2-255 | grep 'Nmap scan report for' | wc -l )
    echo $count
}

#lan_clients_count