# wman - Wireless manager for OpenWRT
====

Openwrt wireless client manager daemon. 

Wman can:
* connect to available wireless network based on priority from the config file if there are users in LAN subnetwork by mask
* change wireless networks if current one lost the internet connection, until the internet connection will not be available again
* disable WiFi if there're not LAN users

# How to install it

0. To run wman you need to install dependencies: bash, nmap, iwinfo
1. Move wman folder to any path in your router (for example in /root)
2. Move etc folder to /etc
3. Insert the `wifi-device` section from your `/etc/config/wireless.conf` to the head of `/etc/wman/wireless.conf.template`
4. Create config files for yours aps (you can copy `wifi-iface` section from your `/etc/config/wireless.conf`). You can see examples in `/etc/wman/11:22:33:44:55:66.conf` and `12345.conf`. Config file must have a name equals wireless network name or wirelless network bssid.
5. Add your wirelless network in `/etc/wman/aps.conf`. 
File must have format: String(wireless network name or wirelless network bssid)[TAB]Character(y/n, must wman connects to other networks with lower priority if they are visible")

For example:
```
11:22:33:44:55:66	y
1234	n
```

The higher the recording is, the higher her priority

6. Change LAN ip mask in /root/wman/lan_clients_count.sh

You can read wman logs with `logread -f`

To add wman to autostart, you need add this line to your /etc/rc.local:
```
cd /root/wman && ./wman.sh > /dev/null 2>&1 &
```
