#!/bin/bash

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
