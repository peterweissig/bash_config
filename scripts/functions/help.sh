#!/bin/bash

#***************************[all]*********************************************
# 2023 09 23

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
    echo -n "  "; config_check_service -h
    echo -n "  "; _config_check_sources -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo -n "  "; config_install_show -h
    echo -n "  "; config_install_nextcloud -h
    echo -n "  "; config_install_vscode -h
    echo -n "  "; config_install_ros -h
    echo -n "  "; _config_install_list -h
    echo -n "  "; _config_uninstall_list -h
    echo ""
    echo "file operations"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; config_bookmarks_edit -h
    echo -n "  "; config_bookmarks_restore -h
    echo -n "  "; config_file_backup -h
    echo -n "  "; _config_file_modify -h
    echo -n "  "; _config_file_restore -h
    echo -n "  "; _config_file_return_last -h
    echo ""
    echo "setup system"
    echo -n "  "; echo "config_bash_search(_restore)"
    echo -n "  "; echo "config_sudo_no_password(_restore)"
    echo -n "  "; echo "config_password_disable_rejection(_restore)"
    echo ""
    echo "apt"
    echo -n "  "; echo "config_source_list_add_multiverse(_restore)"
    echo -n "  "; config_source_list_aptcacher_unset -h
    echo -n "  "; config_source_list_aptcacher_check -h
    echo ""
    echo "cpu"
    echo -n "  "; config_cpu_freq_show -h
    echo -n "  "; config_cpu_temp_show -h
    echo -n "  "; config_cpu_mode_show -h
    echo -n "  "; config_cpu_mode_set -h
    echo ""
    echo "user config"
    echo -n "  "; echo "config_bash_histsize(_restore)"
    echo -n "  "; echo "config_bash_search_local(_restore)"
    echo -n "  "; echo "config_users_hide_login(_restore)"
    echo -n "  "; echo "config_users_show_logins(_restore)"
    echo -n "  "; config_clear_home -h
    echo ""
}

#***************************[help]********************************************
# 2023 09 23

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
    echo -n "  "; config_check_service -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo -n "  "; config_install_show -h
    echo -n "  "; config_install_nextcloud -h
    echo -n "  "; config_install_vscode -h
    echo -n "  "; config_install_ros -h
    echo ""
    echo "file operations"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; config_bookmarks_edit -h
    echo -n "  "; config_bookmarks_restore -h
    echo -n "  "; config_file_backup -h
    echo ""
    echo "setup system"
    echo -n "  "; echo "config_bash_search(_restore)"
    echo -n "  "; echo "config_sudo_no_password(_restore)"
    echo -n "  "; echo "config_password_disable_rejection(_restore)"
    echo ""
    echo "apt"
    echo -n "  "; echo "config_source_list_add_multiverse(_restore)"
    echo -n "  "; config_source_list_aptcacher_unset -h
    echo -n "  "; config_source_list_aptcacher_check -h
    echo ""
    echo "cpu"
    echo -n "  "; config_cpu_freq_show -h
    echo -n "  "; config_cpu_temp_show -h
    echo -n "  "; config_cpu_mode_show -h
    echo ""
    echo "user config"
    echo -n "  "; echo "config_bash_histsize(_restore)"
    echo -n "  "; echo "config_bash_search_local(_restore)"
    echo -n "  "; echo "config_users_hide_login(_restore)"
    echo -n "  "; echo "config_users_show_logins(_restore)"
    echo -n "  "; config_clear_home -h
    echo ""
}
