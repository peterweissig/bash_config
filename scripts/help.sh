#!/bin/bash

#***************************[all]*********************************************
# 2020 10 06

function config_help_all() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "Prints all available functions within repository \"config\"."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print overview of all repositories
    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help"
    echo -n "  "; echo "config_help  #no help"
    echo -n "  "; $FUNCNAME -h
    echo -n "  "; _config_simple_parameter_check -h
    echo ""
    echo "info"
    echo -n "  "; config_info -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo -n "  "; config_install_nextcloud -h
    echo -n "  "; config_install_vscode -h
    echo -n "  "; _config_install_list -h
    echo ""
    echo "general config functions"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; config_file_backup -h
    echo -n "  "; _config_file_modify -h
    echo -n "  "; _config_file_restore -h
    echo -n "  "; _config_file_return_last -h
    echo ""
    echo "setup system"
    echo -n "  "; echo "config_bash_search(_restore)"
    echo -n "  "; echo "config_sources_add_multiverse(_restore)"
    echo -n "  "; config_sources_aptcacher_set -h
    echo -n "  "; config_sources_aptcacher_check -h
    echo -n "  "; config_sources_aptcacher_unset -h
    echo -n "  "; _config_check_sources -h
    echo ""
    echo "user config"
    echo -n "  "; echo "config_bash_search_local(_restore)"
    echo -n "  "; echo "config_users_hide_login(_restore)"
    echo -n "  "; config_clear_home -h
    echo ""
}

#***************************[help]********************************************
# 2020 10 06

function config_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME  #no help"
    echo -n "  "; config_help_all -h
    echo ""
    echo "info"
    echo -n "  "; config_info -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo -n "  "; config_install_nextcloud -h
    echo -n "  "; config_install_vscode -h
    echo ""
    echo "general config functions"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; config_file_backup -h
    echo ""
    echo "setup system"
    echo -n "  "; echo "config_bash_search(_restore)"
    echo -n "  "; echo "config_sources_add_multiverse(_restore)"
    echo -n "  "; echo "config_sources_aptcacher_(un)set"
    echo ""
    echo "user config"
    echo -n "  "; echo "config_bash_search_local(_restore)"
    echo -n "  "; echo "config_users_hide_login(_restore)"
    echo -n "  "; config_clear_home -h
    echo ""
}
