#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

# Find inventory files
ENVIRONMENTS=()
for entry in provisioning/inventory/*
do
    if [ -f ${entry} ] ; then
        ENVIRONMENTS+=($(basename "${entry}"))
    fi
done

source scripts/_environment.sh
