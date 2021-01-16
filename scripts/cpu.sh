#!/bin/bash

#***************************[show freq & temp]********************************

# 2021 01 14
function config_cpu_freq_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<loop-flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:] if flag is set, frequency of printed continuously"
        echo "This function prints the frequency of all CPUs."
        echo -n "If a parameter is passed only one frequency is printed "
        echo "continuously."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ $# -lt 1 ]; then
        cat /proc/cpuinfo | grep "MHz"
    else
        while [ 1 ]; do
            cat /proc/cpuinfo | grep "MHz" | head -n 1
            sleep 0.25
        done
    fi
}

# 2021 01 14
function config_cpu_temp_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<loop-flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:] if flag is set, temperature of printed continuously"
        echo "This function prints the temperature of all CPUs."
        echo -n "If a parameter is passed only one temperature is printed "
        echo "continuously."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ $# -lt 1 ]; then
        sensors | grep --color=never "Core"
    else
        while [ 1 ]; do
            sensors | grep --color=never "Core" | head -n 1
            sleep 0.25
        done
    fi
}



#***************************[mode]********************************************

# 2021 01 14

function config_cpu_mode_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function prints the current mode of all CPUs."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    PATH_CPUS="/sys/devices/system/cpu/"

    # get list of cpus
    cpus="$(ls "$PATH_CPUS" | grep -E "^cpu[0-9]+")"

    # iterate and check if all are equal
    all_equal=1
    last_governor=""
    for cpu in $cpus; do
        cpu_path="${PATH_CPUS}${cpu}/cpufreq/scaling_governor"
        if [ ! -e "$cpu_path" ]; then
            all_equal=0
            break
        fi
        current_governor="$(cat "$cpu_path")"

        if [ "$last_governor" != "" ]; then
            if [ "$last_governor" != "$current_governor" ]; then
                all_equal=0
                break
            fi
        fi
        last_governor="$current_governor"
    done

    # print governor, if all are equal
    if [ $all_equal -eq 1 ] && [ "$current_governor" != "" ]; then
        echo ""
        echo "  all CPUs govenors are \"$current_governor\""
        echo ""

        return
    fi

    # otherwise print each governor
    for cpu in $cpus; do
        echo -n "  ${cpu}: "
        cpu_path="${PATH_CPUS}${cpu}/cpufreq/scaling_governor"
        if [ ! -e "$cpu_path" ]; then
            echo "error"
            continue
        fi
        echo "$(cat "$cpu_path")"
    done
}

#***************************[mode]********************************************

# 2021 01 14
function config_cpu_mode_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function prints the current governors of all CPUs."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    PATH_CPUS="/sys/devices/system/cpu/"

    # get list of cpus
    cpus="$(ls "$PATH_CPUS" | grep -E "^cpu[0-9]+")"

    # iterate and check if all are equal
    all_equal=1
    last_governor=""
    for cpu in $cpus; do
        cpu_path="${PATH_CPUS}${cpu}/cpufreq/scaling_governor"
        if [ ! -e "$cpu_path" ]; then
            all_equal=0
            break
        fi
        current_governor="$(cat "$cpu_path")"

        if [ "$last_governor" != "" ]; then
            if [ "$last_governor" != "$current_governor" ]; then
                all_equal=0
                break
            fi
        fi
        last_governor="$current_governor"
    done

    # print governor, if all are equal
    if [ $all_equal -eq 1 ] && [ "$current_governor" != "" ]; then
        echo ""
        echo "  all CPU scaling govenors are set to \"$current_governor\""
        echo ""

        return
    fi

    # otherwise print each governor
    echo ""
    for cpu in $cpus; do
        echo -n "  ${cpu}: "
        cpu_path="${PATH_CPUS}${cpu}/cpufreq/scaling_governor"
        if [ ! -e "$cpu_path" ]; then
            echo "error"
            continue
        fi
        echo "$(cat "$cpu_path")"
    done
}

# 2021 01 14
function config_cpu_mode_set() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <governor>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: new scaling governor"
        echo "         e.g. \"powersave\" or \"performance\""
        echo "This function sets the current governor of all CPUs."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_governor="$1"

    # init variables
    PATH_CPUS="/sys/devices/system/cpu/"

    # get list of cpus
    cpus="$(ls "$PATH_CPUS" | grep -E "^cpu[0-9]+")"

    # set each governor
    for cpu in $cpus; do
        cpu_path="${PATH_CPUS}${cpu}/cpufreq/scaling_governor"
        if [ ! -e "$cpu_path" ]; then
            echo "  ${cpu}: error"
            continue
        fi
        echo "  ${cpu}: set to $param_governor"
        echo "$param_governor" | sudo tee "$cpu_path" > /dev/null 2>&1
    done

    config_cpu_mode_show
}
