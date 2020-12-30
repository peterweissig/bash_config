#!/bin/bash

#***************************[nextcloud]***************************************
# 2020 12 29

function config_install_nextcloud() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function installs the nextcloud client."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


    # check source files
    str="$(_config_check_sources_nextcloud)"

    if [ "$?" -ne 0 ]; then
        echo "$FUNCNAME: error while checking source list"
        return -2
    fi
    if [ -e "$str"  ]; then
        echo "$FUNCNAME: source list is already installed"
        return
    fi

    # install based on website
    #  https://launchpad.net/~nextcloud-devs/+archive/ubuntu/client
    url_repository="ppa:nextcloud-devs/client"

    # adding repository
    echo "$FUNCNAME: adding repository"
    echo "  ($url_repository)"
    sudo add-apt-repository "$url_repository" --yes
    if [ $? -ne 0 ]; then return -3; fi

    # install client
    sudo apt update
    sudo apt install nextcloud-client --yes
}


#***************************[vs code]*****************************************
# 2020 12 30

function config_install_vscode() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function installs visual studio code."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


    # check source files
    str="$(_config_check_sources_vscode)"

    if [ "$?" -ne 0 ]; then
        echo "$FUNCNAME: error checking if program is already installed"
        return -2
    fi
    if [ -e "$str"  ]; then
        echo "$FUNCNAME: program is already installed"
        return
    fi

    # install based on website
    #  https://code.visualstudio.com/docs/setup/linux
    url_repository="https://packages.microsoft.com/repos/vscode"
    url_keys="https://packages.microsoft.com/keys/microsoft.asc"
    key_path="/usr/share/keyrings/"
    tempfile="$(mktemp)"
    source_list="/etc/apt/sources.list.d/vscode.list"

    if [ -e "$source_list" ]; then
        echo "$FUNCNAME: error source file already exist"
        echo "  ($source_list)"
        return -3
    fi

    # check keys
    if [ ! -e "${key_path}${key_name}" ]; then
        echo "$FUNCNAME: adding keys from microsoft"
        echo "  ($url_keys)"

        wget --output-document=- "$url_keys" | gpg --dearmor > "$tempfile"
        if [ $? -ne 0 ]; then return -4; fi
        # install keys
        sudo install -o root -g root -m 644 "$tempfile" "$key_path"
        if [ $? -ne 0 ]; then return -5; fi
        # remove key file
        rm "$tempfile"
    fi

    # setup source list
    echo "$FUNCNAME: creating source list"
    echo "  ($source_list)"

    (
        echo -n "deb [arch=amd64 signed-by=${key_path}${key_name}] "
        echo    "${url_repository} stable main"
    ) | sudo tee "$source_list"
    if [ $? -ne 0 ]; then return -6; fi

    # install vscode
    sudo apt update
    sudo apt install code --yes
}


#***************************[ros]*********************************************
# 2020 12 29

function config_install_ros() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function installs appropriate ROS 1 version."
        echo " (kinetic, melodic or noetic)"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


    # check source files
    str="$(_config_check_sources_ros)"

    if [ "$?" -ne 0 ]; then
        echo "$FUNCNAME: error checking if ros sources are already installed"
        return -2
    fi
    if [ -e "$str"  ]; then
        echo "$FUNCNAME: ros sources are already installed"
        return
    fi

    # check ubuntu version
    VER=$(lsb_release -r | cut -f2 | cut -d. -f1)
    if [ $VER -eq 20 ]; then
        ROS_DISTRO="noetic"
    elif [ $VER -eq 18 ]; then
        ROS_DISTRO="melodic"
    elif [ $VER -eq 16 ]; then
        ROS_DISTRO="kinetic"
    else
        echo "$FUNCNAME: no currently supported ROS1 version available"
        return -3
    fi

    # install based on website
    #   https://www.ros.org/install/
    url_key="hkp://keyserver.ubuntu.com:80"
    key_id="C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654"
    source_list="/etc/apt/sources.list.d/ros.list"

    if [ -e "$source_list" ]; then
        echo "$FUNCNAME: error source file already exist"
        echo "  ($source_list)"
        return -4
    fi

    # check keys
    if [ "$( apt-key list "${key_id}")" == "" ]; then
        echo "$FUNCNAME: adding keys from ROS"
        echo "  ($url_key)"

        sudo apt-key adv --keyserver "$url_key" \
          --recv-key "$key_id"
    fi

    # setup source list
    echo "$FUNCNAME: creating source list"
    echo "  ($source_list)"

    (
        echo -n "deb http://packages.ros.org/ros/ubuntu "
        echo    "$(lsb_release -sc) main"
    ) | sudo tee "$source_list"
    if [ $? -ne 0 ]; then return -6; fi

    # install ros
    sudo apt update
    sudo apt install ros-${ROS_DISTRO}-desktop --yes

    # hint for more
    echo "You may also install the full ros version:"
    echo "  $ sudo apt install ros-${ROS_DISTRO}-desktop-full"
}

