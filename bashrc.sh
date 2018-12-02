#!/bin/bash

#***************************[check if already sourced]************************
# 2018 11 30

if [ "$SOURCED_BASH_CONFIG" != "" ]; then

    return
    exit
fi

export SOURCED_BASH_CONFIG=1

#***************************[paths and files]*********************************
# 2018 11 17

temp_local_path="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"


#***************************[setting enviroment variables]********************
# 2018 01 11

# set terminal editor to nano
export EDITOR='nano -w'


#***************************[source]******************************************
# 2018 09 27

. ${temp_local_path}scripts/help.sh
