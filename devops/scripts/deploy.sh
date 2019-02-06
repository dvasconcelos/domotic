#!/bin/bash

USAGE_ADDITIONAL_PARAMETER="[deploy_version]"
USAGE_ADDITIONAL_HELP="\tdeploy_version : version to deploy\n"

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ../

source scripts/_environment-without-local.sh
cd ..

# display usage if no option
if [ -z $2 ] ; then
    usage
fi

# save the inventory
deploy_version=${2}

ansible-playbook devops/provisioning/deploy.yml -i devops/provisioning/inventory/${inventory} --extra-vars "deploy_version=$deploy_version"
