#***************************[inputrc]*****************************************
# 2019 09 08

function config_bash_search() {

    FILENAME_CONFIG="/etc/inputrc"

    AWK_STRING='
        # backward search
        $0 ~ /^# "\e\[5~": history-search-backward/ {
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

