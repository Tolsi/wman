#!/bin/bash

#imports
. scan.sh
. accepted.sh
. check_connection.sh
. lan_clients_count.sh
. connect_to_ap.sh

#variables
wlan_interface="wlan0"
wan_interface="br-wan"
wait_connect_time=15
recheck_time=20
aps_without_internet=()
aps_without_internet_clear=60
no_clients_shutdown=120

rm -rf /tmp/wman/
mkdir /tmp/wman/
touch /tmp/wman/current_ap_prioriry
touch /tmp/wman/aps_without_internet_i
echo 0 > /tmp/wman/aps_without_internet_i
echo 0 > /tmp/wman/no_clients_i

function join() {
    # $1 is return variable name
    # $2 is sep
    # $3... are the elements to join
    local retname=$1 sep=$2 ret=$3
    shift 3 || shift $(($#))
    printf -v "$retname" "%s" "$ret${@/#/$sep}"
}

function log(){
	local msg=$1
	echo $msg
	logger -t wman $msg
}

function try_connect_to_accepted(){
	# пробуем точки, пока у нас нет интернета
	join aps_string "," "${accepted[@]}"
	log "Accepted APS (${#accepted[@]}): ${aps_string}"
	for ap_string in "${accepted[@]}"
	do
		IFS='|' read -a ap <<< "$ap_string"
		local priority="${ap[0]}"
		local BSSID="${ap[1]}"
		local connect_to_better="${ap[2]}"
		if [[ ${aps_without_internet[*]} =~ ${BSSID} ]]; then
			local aps_without_internet_i=$(</tmp/wman/aps_without_internet_i)
			if (( "$aps_without_internet_i" >= "$aps_without_internet_clear" )); then
				aps_without_internet=()
				echo 0 > /tmp/wman/aps_without_internet_i
			else
				# TODO зависит от количества точек без интернета
				echo "$(( aps_without_internet_i + 1 ))" > /tmp/wman/aps_without_internet_i
				log "without internet i: '$aps_without_internet_i' Value to reset: '$aps_without_internet_clear'"
			fi
		else
			log "trying $ap_string"
			# подключаемся к точке
			connect_to_ap "$BSSID"
			# ждём подключения
			sleep "$wait_connect_time"
			# проверка соединения
			if (( $( check_connection "$wlan_interface" ) == 1 )); then
				log "Connection to internet restored! Connected to $BSSID with priority $priority"
				echo "$priority" > /tmp/wman/current_ap_prioriry
				break
			else
				log "$BSSID hasnt internet!"
				aps_without_internet+=("$BSSID")
			fi
		fi
	done
	if (( $( check_connection "$wlan_interface" ) == 0 )); then
		log "No internet in accepted APS. Retry"
		aps_without_internet=()
		echo 0 > /tmp/wman/aps_without_internet_i
	fi
}

function main()
{
	# если нет wan подключения
	if (( $( check_connection "$wan_interface" ) == 0 )); then
		log "wan interface hasnt internet"
		# если у нас нет клиентов, то wifi мы выключаем
		if (( $( lan_clients_count ) > 0 )); then
			log "there are clients in lan"
			
			local no_clients_i=$(</tmp/wman/no_clients_i)
			if ! [ -z "$no_clients_i" ] && (( "$no_clients_i" > 0 )); then
				echo 0 > /tmp/wman/no_clients_i
			fi
			
			# приоритет текущей точки
			local current_ap_prioriry=$(</tmp/wman/current_ap_prioriry)
			if (( $( check_connection "$wlan_interface" ) == 0 )); then
				rm /tmp/wman/current_ap_prioriry
				log "Internet connection was losted!"
				scan "$wlan_interface"
				
				eval `accepted`
				
				try_connect_to_accepted
			else
				log "We have internet connection"
				local current_ap_line=$( sed "$(( $current_ap_prioriry + 1 ))q;d" /etc/wman/aps.conf )
				IFS=$'\t' read -a ap <<< "$current_ap_line"
				local connect_to_better="${ap[1]}"
				# поиск лучших точек отключается
				if [[ $connect_to_better == "y" ]]; then
					#ищем точки, приоритетнее этой
					log "Trying connect to better"
					scan "$wlan_interface"
					eval `accepted $current_ap_prioriry`
					try_connect_to_accepted
				fi
			fi
		else
			local no_clients_i=$(</tmp/wman/no_clients_i)
			if (( "$no_clients_i" >= "$no_clients_shutdown" )); then
				log "there are not clients in lan. shutdown wifi"
				rm /tmp/wman/current_ap_prioriry
				ifconfig "$wlan_interface" down
			else
				log "there are not clients in lan. no_clients_i: $no_clients_i"
				echo "$(( no_clients_i + 1 ))" > /tmp/wman/no_clients_i
			fi
		fi
    fi
    
    #сортировать по силе сигнала
    #sort -k3nr /tmp/ScannedAPs_Parsed.MP -o /tmp/ScannedAPs_Parsed.MP
    
    #фильтрация свойств только нужных точек
    #cat /tmp/ScannedAPs_Parsed.MP | grep '7094\|555'
    
    #AP 'ap1' o1:3f:33 Ololo -42 3
    #$ap1_show
    #$ap1_connect
}

ifconfig "$wlan_interface" down
while [ 1 ]; do
    main
	sleep $recheck_time
done
