#!/usr/bin/env bash

: ' Installs Grunt
    More information at: http://gruntjs.com/installing-grunt

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
NPM=$(which npm)

# variables
_GRUNT_CLI_VERSION="${GRUNT_CLI_VERSION}"
_GRUNT_CONTRIB_COMPASS_VERSION="${GRUNT_CONTRIB_COMPASS_VERSION}"

# grunt packages
readonly GRUNT_PACKAGES=" \
          grunt-cli@${_GRUNT_CLI_VERSION} \
          grunt-contrib-compass@${_GRUNT_CONTRIB_COMPASS_VERSION} \
          "

# install grunt through Node.js
"${NPM}" install --global \
          ${GRUNT_PACKAGES}
