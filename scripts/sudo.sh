#!/bin/bash

#***************************[sudo]*******************************************

# 2021 01 26
function config_sudo_no_password() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<username]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "    [#1:]optional username (defaults to \$USER)"
        echo "This function gives sudo privileges to the user. She/he will"
        echo "never be ask for a password when running \"sudo\"."

        return
    fi

    # init variables
    param_user="$1"

    # chack parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ "$param_user" == "" ]; then
        param_user="$USER"
    fi
    if [ "$(getent passwd "$param_user")" == "" ]; then
        echo -n "$FUNCNAME: Unknown user \"$param_user\"."
        return -2
    fi

    # check
    PATH_CONFIG="/etc/sudoers.d/"

    if [ -d "$PATH_CONFIG" ]; then
        FILENAME_CONFIG="${PATH_CONFIG}90-${param_user}-nopasswd"
        if [ -e "$FILENAME_CONFIG" ]; then
            echo "file $FILENAME_CONFIG already exists"
            return
        fi

        echo "creating ${FILENAME_CONFIG}"
        echo "$param_user    ALL = NOPASSWD: ALL" | \
          sudo tee "$FILENAME_CONFIG" >> /dev/null
        sudo chown root:root "$FILENAME_CONFIG"
        sudo chmod 440 "$FILENAME_CONFIG"
        config_file_backup "$FILENAME_CONFIG"
    else
        FILENAME_CONFIG="/etc/sudoers"

        echo "checking $FILENAME_CONFIG"
        if sudo cat "$FILENAME_CONFIG" | grep "^${param_user}" | \
          grep " ALL = NOPASSWD: ALL" >> /dev/null; then
            echo "additional entry for user $param_user already exists"
            return
        fi

        echo "updating $FILENAME_CONFIG using visudo"
        echo "  please add the following line at the end of the file"
        echo "  $param_user    ALL = NOPASSWD: ALL"
        echo ""
        echo "<enter>"; read dummy
        config_file_backup "$FILENAME_CONFIG"
        sudo visudo
        config_file_backup "$FILENAME_CONFIG"
    fi

    if ! sudo visudo -c | grep "${FILENAME_CONFIG}" | \
      grep -i "ok" >> /dev/null; then
        echo "$ sudo visudo -c"
        sudo visudo -c
    else
        echo "done :-)"
    fi
}

# 2021 01 26
function config_sudo_no_password_restore() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<username]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "    [#1:]optional username (defaults to \$USER)"
        echo "This function removes the password-less sudo privileges"
        echo "of the given user."

        return
    fi

    # init variables
    param_user="$1"

    # chack parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ "$param_user" == "" ]; then
        param_user="$USER"
    fi
    if [ "$(getent passwd "$param_user")" == "" ]; then
        echo -n "$FUNCNAME: Unknown user \"$param_user\"."
        return -2
    fi

    # check
    PATH_CONFIG="/etc/sudoers.d/"

    if [ -d "$PATH_CONFIG" ]; then
        FILENAME_CONFIG="${PATH_CONFIG}90-${param_user}-nopasswd"
        if [ ! -e "$FILENAME_CONFIG" ]; then
            echo "file $FILENAME_CONFIG does not exist"
            return
        fi

        echo "removing ${FILENAME_CONFIG}"
        sudo rm "$FILENAME_CONFIG"
    else
        FILENAME_CONFIG="/etc/sudoers"

        echo "checking $FILENAME_CONFIG"
        if ! sudo cat "$FILENAME_CONFIG" | grep "^${param_user}" | \
          grep " ALL = NOPASSWD: ALL" >> /dev/null; then
            echo "no additional entry for user $param_user"
            return
        fi

        echo "updating $FILENAME_CONFIG using visudo"
        echo "  please remove the following line from the file"
        echo "  $param_user    ALL = NOPASSWD: ALL"
        echo ""
        echo "<enter>"; read dummy
        config_file_backup "$FILENAME_CONFIG"
        sudo visudo
        config_file_backup "$FILENAME_CONFIG"
    fi

    echo "$ sudo visudo -c"
    sudo visudo -c
}
