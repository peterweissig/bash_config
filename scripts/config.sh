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



#***************************[nano]********************************************
# 2020 12 31

alias config_nano="nano_config"
function nano_config() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [--no-header] [--sudo] <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 2 options and needs 1 parameter"
        echo "    [--no-header] avoids adding header info"
        echo "    [--sudo]      uses always sudo to access the file"
        echo "     #1: full path of original file"
        echo "This function executes nano to modify the given config file."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # init variables
    option_no_header=0
    option_sudo=0
    param_file=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 3 ]; then
        params_ok=1
        param_file="${@: -1}"
        if [ $# -ge 2 ]; then
            if [ "$1" == "--no-header" ]; then
                option_no_header=1
            elif [ "$1" == "--sudo" ]; then
                option_sudo=1
            else
                params_ok=0
            fi
        fi
        if [ $# -ge 3 ]; then
            if [ "$2" == "--no-header" ]; then
                option_no_header=1
            elif [ "$2" == "--sudo" ]; then
                option_sudo=1
            else
                params_ok=0
            fi
        fi
    fi
    if [ $params_ok -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the modification function
    if [ $option_sudo -eq 1 ]; then
        if [ $option_no_header -eq 1 ]; then
            # sudo and no header
            _config_file_modify_full "$param_file" "" "" "auto" "" "sudo"
        else
            # sudo
            _config_file_modify_full "$param_file" "" "" "auto" \
              "default" "sudo"
        fi
    else
        if [ $option_no_header -eq 1 ]; then
            # no header
            _config_file_modify "$param_file" "" "auto" ""
        else
            # simple version
            _config_file_modify "$param_file"
        fi
    fi
}

alias config_nano_restore="nano_config_restore"
function nano_config_restore() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: full path of original file"
        echo "This function restores the formerly modified config file."
        echo "The related backup-files will be removed!"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the general modification function
    _config_file_restore "$1"
}



#***************************[inputrc]*****************************************
# 2019 11 20

function config_bash_search() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "enables searching through the bash-history using" \
      "page-up/page-down keys."
    if [ $? -ne 0 ]; then return -1; fi

    # do the configuration
    FILENAME_CONFIG="/etc/inputrc"

    AWK_STRING='
        # backward search
        $0 ~ /^# "\\e\[5~": history-search-backward/ {
          print "# [EDIT]: ",$0
          $0 = "\"\\e[5~\": history-search-backward"
        }
        # forward search
        $0 ~ /^# "\\e\[6~": history-search-forward/ {
          print "# [EDIT]: ",$0
          $0 = "\"\\e[6~\": history-search-forward"
        }

        { print $0 }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function config_bash_search_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for searching through the bash-history."
    if [ $? -ne 0 ]; then return -1; fi

    # undo the configuration
    FILENAME_CONFIG="/etc/inputrc"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}

# 2019 12 10

function config_bash_search_local() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "enables searching through the bash-history using" \
      "page-up/page-down keys."
    if [ $? -ne 0 ]; then return -1; fi

    # do the configuration
    FILENAME_CONFIG=~/".inputrc"

    AWK_STRING='
        # init variables
        BEGIN {
            found_backward=0
            found_forward=0
        }

        # check for existing entries
        $0 ~ /^"\\e\[5~": history-search-backward/ {
          found_backward=1
        }
        $0 ~ /^"\\e\[6~": history-search-forward/ {
          found_forward=1
        }

        { print $0 }

        # add config (if necessary)
        END {
            if (found_backward == 0) {
                print "\"\\e[5~\": history-search-backward"
            }
            if (found_forward == 0) {
                print "\"\\e[6~\": history-search-forward"
            }
        }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "auto"
}

function config_bash_search_local_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for searching through the bash-history."
    if [ $? -ne 0 ]; then return -1; fi

    # undo the configuration
    FILENAME_CONFIG=~/".inputrc"

    _config_file_restore "$FILENAME_CONFIG" "auto"
}



#***************************[history size]************************************
# 2020 12 26

