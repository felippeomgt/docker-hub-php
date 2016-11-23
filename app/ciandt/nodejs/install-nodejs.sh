#!/usr/bin/env bash

: ' Installs Node.js
    More information at: https://easyengine.io/tutorials/nodejs/node-js-npm-install-ubuntu/

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
APT_GET=$(which apt-get)

# variables
_NODEJS_VERSION="${NODEJS_VERSION}"

# install required package
"${APT_GET}" update \
&& "${APT_GET}" install \
                --no-install-recommends \
                --assume-yes \
                python-software-properties

# check apt-add-repository binary
APT_ADD_REPOSITORY=$(which apt-add-repository)

# add repo for Node.js
"${APT_ADD_REPOSITORY}" -y ppa:chris-lea/node.js

# install Node.js
"${APT_GET}" update \
&& "${APT_GET}" install \
                --no-install-recommends \
                --assume-yes \
                nodejs=${_NODEJS_VERSION}-1chl1~precise1

# remove apt cache in order to improve Docker image size
"${APT_GET}" clean
