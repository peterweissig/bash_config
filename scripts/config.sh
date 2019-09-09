#***************************[inputrc]*****************************************
# 2019 09 08

function config_update_system() {

    echo "1. sudo apt-get update"
    sudo apt-get update
    if [ $? -ne 0 ]; then return -1; fi

    echo ""
    echo "2. sudo apt-get upgrade --assume-yes"
    sudo apt-get upgrade --assume-yes
    if [ $? -ne 0 ]; then return -2; fi

    echo ""
    echo "3. sudo apt-get dist-upgrade --assume-yes"
    sudo apt-get dist-upgrade --assume-yes
    if [ $? -ne 0 ]; then return -3; fi

    echo ""
    echo "4. sudo apt-get autoremove --assume-yes"
    sudo apt-get autoremove --assume-yes
    if [ $? -ne 0 ]; then return -4; fi

    echo ""
    echo "done :-)"
}

#***************************[inputrc]*****************************************
# 2019 09 08

function config_bash_search() {

    FILENAME_CONFIG="/etc/inputrc"

    AWK_STRING='
        # backward search
        $0 ~ /^# "\\e\[5~": history-search-backward/ {
          print "# [COMMENT]: ",$0
          $0 = "\"\\e[5~\": history-search-backward"
        }
        # forward search
        $0 ~ /^# "\\e\[6~": history-search-forward/ {
          print "# [COMMENT]:",$0
          $0 = "\"\\e[6~\": history-search-forward"
        }

        { print $0 }
    '

    _config_file_modify_awk "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

#function config_bash_search_restore() {
#
#    FILENAME_CONFIG="/etc/inputrc"
#
#    _config_file_restore "$FILENAME_CONFIG"
#}

