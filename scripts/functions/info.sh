#!/bin/bash

#***************************[config_info]*************************************
# 2020 10 06

function config_info() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function returns some basic infos:"
        echo "  RAM, ROM, CPU, IP, ..."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    echo ""
    ip address show | grep --color=auto --extended-regexp \
      "(^[^ ]+ [^ ]+|(inet|ether) [^ ]+)"
    #ifconfig | grep -E "(Link |inet )"

    echo ""
    lsb_release -a | grep "Description"
    echo "Hostname: $HOSTNAME"
    echo -n "user: " && ls /home/ | sed -z 's/[ /\t\n]\+/ /g' && echo ""

    echo ""
    cat /proc/cpuinfo | grep "model name" | head -n 1
    cat /proc/cpuinfo | grep "cores"      | head -n 1
    cat /proc/cpuinfo | grep "MHz"

    echo ""
    cat /proc/meminfo | grep "MemTotal"

    echo ""
    sudo parted --script --list | grep --color=auto --extended-regexp \
      "/dev/sd[^ :]+"
}
