#!/bin/bash

#***************************[apt]*********************************************
# 2019 09 08

function config_update_system() {

    echo "1. sudo apt update"
    sudo apt update
    if [ $? -ne 0 ]; then return -1; fi

    echo ""
    echo "2. sudo apt upgrade --assume-yes"
    sudo apt upgrade --assume-yes
    if [ $? -ne 0 ]; then return -2; fi

    echo ""
    echo "3. sudo apt dist-upgrade --assume-yes"
    sudo apt dist-upgrade --assume-yes
    if [ $? -ne 0 ]; then return -3; fi

    echo ""
    echo "4. sudo apt autoremove --assume-yes"
    sudo apt autoremove --assume-yes
    if [ $? -ne 0 ]; then return -4; fi

    echo ""
    echo "done :-)"
}



#***************************[sources.list]************************************
# 2019 11 20

function config_source_list_add_multiverse() {

    FILENAME_CONFIG="/etc/apt/sources.list"

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "appends restricted, universe and multiverse to all sources." \
      "  (only changing $FILENAME_CONFIG)"
    if [ $? -ne 0 ]; then return -1; fi

    # check if already set
    temp="$(cat "$FILENAME_CONFIG" | grep --extended-regexp "^deb" | \
      grep --extended-regexp "(multiverse|universe|restricted)")"
    if [ "$(echo "$temp" | wc -w)" -gt 0 ]; then
        echo -n "$FILENAME_CONFIG: multiverse, universe or restricted "
        echo "is already set!"
        echo ""
        echo "$temp"
        return -2
    fi

    # do the configuration
    AWK_STRING='
        # append restricted, universe and multiverse to all sources
        $0 ~ /^deb.+main$/ {
          print "# [EDIT]: ",$0
          $0 = $0" restricted universe multiverse"
        }

        { print $0 }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function config_source_list_add_multiverse_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for sources.list."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/apt/sources.list"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}



#***************************[apt-cacher-ng]***********************************

# 2023 09 23
function config_source_list_aptcacher_check() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<verbosity>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]verbosity-level"
        echo "         \"\"         same as normal (default)"
        echo "         \"quiet\"    print only errors"
        echo "         \"normal\"   print header and result(s)"
        echo "         \"verbose\"  print also recommandations"
        echo "This function checks if config_source_list_aptcacher_unset"
        echo "needs to be called."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_verb="$1"
    if [ "$param_verb" == "" ]; then
        param_verb="normal"
    fi
    if [ "$param_verb" == "quiet" ]; then
        param_verb=0
    elif [ "$param_verb" == "normal" ]; then
        param_verb=1
    elif [ "$param_verb" == "verbose" ]; then
        param_verb=2
    else
        echo "$FUNCNAME: Parameter Error for <verbosity>."
        $FUNCNAME --help
        return -1
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # initial output
    if [ $param_verb -eq 1 ]; then
        echo -n "apt sources       ... "
    fi

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    # find all entries within config path
    readarray -t filelist <<< "$(ls "$PATH_CONFIG" 2>> /dev/null | \
      grep -v -e ".save\$" )"
        # check result
        if [ $? -ne 0 ]; then
            if [ $param_verb -eq 2 ]; then
                echo "$FUNCNAME: error reading source files"
            else
                echo ""
                echo -n "  error reading source files"
                if [ $param_verb -ge 1 ]; then
                    echo ""
                fi
            fi
            return -2;
        fi

    # prepand path to all files
    for i in ${!filelist[@]}; do
        filelist[$i]="${PATH_CONFIG}${filelist[$i]}"
    done
    # add basic file
    filelist+=("$FILENAME_CONFIG")

    error_flag=0
    # iterate over all files
    if [ $param_verb -ge 2 ]; then
        echo ""
    fi
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "" ] || [ ! -f "${filelist[$i]}" ]; then
            continue;
        fi

        if [ $param_verb -ge 2 ]; then
            echo "checking file ${filelist[$i]}"
        fi

        # check if port is set
        temp="$(cat "${filelist[$i]}" | grep --extended-regexp "^deb" | \
        grep ":3142")"

        if [ "$temp" != "" ]; then
            if [ $param_verb -ge 2 ]; then
                echo "  $FUNCNAME: sources in \"${filelist[$i]}\" can be updated"
                echo "  run $ config_source_list_aptcacher_unset"
                return
            else
                echo ""
                echo -n "  update \"${filelist[$i]}\""
            fi
            error_flag=1
        fi
    done

    if [ "$error_flag" -eq 1 ]; then
        if [ $param_verb -ge 1 ]; then
            echo ""
            echo "  --> config_source_list_aptcacher_unset"
        fi
        return -3
    else
        if [ $param_verb -ge 1 ]; then
            echo "ok"
        fi
    fi
}

# 2020 12 31
function config_source_list_aptcacher_unset() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "changes all source-list files to NOT use the apt-cacher-ng server."

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    AWK_STRING='
        # update url of repositories
        $0 ~ /^deb/ && $0 ~ /:3142/ {
          sub( /\S+:3142\// , "http://" )

          # check for HTTPS
          sub( /http:\/\/HTTPS\/\/\// , "https://" )
        }

        { print $0 }
    '

    # find all entries within config path
    readarray -t filelist <<< "$(ls "$PATH_CONFIG" 2>> /dev/null | \
      grep -v -e ".save\$" )"
        # check result
        if [ $? -ne 0 ]; then return -2; fi
    # prepand path to all files
    for i in ${!filelist[@]}; do
        filelist[$i]="${PATH_CONFIG}${filelist[$i]}"
    done
    # add basic file
    filelist+=("$FILENAME_CONFIG")

    # iterate over all files
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "" ] || [ ! -f "${filelist[$i]}" ]; then
            continue;
        fi
        echo "reverting file ${filelist[$i]}"

        # do the configuration
        _config_file_modify_full "${filelist[$i]}" "apt_cacher" \
          "$AWK_STRING" "normal" ""
        if [ $? -ne 0 ]; then return -3; fi
        echo ""
    done
}
