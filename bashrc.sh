#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_CONFIG" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_CONFIG="$SOURCED_BASH_LAST"


#***************************[optional external variables]*********************
# 2019 04 21

# CONFIG_PATH_BACKUP
if [ "$CONFIG_PATH_BACKUP" != "" ] && [ ! -d "$CONFIG_PATH_BACKUP" ]; then
    echo -n "Error sourcing \"config\": "
    echo "path \$CONFIG_PATH_BACKUP does not exist"
fi

#***************************[paths and files]*********************************
# 2019 04 21

# this is only a local variable - no export
CONFIG_PATH="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"

if [ "$CONFIG_PATH_BACKUP" == "" ]; then
    export CONFIG_PATH_BACKUP="${CONFIG_PATH}backup/"
fi


#***************************[setting enviroment variables]********************
# 2018 01 11

# set terminal editor to nano
export EDITOR='nano -w'


#***************************[source]******************************************
# 2020 04 21

. ${CONFIG_PATH}scripts/functions.sh
. ${CONFIG_PATH}scripts/config.sh
. ${CONFIG_PATH}scripts/install.sh
. ${CONFIG_PATH}scripts/help.sh
