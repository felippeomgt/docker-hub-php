#!/usr/bin/env bash

: ' Load Apache 2 environment variables form envvars file and executes Apache 2
    in daemon foreground mode

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)

# variables
APACHE2_CONF_FOLDER="/etc/apache2"
APACHE2_ENVVARS_FILE="${APACHE2_CONF_FOLDER}/envvars"
APACHE2_RUN_FOLDER="/var/run/apache2"
APACHE2_PID_FILE="${APACHE2_RUN_FOLDER}/apache2.pid"

if test -f "${APACHE2_ENVVARS_FILE}"; then

  source "${APACHE2_ENVVARS_FILE}"

fi

# Remove any pre-existing Apache2 PID files
rm --force "${APACHE2_PID_FILE}"

# run Apache2
exec apache2 -D FOREGROUND "$@"
