#!/bin/bash

### NAME
###        vpnip - Set IP address in VPN for Azure Static Web Apps.
###
### SYNOPSIS
###        vpnip.sh
###
### DESCRIPTION
###        Publish your own IP address within the IP address range of OpenVPN as a Web site.
###        When users access a website, they can obtain an IP address.
###
###        Get the network address and netmask of the VPN from the OpenVPN server configuration.
###        Use them to pick out your own IP address that is included in the IP address range of 
###        the VPN and write it to the Index file. Then push it to the GitHub repository.
###        This GitHub repository is the repository for Azure Static Web Apps, and when pushed,
###        it will be published as a website by GitHub Action.
###
###        The OpenVPN server configuration can only be read by root privileges, so this script
###        needs to be run as root user.
###
###        The following IP calculation library is used to calculate whether an IP address is included
###        in the IP address range.
###        https://qiita.com/harasou/items/5c14c335388f70e178f5
###

# Repository name
name=my-first-static-web-app
# Index file name
index=index.html
# IP calculation library
ipdecimal=/usr/local/lib/ipdecimal.sh

[ -r "$ipdecimal" ] || exit 1

# The root directory of the web site
webroot=$HOME/$name
# Path of the index file
index_path=$webroot/$index

current=""
[ -w "$index_path" ] && current=$(cat "$index_path")

openvpn_conf=$(ps -C openvpn -o args= | head -1 | grep -o "\-\-config [^ ]*" | cut -d" " -f2)
vpn_network=$(grep ^server $openvpn_conf)
[ -n "$vpn_network" ] || exit 1
vpn_network_address=$(echo $vpn_network | cut -d" " -f2)
vpn_netmask=$(echo $vpn_network | cut -d" " -f3)

declare -a addresses=$(ip address | grep inet | awk '{print $2}' | cut -d/ -f1)

. $ipdecimal
for address in ${addresses[@]}; do
    if $(ipwith $vpn_network_address $vpn_netmask $address) && [ "$address" != "$current" ]; then
        echo $address > $index_path
        pushd $webroot > /dev/null 2>&1
        git add $index
        git commit -qm "Changed IP address from $current to $address."
        git push -q origin main
        popd > /dev/null 2>&1
        break
    fi
done

exit 0