function config_bash_histsize() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "increase length of bash-history."
    if [ $? -ne 0 ]; then return -1; fi

    # do the configuration
    FILENAME_CONFIG=~/".bashrc"

    # constants
    HISTSIZE_NEW=5000
    HISTFILESIZE_NEW=20000

    # setuo awk strings
    AWK_STRING1="
        # set HISTSIZE from $HISTSIZE to $HISTSIZE_NEW
        \$0 ~ /^HISTSIZE=/ {
          print \"# [EDIT]: \",\$0
          \$0 = \"HISTSIZE=$HISTSIZE_NEW\"
        }
    "
    AWK_STRING2="
        # set HISTFILESIZE from $HISTFILESIZE to $HISTFILESIZE_NEW
        \$0 ~ /^HISTFILESIZE=/ {
          print \"# [EDIT]: \",\$0
          \$0 = \"HISTFILESIZE=$HISTFILESIZE_NEW\"
        }
    "
    AWK_STRING3="
        { print \$0 }
    "


    # check hist size
    if [ "$HISTSIZE" != "" ] && [ "$HISTSIZE" -ge "$HISTSIZE_NEW" ]; then
        echo "\$HISTSIZE=$HISTSIZE ... ok"
        AWK_STRING1=""
    else
        echo "\$HISTSIZE=$HISTSIZE_NEW # instead of $HISTSIZE"
    fi

    # check hist-file-size
    if [ "$HISTFILESIZE" != "" ] && \
      [ "$HISTFILESIZE" -ge "$HISTFILESIZE_NEW" ]; then
        echo "\$HISTFILESIZE=$HISTFILESIZE ... ok"
        AWK_STRING2=""
    else
        echo "\$HISTFILESIZE=$HISTFILESIZE_NEW # instead of $HISTFILESIZE"
    fi


    AWK_STRING="${AWK_STRING1}${AWK_STRING2}"

    if [ "$AWK_STRING1" != "" ] || [ "$AWK_STRING2" != "" ]; then
        AWK_STRING="${AWK_STRING1}${AWK_STRING2}${AWK_STRING3}"
        _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "auto"
    fi
}

function config_bash_histsize_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old size of bash-history."
    if [ $? -ne 0 ]; then return -1; fi

    # undo the configuration
    FILENAME_CONFIG=~/".bashrc"

    _config_file_restore "$FILENAME_CONFIG" "auto"
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



#***************************[aptcacher]***************************************

# 2020 12 30
function config_source_list_aptcacher_set() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <ip-address>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: ip-address of apt-cacher-ng server"
        echo "This function changes all source-list files to use the"
        echo "apt-cacher server. If a server is already set, the source will"
        echo "not be changed, even if the ip-address is not matching."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    ipaddr="$1"
    if [ "$ipaddr" != "localhost" ] && \
      ! [[ "$ipaddr" =~ ((([0-9]{1,3})\.){3})([0-9]{1,3}) ]]; then

        echo "$FUNCNAME: ip-address ($ipaddr) is not valid."
        return -2
    fi

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    AWK_STRING="
        # update url of repositories
        \$0 ~ /^deb/ && \$0 !~ /:3142/ {
          sub( /http:\/\// , \"&${ipaddr}:3142/\" )
        }

        { print \$0 }
    "

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
        echo "modifying file ${filelist[$i]}"

        # do the configuration
        _config_file_modify_full "${filelist[$i]}" "apt_cacher" \
          "$AWK_STRING" "normal" ""
        if [ $? -ne 0 ]; then return -3; fi
        echo ""
    done
}

# 2020 12 30
function config_source_list_aptcacher_check() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameter"
        echo "This function checks if config_source_list_aptcacher_set"
        echo "needs to be called."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

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
        echo "checking file ${filelist[$i]}"

        # check if already set
        temp="$(cat "${filelist[$i]}" | grep --extended-regexp "^deb" | \
        grep --extended-regexp -v ":[0-9]+")"

        # check for https
        if [ "$(echo "$temp" | grep "https" | wc -w)" -gt 0 ]; then
            echo "  ... can't handle https deb"
        fi

        if [ "$(echo "$temp" | grep -v "https" | wc -w)" -gt 0 ]; then
            echo ""
            echo "$FUNCNAME: sources in \"${filelist[$i]}\" can be updated"
            echo "call \$ config_source_list_aptcacher_set"
            return
        fi
    done

    echo "nothing to do :-)"
}

# 2020 12 30
function config_source_list_aptcacher_unset() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "changes all source-list files to NOT use the apt-cacher server."

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    AWK_STRING='
        # update url of repositories
        $0 ~ /^deb/ && $0 ~ /:3142/ {
          sub( /\S+:3142\// , "http://" )
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
