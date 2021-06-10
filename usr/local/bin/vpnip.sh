#!/bin/bash

ipdecimal=/usr/local/lib/ipdecimal.sh
openvpn_conf=/etc/openvpn/dmdragon.d/dmdragon.conf
webroot=/home/azureuser/my-first-static-web-app

vpn_network=$(grep ^server $openvpn_conf)
vpn_network_address=$(echo $vpn_network | cut -d" " -f2)
vpn_netmask=$(echo $vpn_network | cut -d" " -f3)

declare -a addresses=$(ip address | grep inet | awk '{print $2}' | cut -d/ -f1)

. $ipdecimal
for address in ${addresses[@]}; do
    address=192.160.160.2
    if $(ipwith $vpn_network_address $vpn_netmask $address) && [ $address != $(cat $webroot/index.html) ]; then
        echo $address > $webroot/index.html
        pushd $webroot
        git add index.html
        git commit -m "Change IP Address."
        git push origin main
        popd
        break
    fi
done

exit 0
