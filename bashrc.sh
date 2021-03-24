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
# 2021 02 02

# this is only a local variable - no export
CONFIG_PATH="$(realpath "$(dirname "${BASH_SOURCE}")" )/"


# load and check data dir
if [ "$CONFIG_PATH_BACKUP" == "" ]; then
    CONFIG_PATH_BACKUP="$(_repo_bash_data_dirs_get --mkdir "config" \
      "${CONFIG_PATH}backup/")"
fi
_repo_bash_data_dirs_check --rmdir "$CONFIG_PATH_BACKUP" \
  "config" "${CONFIG_PATH}backup/"



#***************************[setting enviroment variables]********************
# 2018 01 11

# set terminal editor to nano
export EDITOR='nano -w'



#***************************[source]******************************************
# 2021 03 24

# internal or generic functions
source "${CONFIG_PATH}scripts/functions/apt.sh"
source "${CONFIG_PATH}scripts/functions/file.sh"
source "${CONFIG_PATH}scripts/functions/help.sh"
source "${CONFIG_PATH}scripts/functions/info.sh"
source "${CONFIG_PATH}scripts/functions/install.sh"
source "${CONFIG_PATH}scripts/functions/internal.sh"
source "${CONFIG_PATH}scripts/functions/service.sh"

# concrete settings (usually with a ..._restore counter part)
source "${CONFIG_PATH}scripts/apt.sh"
source "${CONFIG_PATH}scripts/bash.sh"
source "${CONFIG_PATH}scripts/bookmarks.sh"
source "${CONFIG_PATH}scripts/cpu.sh"
source "${CONFIG_PATH}scripts/file.sh"
source "${CONFIG_PATH}scripts/user.sh"
source "${CONFIG_PATH}scripts/sudo.sh"

# installing external packages
source "${CONFIG_PATH}scripts/install.sh"
