#!/bin/bash

### NAME
###        ipdecimal.sh - Converts an IP address and a 32-bit decimal value to each other
###
###        ip2decimal - Converts IP address representations to 32-bit values
###        decimal2ip - Converts 32-bit values to IP address representations
###        cidr2decimal - Converts CIDR network addresses to 32-bit values
###        iplist - Get a list of consecutive IP addresses
###        ipwith - Determine if an IP address is in the range of a particular network
###
### SYNOPSIS
###        ip2decimal ip_address
###        decimal2ip decimal
###        cidr2decimal cidr
###        iplist ip_address number
###        ipwith ip_address netmask determined_ip_address
###
### DESCRIPTION
###        Convert the IP address representations to 32-bit values in order to calculate the IP address in 32-bit values.
###        Convert the 32-bit value to IP address representations in order to use IP address representations for the result
###        after the calculation.
###        Also converts CIDR value to 32-bit value in order to calculate netmask in 32-bit value.
###
###        Use these to calculate the IP address in 32-bit value.
###        Also, the calculation result can be expressed in IP address representations.
###
###　　　　　These include a function to obtain a list of consecutive IP addresses and a function to determine
###        if an IP address is in a particular network range.
###
### AUTHOR
###        harasou <https://harasou.jp/>
###
### SEE ALSO
###        https://qiita.com/harasou/items/5c14c335388f70e178f5

# IP address to 32-bit decimal value.
function ip2decimal(){
    local IFS=.
    local c=($1)
    printf "%s\n" $(( (${c[0]} << 24) | (${c[1]} << 16) | (${c[2]} << 8) | ${c[3]} ))
}

# 32-bit decimal value to IP address.
function decimal2ip(){
    local n=$1
    printf "%d.%d.%d.%d\n" $(($n >> 24)) $(( ($n >> 16) & 0xFF)) $(( ($n >> 8) & 0xFF)) $(($n & 0xFF))
}

# CIDR to 32-bit decimal value.
function cidr2decimal(){
    printf "%s\n" $(( 0xFFFFFFFF ^ ((2 ** (32-$1))-1) ))
}

# Get a list of consecutive IPs.
function iplist(){
    local num=$(ip2decimal $1)
    local max=$(($num + $2 - 1))

    while :
    do
        decimal2ip $num
        [[ $num == $max ]] && break || num=$(($num+1))
    done
}

# Is an IP in the range of a particular network?
function ipwith(){
   local addr=$1
   local mask=$2

   local num=$(ip2decimal $3)
   local net=$(( $(ip2decimal $addr) & $(ip2decimal $mask) ))
   local brd=$(( $(ip2decimal $addr) | (0xFFFFFFFF ^ $(ip2decimal $mask)) ))

   [ $net -le $num -a $num -le $brd ] && return 0 || return 1
}
