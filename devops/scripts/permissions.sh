#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ../

source scripts/_environment-with-local.sh
cd ..

ansible-playbook devops/provisioning/permissions.yml -i devops/provisioning/inventory/${inventory}
