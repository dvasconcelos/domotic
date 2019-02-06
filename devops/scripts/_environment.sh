#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

#
# Figure out the environment the ansible will run on.
#

if [ -z $ENVIRONMENTS ] ; then
    echo "ERROR - The ENVIRONMENTS variable is empty"
    exit 1
fi

# Array Join function - join the array $2 with the glue $1
function arrayJoin {
    local IFS="$1"
    shift
    echo "$*"
}

# Array in function - Check if given array $2 contains given element $1
function arrayIn() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

# Usage function
function usage() {
    printf "\n"
    printf "Usage:\n$0 [environment] ${USAGE_ADDITIONAL_PARAMETER}\n"
    printf "\tenvironment : ["$(arrayJoin , "${ENVIRONMENTS[@]}")"]\n"
    printf "${USAGE_ADDITIONAL_HELP}"
    printf "\n"
    exit 0
}

# display usage if asked with -h
if [ "$1" == "-h" ] ; then
    usage
fi

# display usage if no option
if [ -z $1 ] ; then
    usage
fi

# display error if the environment is unknown
arrayIn ${1} "${ENVIRONMENTS[@]}"
if [ $? = 1 ] ; then
    echo "No environment $1"
    exit 1
fi

# save the inventory
inventory=${1}
