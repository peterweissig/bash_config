#!/bin/bash

#***************************[modify config files]*****************************
# 2019 09 09

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
        echo "    [#4:]additional header (default date and username)"
        echo "         if not set (\"\"), no header will be added"
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
        if [ "$2" == "" ]; then
            cp "$filename" "$temp_file"
            nano "$temp_file"
        else
            cat "$filename" | awk "$2" > "$temp_file"
        fi
        if [ $? -ne 0 ]; then return -7; fi

        #// check if file was changed
        if [ "$(diff --brief "$temp_file" "$filename")" == "" ]; then
            echo "File \"$filename\" not changed!"
            rm "$temp_file"

            if [ "$flag_create_config" -eq 0 ]; then
                filename_last="$(_config_file_return_last "$filename")";
                if [ -e "$filename_last" ]; then
                    echo "rm \"$filename_last\""
                    rm "$filename_last"
                fi
            fi
            return
        fi
    else
        awk "$2" > "$temp_file"
        if [ $? -ne 0 ]; then return -8; fi
    fi

    #// create header
    if [ $# -lt 4 ]; then
        header="$(
            echo "# $(date): $USER edited \"$(realpath "$filename")\""
            echo "#"
        )"
    else
        header="$3"
    fi

    #// copy file back to original position and remove temp file
    if [ "$(stat -c '%U' "$filename")" == "root" ]; then
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
    _file_backup_base "$filename" "$CONFIG_PATH_BACKUP" "suffix" "--yes"
    if [ $? -ne 0 ]; then return -11; fi
}

# 2019 09 09
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

    # check for already existing backups
    find_result="$(find "$CONFIG_PATH_BACKUP" -regextype sed \
      -regex ".*/[0-9_]*${filebase_simple}[0-9_]*")"
    if [ $? -ne 0 ]; then return -3; fi

    if [ "$(echo "$find_result" | wc -w)" -eq 0 ]; then
        echo "$FUNCNAME: no backup for file ($filename)!"
        return -4
    fi

    # test for flags
    if [ "$flag_create_config" -ne 0 ]; then
        if [ "$(echo "$find_result" | wc -l)" -ne 1 ]; then
            echo "$FUNCNAME: there must be exactly one backup for file"
            echo "  $filename"
            return -5
        fi

    else
        if [ "$flag_backup_once" -ne 0 ]; then
            if [ "$(echo "$find_result" | wc -l)" -ne 2 ]; then
                echo "$FUNCNAME: there must be exactly two backups for file"
                echo "  $filename"
                return -5
            fi
        else
            if [ "$(echo "$find_result" | wc -l)" -lt 2 ]; then
                echo "$FUNCNAME: there must be at least two backups for file"
                echo "  $filename"
                return -5
            fi
        fi

        # removed last file
        filename_last="$(_config_file_return_last "$filename")";
        if [ $? -ne 0 ]; then return -6; fi
        if [ ! -e "$filename_last" ]; then
            return -6
        fi
        echo "rm \"$filename_last\""
        rm "$filename_last"
    fi

    # get last file
    filename_last="$(_config_file_return_last "$filename")";
    if [ $? -ne 0 ]; then return -7; fi
    if [ ! -e "$filename_last" ]; then
        return -7
    fi

    #// move file back to original position
    if [ "$(stat -c '%U' "$filename")" == "root" ]; then
        echo "sudo mv \"$filename_last\" \"$filename\""
        sudo mv "$filename_last" "$filename"
    else
        echo "mv \"$filename_last\" \"$filename\""
        mv "$filename_last" "$filename"
    fi
}

