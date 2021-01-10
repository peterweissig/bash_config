#!/bin/bash

#***************************[service info]***********************************
# 2021 01 10

function config_check_service() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <service-name> [<verbosity>] [<enabled>] [<active>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-4 parameters"
        echo "     #1: service to be checked"
        echo "    [#2:]verbosity-level"
        echo "         \"\"         some as normal (default)"
        echo "         \"quiet\"    print only errors"
        echo "         \"normal\"   print service name and result(s)"
        echo "         \"verbose\"  print also recommandations"
        echo "    [#3:]flag for checking enabled/disabled status"
        echo "         \"\"         no check is done (default)"
        echo "         \"enabled\"  check, if service is enabled"
        echo "         \"disabled\" check, if service is disabled"
        echo "    [#4:]flag for checking (in)active status"
        echo "         \"\"         no check is done"
        echo "         \"active\"   check, if service is active (default)"
        echo "         \"inactive\" check, if service is inactive"
        echo "This function checks, if the given service exists. Depending"
        echo "on the optional parameters the status will also be checked."
        echo "The function only echos some infos, if there are problems."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 4 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_name="$1"
    param_verb="$2"
    param_enabled="$3"
    param_active="active"
    if [ $# -ge 4 ]; then
        param_active="$4"
    fi
    if [ "$param_verb" == "" ]; then
        param_verb="normal"
    fi
    if [ "$param_verb" == "quiet" ]; then
        param_verb=0
    elif [ "$param_verb" == "normal" ]; then
        param_verb=1
    elif [ "$param_verb" == "verbose" ]; then
        param_verb=2
    else
        echo "$FUNCNAME: Parameter Error for <verbosity>."
        $FUNCNAME --help
        return -1
    fi
    if [ "$param_enabled" != "" ] && [ "$param_enabled" != "enabled" ] && \
      [ "$param_enabled" != "disabled" ]; then
        echo "$FUNCNAME: Parameter Error for <enabled>."
        $FUNCNAME --help
        return -1
    fi
    if [ "$param_active" != "" ] && [ "$param_active" != "active" ] && \
      [ "$param_active" != "inactive" ]; then
        echo "$FUNCNAME: Parameter Error for <active>."
        $FUNCNAME --help
        return -1
    fi

    # initial output
    if [ $param_verb -ge 1 ]; then
        echo -n "checking service \"$param_name\" ... "
    fi

    error_flag=0
    # check if service exists
    result="$(systemctl status "$param_name" 2> /dev/null)"
    error_code="$?"
    if [ "$result" == "" ]; then
        echo ""
        echo -n "  unknown service"
        if [ $param_verb -ge 1 ]; then
            echo ""
        fi
        return -2
    elif [ "$error_code" -ne 0 ]; then
        if [ $param_verb -ge 1 ] || [ "$param_active" == "active" ] || \
          [ "$param_enabled" == "enabled" ]; then
            error_flag=1
            echo ""
            echo -n "  service status error"
            if [ $param_verb -ge 2 ]; then
                echo ""
                echo -n "    $ sudo systemctl status \"$param_name\""
            fi
        fi
    fi

    # check, if service is active
    if [ "$param_active" != "" ]; then
        result="$(systemctl is-active "$param_name" 2> /dev/null)"
        if [ "$result" != "$param_active" ]; then
            error_flag=1
            echo ""
            echo -n "  service not ${param_active}"
            if [ $param_verb -ge 2 ]; then
                echo ""
                if [ "$param_active" == "active" ]; then
                    echo -n "    $ sudo systemctl start \"$param_name\""
                else
                    echo -n "    $ sudo systemctl stop \"$param_name\""
                fi
            fi
        fi
    fi

    # check, if service is enabled
    if [ "$param_enabled" != "" ]; then
        result="$(systemctl is-enabled "$param_name" 2> /dev/null)"
        if [ "$result" != "$param_enabled" ]; then
            error_flag=1
            echo ""
            echo -n "  service not ${param_enabled}"
            if [ $param_verb -ge 2 ]; then
                echo ""
                if [ "$param_enabled" == "enabled" ]; then
                    echo -n "    $ sudo systemctl enable \"$param_name\""
                else
                    echo -n "    $ sudo systemctl disable \"$param_name\""
                fi
            fi
        fi
    fi

    # output result
    if [ "$error_flag" -eq 1 ]; then
        if [ $param_verb -ge 1 ]; then
            echo ""
        fi
        return -3
    else
        if [ $param_verb -ge 1 ]; then
            echo "ok"
        fi
    fi
}
