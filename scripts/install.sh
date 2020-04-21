#!/bin/bash

#***************************[nextcloud]***************************************
# 2020 04 21

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
    sudo apt-get update
    sudo apt install nextcloud-client --yes
}


#***************************[vs code]*****************************************
# 2020 04 21

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
    key_name="packages.microsoft.gpg"
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

        wget --output-document=- "$url_keys" | gpg --dearmor > "$key_name"
        if [ $? -ne 0 ]; then return -4; fi
        # install keys
        sudo install -o root -g root -m 644 "$key_name" "$key_path"
        if [ $? -ne 0 ]; then return -5; fi
        # remove key file
        rm "$key_name"
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
    sudo apt-get update
    sudo apt install code --yes
}


