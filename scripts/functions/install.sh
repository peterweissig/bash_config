#!/bin/bash

#***************************[installation]************************************
# 2020 04 21

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
            answer="a"
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
                sudo apt install "$package" --assume-yes
            fi
        fi
    done
}

# 2023 09 24
function _config_uninstall_list() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <package-list> [<verbosity>] [<auto-answer>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: list of all packages (white-space seperated)"
        echo "    [#2:]verbosity flag"
        echo "         \"\" print also uninstalled packages (default)"
        echo "         \"quiet\" less verbose output"
        echo "    [#3:]using auto-answer for uninstalling packages"
        echo "         (must be -y or --yes)"
        echo "This function checks all given packages and asks for"
        echo "permission to uninstall all installed packages."

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
            answer="a"
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

        if [ "${package_info}" == "" ] || \
           [ "${package_info:0:2}" == "rc" ] || \
           [ "${package_info:0:2}" == "rn" ]; then
            # nothing todo
            if [ "$verbose" -ne 0 ]; then
                echo "  Package \"$package\" is not installed."
            fi
        else

            if [ "$verbose" -ne 0 ] || [ "$answer" != "a" ]; then
                if [ "${package_info:0:2}" == "ii" ]; then
                    echo "  Package \"$package\" is installed."
                else
                    echo "  Package \"$package\" might be installed."
                fi
                if [ "$answer" != "a" ]; then
                    echo -n "  Try to uninstall it ? (No/yes/all) "
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
                sudo apt remove "$package" --assume-yes
            fi
        fi
    done
}

# 2022 02 20
function config_install_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function lists all manually installed packages."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # based on https://askubuntu.com/questions/2389
    LIST_CURRENT="$(apt-mark showmanual | sort --unique)"
    LIST_INIT="$(gzip -dc /var/log/installer/initial-status.gz | \
      grep "^Package: " | grep -o -E "[^: ]+$" | sort --unique)"

    comm -23 <(echo "$LIST_CURRENT") <(echo "$LIST_INIT")
}
