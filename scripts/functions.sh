#***************************[modify config files]*****************************
# 2019 09 08

function _config_file_modify_awk() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> <awk-script> [<flag>] [<header>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2-4 parameters"
        echo "     #1: full path of original file"
        echo "     #2: awk script"
        echo "    [#3:]flag"
        echo "         \"normal\"        ... normal operation"
        echo "         \"backup-once\"   ... fails if backup already exists"
        echo "         \"create-config\" ... fails if file already exists"
        echo "    [#4:]additional header (default date and username)"
        echo "         if not set (\"\"), no header will be added"
        echo "This function runs the given awk script on the config file."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # check parameter
    if [ $# -lt 2 ] || [ $# -gt 4 ]; then
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
    flag_backup_once="0"
    flag_create_config="0"

    if [ $# -gt 2 ]; then
        if [ "$3" == "backup-once" ]; then
            flag_backup_once="1"
        elif [ "$3" == "create-config" ]; then
            flag_create_config="1"
        elif [ "$3" != "normal" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # simplify config-file name
    filename="$1"
    filepath="$(dirname  "$filename")"
    filebase="$(basename "$filename")"
    filebase_simple="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then return -2; fi

    # check for already existing backup
    if [ "$flag_backup_once" -ne 0 ]; then
        # check if
        find_result="$(find "$CONFIG_PATH_BACKUP" -regextype sed \
          -regex ".*/[0-9_]*${filebase_simple}[0-9_]*" -print -quit)"
        if [ $? -ne 0 ]; then return -3; fi

        if [ "$(echo "$find_result" | wc -w)" != 0 ]; then
            echo "$FUNCNAME: backup for file ($filename) already exists!"
            echo "  $find_result"
            return -4
        fi
    fi

    # create a backup before the operation
    if [ "$flag_create_config" -eq 0 ]; then
        #// check file and create a backup before applying awk-script
        _file_backup_base "$filename" "$CONFIG_PATH_BACKUP" "suffix" "--yes"
        if [ $? -ne 0 ]; then return -5; fi
    else
        if [ -e "$filename" ]; then
            echo "File \"$filename\" already exists!"
            return -6
        fi
    fi

    #// manipulate file, create temp-file and check for changes
    temp_file="${CONFIG_PATH_BACKUP}${filebase_simple}_temp"

    if [ "$flag_create_config" -eq 0 ]; then
        cat "$filename" | awk "$2" > "$temp_file"
        if [ $? -ne 0 ]; then return -7; fi

        #// check if file was changed
        if [ "$(diff --brief "$temp_file" "$filename")" == "" ]; then
            echo "File \"$filename\" not changed!"
            rm "$temp_file"
            return
        fi
    else
        awk "$2" > "$temp_file"
        if [ $? -ne 0 ]; then return -8; fi
    fi

    #// create header
    if [ $# -lt 4 ]; then
        header="$(
            echo "# $(date): $USER edited \"$filename\""
            echo "#"
        )"
    else
        header="$3"
    fi

    #// copy file back to original position and remove temp file
    if [ "$(stat -c '%U' "$1")" == "root" ]; then
        (
            echo "$header"
            cat "$temp_file"
        ) | sudo tee "$filename" > "/dev/null"
    else
        (
            echo "$header"
            cat "$temp_file"
        ) > "$filename"
    fi
    if [ $? -ne 0 ]; then return -9; fi
    rm "$temp_file"
    if [ $? -ne 0 ]; then return -10; fi

    #// create a backup after the operation
    _file_backup_base "$1" "$CONFIG_PATH_BACKUP" "suffix" "--yes"
    if [ $? -ne 0 ]; then return -11; fi
}
