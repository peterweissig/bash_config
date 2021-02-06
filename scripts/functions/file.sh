#!/bin/bash

#***************************[backup config files]*****************************
# 2021 01 01
function config_file_backup() {
    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<subdir>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]additional subdirectory for storing backup"
        echo "This function stores an backup of the given config file."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_filename="$1"
    param_subdir="$2"

    config_path_backup="$CONFIG_PATH_BACKUP"
    if [ "$config_path_backup" != "" ] && \
      [ "${config_path_backup: -1}" != "/" ]; then
        config_path_backup="${config_path_backup}/"
    fi
    if [ "$param_subdir" != "" ]; then
        config_path_backup="${config_path_backup}${param_subdir}"
        if [ "$config_path_backup" != "" ] && \
          [ "${config_path_backup: -1}" != "/" ]; then
            config_path_backup="${config_path_backup}/"
        fi
    fi


    # call the general modification function
    _file_backup_base "$param_filename" "$config_path_backup" \
      "suffix" "--yes" "sudo"
}



#***************************[modify config files]*****************************
# 2021 02 06
function _config_file_modify() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<script>] [<flag>] [<header>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-4 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]a valid awk script"
        echo "         if not set (\"\"), the editor nano will be executed"
        echo "    [#3:]flag"
        echo "         \"normal\"        ... normal operation (default)"
        echo "         \"backup-once\"   ... fails if backup already exists"
        echo "         \"create-config\" ... fails if file already exists"
        echo "         \"auto\"          ... automatically switches between"
        echo "                               normal and create-config"
        echo "    [#4:]additional header (default date and username)"
        echo "         if set to \"default\", will create default header"
        echo "         if set empty (\"\"), no header will be added"
        echo "This function modifies the given config file - "
        echo "either by running the given awk script or by executing nano."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 4 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_filename="$1"
    #param_script="$2"
    param_flag="$3"
    #param_header="$4"

    if [ $# -gt 2 ]; then
        if [ "$param_flag" != "backup-once" ] && \
          [ "$param_flag" != "create-config" ] && \
          [ "$param_flag" != "auto" ] && \
          [ "$param_flag" != "normal" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # call full version of modification script
    shift
    _config_file_modify_full "$param_filename" "" "$@"

}

# 2021 02 06
function _config_file_modify_full() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <filename> [<subdir>] [<script>] [<flag>] "
        echo "[<header>] [<copy-with-sudo>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-6 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]additional subdirectory for storing backup"
        echo "    [#3:]a valid awk script"
        echo "         if not set (\"\"), the editor nano will be executed"
        echo "    [#4:]flag"
        echo "         \"normal\"        ... normal operation (default)"
        echo "         \"backup-once\"   ... fails if backup already exists"
        echo "         \"create-config\" ... fails if file already exists"
        echo "         \"auto\"          ... automatically switches between"
        echo "                               normal and create-config"
        echo "    [#5:]additional header (default date and username)"
        echo "         if set to \"default\", will create default header"
        echo "         if set empty (\"\"), no header will be added"
        echo "    [#6:]using sudo to read and copy file"
        echo "         (must be \"sudo\" to be in effect)"
        echo "This function modifies the given config file - "
        echo "either by running the given awk script or by executing nano."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 6 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for other repos
    if [ "$SOURCED_BASH_FILE" == "" ]; then
        echo -n "$FUNCNAME: Can't find file-functions. Did you call "
        echo "git_clone_bash_file ?"
        return -1
    fi

    # init variables
    param_filename="$1"
    param_subdir="$2"
    param_script="$3"
    param_flag="$4"
    param_header="$5"
    param_sudo="$6"

    config_path_backup="$CONFIG_PATH_BACKUP"
    if [ "$config_path_backup" != "" ] && \
      [ "${config_path_backup: -1}" != "/" ]; then
        config_path_backup="${config_path_backup}/"
    fi
    config_path_backup="${config_path_backup}${param_subdir}"
    if [ "$config_path_backup" != "" ] && \
      [ "${config_path_backup: -1}" != "/" ]; then
        config_path_backup="${config_path_backup}/"
    fi

    if [ "$param_sudo" != "" ] && [ "$param_sudo" != "sudo" ]; then
        echo "$FUNCNAME: copy-with-sudo must be \"\" (empty) or sudo."
        echo "  (not \"$param_sudo\")"
        return -1
    fi

    flag_backup_once="0"
    flag_create_config="0"
    if [ $# -gt 3 ]; then
        if [ "$param_flag" == "backup-once" ]; then
            flag_backup_once="1"
        elif [ "$param_flag" == "create-config" ]; then
            flag_create_config="1"
        elif [ "$param_flag" == "auto" ]; then
            if [ ! -e "$param_filename" ]; then
                if [ "$param_sudo" != "sudo" ] ||
                  sudo [ ! -e "$param_filename" ]; then
                    flag_create_config="1"
                fi
            fi
        elif [ "$param_flag" != "normal" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # simplify config-file name
    filepath="$(dirname  "$param_filename")"
    filebase="$(basename "$param_filename")"
    filebase_simple="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then return -2; fi

    # check for already existing backup
    if [ "$flag_backup_once" -ne 0 ]; then
        find_result="$(find "$config_path_backup" -regextype sed \
          -regex ".*/[0-9_]*${filebase_simple}[0-9_]*" -print -quit)"
        if [ $? -ne 0 ]; then return -3; fi

        if [ "$(echo "$find_result" | wc -w)" != 0 ]; then
            echo -n "$FUNCNAME: backup for file ($param_filename) "
            echo "already exists!"
            echo "  $find_result"
            return -4
        fi
    fi

    # create a backup before the operation
    if [ "$flag_create_config" -eq 0 ]; then
        #// check file and create a backup before applying awk-script
        _file_backup_base "$param_filename" "$config_path_backup" \
          "suffix" "--yes" "$param_sudo"
        if [ $? -ne 0 ]; then return -5; fi
    else
        if [ -e "$param_filename" ]; then
            echo "File \"$param_filename\" already exists!"
            return -6
        fi
    fi

    #// manipulate file, create temp-file and check for changes
    temp_file="${CONFIG_PATH_BACKUP}${filebase_simple}_temp"

    if [ "$flag_create_config" -eq 0 ]; then
        if [ "$param_script" == "" ]; then
            if [ "$param_sudo" != "sudo" ]; then
                cp "$param_filename" "$temp_file"
            else
                sudo cp "$param_filename" "$temp_file"
                sudo chown "$USER" "$temp_file"
            fi
            nano "$temp_file"
        else
            if [ "$param_sudo" != "sudo" ]; then
                cat "$param_filename" | awk "$param_script" > "$temp_file"
            else
                sudo cat "$param_filename" | \
                  awk "$param_script" > "$temp_file"
            fi
        fi
        if [ $? -ne 0 ]; then return -7; fi

        #// check if file was changed
        if [ "$param_sudo" != "sudo" ]; then
            temp="$(diff --brief "$temp_file" "$param_filename")"
        else
            temp="$(sudo diff --brief "$temp_file" "$param_filename")"
        fi
        if [ "$temp" == "" ]; then
            echo "File \"$param_filename\" not changed!"
            rm "$temp_file"

            if [ "$flag_create_config" -eq 0 ]; then
                filename_last="$(_config_file_return_last \
                  "$param_filename" "$config_path_backup")";
                if [ -e "$filename_last" ]; then
                    echo "rm \"$filename_last\""
                    rm "$filename_last"
                fi
            fi
            return
        fi
    else
        echo "" | awk "$param_script" > "$temp_file"
        if [ $? -ne 0 ]; then return -8; fi
    fi

    #// create header
    if [ $# -lt 5 ] || [ "$param_header" == "default" ]; then
        if [ "$param_sudo" != "sudo" ]; then
            filename_full="$(realpath "$param_filename")"
        else
            filename_full="$(sudo realpath "$param_filename")"
        fi
        header="$(
            echo "# $(date): $USER edited \"${filename_full}\""
            echo "#"
        )"
    else
        header="$param_header"
    fi

    #// check file owner
    if [ "$flag_create_config" -eq 0 ]; then
        temp_dir_or_file="$param_filename"
    else
        temp_dir_or_file="$filepath"
    fi

    #// copy file back to original position and remove temp file
    if [ "$param_sudo" == "sudo" ] || \
      [ "$(stat -c '%U' "$temp_dir_or_file")" == "root" ]; then
        (
            if [ "$header" != "" ]; then
                echo "$header"
            fi
            cat "$temp_file"
        ) | sudo tee "$param_filename" > "/dev/null"
    else
        (
            if [ "$header" != "" ]; then
                echo "$header"
            fi
            cat "$temp_file"
        ) > "$param_filename"
    fi
    if [ $? -ne 0 ]; then return -9; fi
    rm "$temp_file"
    if [ $? -ne 0 ]; then return -10; fi

    #// create a backup after the operation
    _file_backup_base "$param_filename" "$config_path_backup" \
      "suffix" "--yes" "$param_sudo"
    if [ $? -ne 0 ]; then return -11; fi
}

# 2020 01 26
function _config_file_restore() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]flag"
        echo "         \"normal\"        ... fails if there are not at least"
        echo "                               two backups (default)"
        echo "         \"backup-once\"   ... fails if there are not exactly"
        echo "                               two backups (before and after)"
        echo "         \"create-config\" ... fails if there are not exactly"
        echo "                               one backup (only after)"
        echo "         \"auto\"          ... fails if there are not at least"
        echo "                               one backup"
        echo "This function restores the formerly modified config file."
        echo "The related backup-files will be removed!"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_filename="$1"
    param_flag="$2"

    if [ $# -gt 2 ]; then
        if [ "$param_flag" != "backup-once" ] && \
          [ "$param_flag" != "create-config" ] && \
          [ "$param_flag" != "auto" ] && \
          [ "$param_flag" != "normal" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # call full version of restore script
    shift
    _config_file_restore_full "$param_filename" "" "$@"

}

# 2021 02 06
function _config_file_restore_full() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<subdir>] [<flag>] [<copy-with-sudo>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-4 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]additional subdirectory for storing backup"
        echo "    [#3:]flag"
        echo "         \"normal\"        ... fails if there are not at least"
        echo "                               two backups (default)"
        echo "         \"backup-once\"   ... fails if there are not exactly"
        echo "                               two backups (before and after)"
        echo "         \"create-config\" ... fails if there are not exactly"
        echo "                               one backup (only after)"
        echo "         \"auto\"          ... fails if there are not at least"
        echo "                               one backup"
        echo "    [#4:]using sudo to compare and copy file"
        echo "         (must be \"sudo\" to be in effect)"
        echo "This function restores the formerly modified config file."
        echo "The related backup-files will be removed!"

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 4 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for other repos
    if [ "$SOURCED_BASH_FILE" == "" ]; then
        echo -n "$FUNCNAME: Can't find file-functions. Did you call "
        echo "git_clone_bash_file ?"
        return -1
    fi

    # init variables
    param_filename="$1"
    param_subdir="$2"
    param_flag="$3"
    param_sudo="$4"

    flag_backup_once="0"
    flag_create_config="0"
    flag_auto_config="0"
    if [ $# -gt 2 ]; then
        if [ "$param_flag" == "backup-once" ]; then
            flag_backup_once="1"
        elif [ "$param_flag" == "create-config" ]; then
            flag_create_config="1"
        elif [ "$param_flag" == "auto" ]; then
            flag_auto_config="1"
        elif [ "$param_flag" != "normal" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi
    if [ "$param_sudo" != "" ] && [ "$param_sudo" != "sudo" ]; then
        echo "$FUNCNAME: copy-with-sudo must be \"\" (empty) or sudo."
        echo "  (not \"$param_sudo\")"
        return -1
    fi

    config_path_backup="$CONFIG_PATH_BACKUP"
    if [ "$config_path_backup" != "" ] && \
      [ "${config_path_backup: -1}" != "/" ]; then
        config_path_backup="${config_path_backup}/"
    fi
    config_path_backup="${config_path_backup}${param_subdir}"
    if [ "$config_path_backup" != "" ] && \
      [ "${config_path_backup: -1}" != "/" ]; then
        config_path_backup="${config_path_backup}/"
    fi

    # simplify config-file name
    filepath="$(dirname  "$param_filename")"
    filebase="$(basename "$param_filename")"
    filebase_simple="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then return -2; fi

    # check for already existing backups
    find_result="$(find "$config_path_backup" -regextype sed \
      -regex ".*/[0-9_]*${filebase_simple}[0-9_]*")"
    if [ $? -ne 0 ]; then return -3; fi

    count_result="$(echo "$find_result" | wc -l)"
    if [ "$find_result" == "" ] || [ "$count_result" -eq 0 ]; then
        echo "$FUNCNAME: no backup for file ($param_filename)!"
        return -4
    fi

    # check for auto config
    if [ "$flag_auto_config" -ne 0 ]; then
        if [ "$count_result" -eq 1 ]; then
            flag_create_config="1"
        fi
        if [ "$count_result" -eq 2 ]; then
            flag_backup_once="1"
        fi
    fi

    # test number of needed backups
    if [ "$flag_create_config" -ne 0 ]; then
        if [ "$count_result" -ne 1 ]; then
            echo "$FUNCNAME: there must be exactly one backup for file"
            echo "  $param_filename"
            return -5
        fi

    else
        if [ "$flag_backup_once" -ne 0 ]; then
            if [ "$count_result" -ne 2 ]; then
                echo "$FUNCNAME: there must be exactly two backups for file"
                echo "  $param_filename"
                return -5
            fi
        else
            if [ "$count_result" -lt 2 ]; then
                echo "$FUNCNAME: there must be at least two backups for file"
                echo "  $param_filename"
                return -5
            fi
        fi
    fi

    # find last file
    filename_last="$(_config_file_return_last \
      "$param_filename" "$config_path_backup")";
    if [ $? -ne 0 ]; then return -6; fi
    if [ ! -e "$filename_last" ]; then
        return -6
    fi

    # check last config

    if [ "$param_sudo" != "sudo" ]; then
        changes="$(diff --brief "$filename_last" "$param_filename")"
    else
        changes="$(sudo diff --brief "$filename_last" "$param_filename")"
    fi
    if [ "$changes" != "" ]; then
        unset changes
        echo "File \"$param_filename\" has been changed!"
        echo "  (it is NOT identical to \"$filename_last\")"

        return -7
    fi

    # remove last config
    echo "rm \"$filename_last\""
    rm "$filename_last"

    # test for flags
    if [ "$flag_create_config" -eq 0 ]; then

        # get second last file
        filename_last="$(_config_file_return_last \
          "$param_filename" "$config_path_backup")";
        if [ $? -ne 0 ]; then return -7; fi
        if [ ! -e "$filename_last" ]; then
            return -8
        fi

        #// move file back to original position
        if [ "$param_sudo" == "sudo" ] ||
          [ "$(stat -c '%U' "$param_filename")" == "root" ]; then
            echo "sudo mv \"$filename_last\" \"$param_filename\""
            sudo mv "$filename_last" "$param_filename"
            sudo chown root:root "$param_filename"
        else
            echo "mv \"$filename_last\" \"$param_filename\""
            mv "$filename_last" "$param_filename"
        fi
    else
        #// remove original file
        if [ "$param_sudo" == "sudo" ] ||
          [ "$(stat -c '%U' "$param_filename")" == "root" ]; then
            echo "sudo rm \"$param_filename\""
            sudo rm "$param_filename"
        else
            echo "rm \"$param_filename\""
            rm "$param_filename"
        fi
    fi
}

# 2020 01 26
function _config_file_return_last() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<backup-path>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]backup-path (defaults to CONFIG_PATH_BACKUP)"
        echo "This function returns the path/name of the last stored"
        echo "version of the given file."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for other repos
    if [ "$SOURCED_BASH_FILE" == "" ]; then
        echo -n "$FUNCNAME: Can't find file-functions. Did you call "
        echo "git_clone_bash_file ?"
        return -1
    fi

    # init variables
    param_filename="$1"
    param_backup_path="$2"

    if [ "$param_backup_path" == "" ]; then
        param_backup_path="$CONFIG_PATH_BACKUP"
    fi

    # simplify config-file name
    filepath="$(dirname  "$param_filename")"
    filebase="$(basename "$param_filename")"
    filebase_simple="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then return -2; fi

    # check for existing backup
    find_result="$(find "$param_backup_path" -regextype sed \
      -regex ".*/[0-9_]*${filebase_simple}[0-9_]*")"
    if [ $? -ne 0 ]; then return -3; fi

    if [ "$(echo "$find_result" | wc -w)" == 0 ]; then
        return
    fi

    # return result
    echo "$find_result" | sort | tail --lines=1
}
