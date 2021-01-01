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
# 2020 12 27

# this is only a local variable - no export
CONFIG_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"


if [ "$CONFIG_PATH_BACKUP" == "" ]; then
    # check if an alternative path exists
    if [ "$REPO_BASH_DATA_PATH" != "" ] && \
      [ -d "$REPO_BASH_DATA_PATH" ]; then
        export CONFIG_PATH_BACKUP="${REPO_BASH_DATA_PATH}config/"
    else
        export CONFIG_PATH_BACKUP="${CONFIG_PATH}backup/"
    fi

    # check if config folder exists
    if [ ! -d "$CONFIG_PATH_BACKUP" ]; then
        echo "creating backup folder for \"config\""
        echo "    ($CONFIG_PATH_BACKUP)"
        mkdir -p "$CONFIG_PATH_BACKUP"
    fi
fi



#***************************[setting enviroment variables]********************
# 2018 01 11

# set terminal editor to nano
export EDITOR='nano -w'



#***************************[source]******************************************
# 2021 01 01

# internal or generic functions
. ${CONFIG_PATH}scripts/functions/apt.sh
. ${CONFIG_PATH}scripts/functions/file.sh
. ${CONFIG_PATH}scripts/functions/help.sh
. ${CONFIG_PATH}scripts/functions/info.sh
. ${CONFIG_PATH}scripts/functions/install.sh
. ${CONFIG_PATH}scripts/functions/internal.sh

# concrete settings (usually with a ..._restore counter part)
. ${CONFIG_PATH}scripts/apt.sh
. ${CONFIG_PATH}scripts/bash.sh
. ${CONFIG_PATH}scripts/file.sh
. ${CONFIG_PATH}scripts/user.sh

# installing external packages
. ${CONFIG_PATH}scripts/install.sh

