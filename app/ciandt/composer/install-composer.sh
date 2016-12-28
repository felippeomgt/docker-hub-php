#!/usr/bin/env bash

: ' Installs Composer
    More information at: https://getcomposer.org/download/

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
MKDIR=$(which mkdir)
MV=$(which mv)
PHP=$(which php)
RM=$(which rm)

# variables
_COMPOSER_VERSION="${COMPOSER_VERSION}"

# create a tmp folder
"${MKDIR}" --parents /tmp/composer

# change workdir
cd /tmp/composer

# download and check Composer installer
"${PHP}" -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# check downloaded Composer installer \
_EXPECTED_SIGNATURE=$(curl https://composer.github.io/installer.sig)
_ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
if [ "${_EXPECTED_SIGNATURE}" != "${_ACTUAL_SIGNATURE}" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

# install Composer \
"${PHP}" composer-setup.php --version "${_COMPOSER_VERSION}"

# move to bin \
"${MV}" composer.phar /usr/local/bin/composer

# remove Composer installer \
"${PHP}" -r "unlink('composer-setup.php');"

# remove folder
cd \
&& "${RM}" --force \
           --recursive \
           /tmp/composer