# 2019 09 08
function _config_file_return_last() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: full path of original file"
        echo "This function returns the path/name of the last stored"
        echo "version of the given file."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
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

    # simplify config-file name
    filename="$1"
    filepath="$(dirname  "$filename")"
    filebase="$(basename "$filename")"
    filebase_simple="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then return -2; fi

    # check for existing backup
    find_result="$(find "$CONFIG_PATH_BACKUP" -regextype sed \
      -regex ".*/[0-9_]*${filebase_simple}[0-9_]*")"
    if [ $? -ne 0 ]; then return -3; fi

    if [ "$(echo "$find_result" | wc -w)" == 0 ]; then
        return
    fi

    # return result
    echo "$find_result" | sort | tail --lines=1
}


#***************************[installation]************************************
# 2019 09 10

function _config_install_list() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <package-list> [<verbosity>] [<auto-answer>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: list of all packages (white-space seperated)"
        echo "    [#2:]verbosity flag"
        echo "         \"\" print also installed packages (default)"
        echo "         \"quiet\" less verbose output"
        echo "    [#3:]using auto-answer for installing packages"
        echo "         (must be -y or --yes)"
        echo "This function checks all given packages and asks for"
        echo "permission to install the missing ones."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    verbose="1"
    auto_answer=""
    answer=""

    if [ $# -gt 1 ]; then
        if [ "$2" == "quiet" ]; then
            verbose="0"
        elif [ "$2" != "" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    if [ $# -gt 2 ]; then
        if [ "$3" == "-y" ] || [ "$3" == "--yes" ]; then
            auto_answer="--assume-yes"
        elif [ "$3" != "" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # iterate over all packages
    for package in $1; do
        # check current state of package
        package_info="$(dpkg-query --show --showformat='${db:Status-Abbrev}' \
          "$package" 2> /dev/null)"

        if [ "${package_info:0:2}" == "ii" ]; then
            # nothing todo
            if [ "$verbose" -ne 0 ]; then
                echo "  Package \"$package\" is already installed."
            fi
        else

            if [ "$verbose" -ne 0 ] || [ "$answer" != "a" ]; then
                echo "  Package \"$package\" is missing."
                if [ "$answer" != "a" ]; then
                    echo -n "  Try to install it ? (No/yes/all) "
                    read answer

                    # check if answer was "yes"
                    if [ "$answer" == "yes" ] || [ "$answer" == "YES" ] || \
                      [ "$answer" == "Yes" ] || [ "$answer" == "y" ]; then
                        answer="y";
                    fi
                    # check if answer was "all"
                    if [ "$answer" == "all" ] || [ "$answer" == "ALL" ] || \
                      [ "$answer" == "All" ] || [ "$answer" == "A" ]; then
                        answer="a";
                    fi
                fi
            fi

            # install
            if [ "$answer" == "y" ] || [ "$answer" == "a" ]; then
                sudo apt install "$package" $auto_answer
            fi
        fi
    done
}

#***************************[parameter]***************************************
# 2019 09 26

function _config_simple_parameter_check() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <function_name> <first_parameter> <string1> "
        echo "[<string2>] ..."

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 3-.. parameters"
        echo "     #1: displayed function name"
        echo "     #2: first parameter"
        echo "     #3: (first) string of description"
        echo "    [#..:] optional other strings of description"
        echo "This function is a wrapper function for all simple config-"
        echo "functions, which do not take any parameters except for"
        echo "-h and --help."
        echo "Additionally the user will be asked to confirm the execution."

        return
    fi

    # check parameter
    if [ $# -lt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi




    # switch to wrapped function
    func_name="$1"
    argument="$2"
    shift
    shift

    # print simple help
    if [ "$argument" == "-h" ]; then
        echo "$func_name"
        return
    fi

    # print function description
    echo -n "$func_name "
    for line in "$@"; do
        echo "$line"
    done

    if [ "$argument" == "--help" ]; then
        return
    fi

    # check parameter
    if [ "$argument" != "" ]; then
        echo "$func_name: Parameter Error."
        return -1
    fi

    # check for user-intention
    echo -n "  Do you want to continue ? (No/yes) "
    read answer

    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
        [ "$answer" != "yes" ]; then
        echo "$func_name: Aborted."
        return -1
    fi

    return
}

