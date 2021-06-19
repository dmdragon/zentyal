#!/bin/bash

name=my-first-static-web-app
ipdecimal=/usr/local/lib/ipdecimal.sh

[ -r "$ipdecimal" ] || exit 1

webroot=$HOME/$name
current=""
[ -w "$webroot/index.html" ] && current=$(cat $webroot/index.html)

openvpn_conf=$(ps -C openvpn -o args= | head -1 | grep -o "\-\-config [^ ]*" | cut -d" " -f2)
vpn_network=$(sudo grep ^server $openvpn_conf)
[ -n "$vpn_network" ] || exit 1
vpn_network_address=$(echo $vpn_network | cut -d" " -f2)
vpn_netmask=$(echo $vpn_network | cut -d" " -f3)

declare -a addresses=$(ip address | grep inet | awk '{print $2}' | cut -d/ -f1)

. $ipdecimal
for address in ${addresses[@]}; do
    if $(ipwith $vpn_network_address $vpn_netmask $address) && [ "$address" != "$current" ]; then
        echo $address > $webroot/index.html
        pushd $webroot > /dev/null 2>&1
        git add index.html
        git commit -qm "Change IP Address."
        git push -q origin main
        popd > /dev/null 2>&1
        break
    fi
done

exit 0
