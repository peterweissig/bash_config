#!/bin/bash

#***************************[paths and files]*********************************
# 2018 09 27

temp_local_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/"


#***************************[setting enviroment variables]********************
# 2018 01 11

# set terminal editor to nano
export EDITOR='nano -w'


#***************************[source]******************************************
# 2018 09 27

. ${temp_local_path}scripts/help.sh
