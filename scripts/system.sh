#!/bin/bash

#***************************[password security]*******************************

# 2023 01 28
function config_password_disable_rejection() {

    FILENAME_CONFIG="/etc/security/pwquality.conf"

    AWK_STRING='
        # disabling password rejection
        $0 ~ /^# enforcing = 1/ {
          $0 = "enforcing = 0"
        }

        { print $0 }
    '

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "disables password rejection."
    if [ $? -ne 0 ]; then return -1; fi

    # check config file
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "$FUNCNAME: config file \"$FILENAME_CONFIG\" does not exist"
        return -2
    fi
    temp="$(cat "$FILENAME_CONFIG" | grep -e '^enforcing = 0' | wc -l)"
    if [ "$temp" -gt 0 ]; then
        echo "$FUNCNAME: password rejection already disabled"
        return -3
    fi

    # do the configuration
    _config_file_modify_full "${FILENAME_CONFIG}" "password" \
          "$AWK_STRING" "backup-once" ""
}

# 2023 01 28
function config_password_disable_rejection_restore() {

    FILENAME_CONFIG="/etc/security/pwquality.conf"

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores previous password settings."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    _config_file_restore_full "$FILENAME_CONFIG" "password" \
      "backup-once"
}
