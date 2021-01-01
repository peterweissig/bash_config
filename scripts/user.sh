#!/bin/bash

#***************************[clear home]**************************************
# 2019 09 26

function config_clear_home() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<username>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]username"
        echo "This function removes unused folders from the home-directory."
        echo "If no username is given, the current home-directory is used."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ $# -lt 1 ]; then
        home="${HOME}/"
    else
        home="/home/$1/"
    fi

    # check if home of user exists
    if [ ! -d "$home" ]; then
        echo "$FUNCNAME: directory \"$home\" does not exist!"
        return -2
    fi

    # list of folders to be removed
    list="Dokumente/ Documents/ \
          Musik/ Music/         \
          Bilder/ Pictures/     \
          Videos/ Video/        \
          Vorlagen/ Templates/  \
          Öffentlich/ Public/"

    # iterate over all folders
    for dir in $list; do
        path="${home}${dir}"
        if [ ! -d "$path" ]; then
            continue;
        fi

        if [ "$(ls "$path" | wc -w)" -gt 0 ]; then
            echo "warning, directory \"$dir\" is not empty"
        else
            echo "removing \"$dir\""
            rmdir "$path"
        fi
    done
}



#***************************[user login]**************************************
# 2020 01 26

function config_users_hide_login() {

    PATH_CONFIG="/var/lib/AccountsService/users/"
    FILENAME_CONFIG="${PATH_CONFIG}$1"

    AWK_STRING='
        # remove user from login-screen
        BEGIN {
            print "[User]"
            print "SystemAccount=true"
        }
    '

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<username>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: username"
        echo "This function removes the given user from the login-screen."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_username="$1"

    # check if user is in passwd and has a home
    temp="$(cat "/etc/passwd" | grep -e "^${param_username}" | wc -w)"
    if [ "$temp" -eq 0 ]; then
        echo "$FUNCNAME: user \"$param_username\" does not exist"
        return -2
    fi
    if [ ! -d "/home/$param_username" ]; then
        echo "$FUNCNAME: user \"$param_username\" does not have a home"
        return -2
    fi

    # check if AccountsService is used
    if [ ! -d "${PATH_CONFIG}" ]; then
        echo "$FUNCNAME: user \"$param_username\" does not use AccountsService"
        return -3
    fi

    # check if config file exists
    if [  -e "${FILENAME_CONFIG}" ]; then
        echo -n "$FUNCNAME: config file for user already exists - "
        echo "please edit manually"
        echo "    $ nano_config ${FILENAME_CONFIG}"
        echo "        >>> [User]"
        echo "        >>> SystemAccount=true"
        return -3
    fi

    # do the configuration
    _config_file_modify_full "${FILENAME_CONFIG}" "accounts_service" \
          "$AWK_STRING" "create-config" ""
}

function config_users_hide_login_restore() {

    FILENAME_CONFIG="${PATH_CONFIG}$1"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<username>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: username"
        echo "Restores the old behaviour for login of given user."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    _config_file_restore_full "$FILENAME_CONFIG" "accounts_service" \
      "create-config"
}


# 2020 12 26
function config_users_show_logins() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "shows all users on login screen."
    if [ $? -ne 0 ]; then return -1; fi


    FILENAME_CONFIG="/etc/lightdm/lightdm.conf"


    AWK_STRING='
        # remove greeter-hide-users
        $0 ~ /^greeter-hide-users=true/ {
          $0 = "# [REMOVED]: " $0
        }

        { print $0 }
    '

    # do the configuration
    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "auto"
}

function config_users_show_logins_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the login screen."
    if [ $? -ne 0 ]; then return -1; fi

    # undo the configuration
    FILENAME_CONFIG="/etc/ligthdm/ligthdm.conf"

    _config_file_restore "$FILENAME_CONFIG" "auto"
}
