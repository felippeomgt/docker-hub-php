#!/usr/bin/env bash

: ' Defines PHP CGI variables and binary

    '

# variables
PHP_MAJOR_VERSION=<PHP_MAJOR_VERSION_PLACEHOLDER>
PHPRC="/usr/local/php"${PHP_MAJOR_VERSION}"/etc/cli/"
PHP_FCGI_CHILDREN=4
PHP_FCGI_MAX_REQUESTS=5000

# export variables
export PHPRC
export PHP_FCGI_CHILDREN
export PHP_FCGI_MAX_REQUESTS

# exec
exec /usr/local/php"${PHP_MAJOR_VERSION}"/bin/php-cgi
