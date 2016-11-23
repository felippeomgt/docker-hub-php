#!/usr/bin/env bash

: ' Installs Drush
    More information at: https://www.drupal.org/node/1248790

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
CURL=$(which curl)
LN=$(which ln)
MKDIR=$(which mkdir)
RM=$(which rm)

# variables
_RUBY_VERSION="${RUBY_VERSION}"
_RUBY_BUNDLER_VERSION="${RUBY_BUNDLER_VERSION}"
_RUBY_COMPASS_VERSION="${RUBY_COMPASS_VERSION}"

# create tmp folder
"${MKDIR}" /tmp/ruby

# change workdir
cd /tmp/ruby

# add gpg key
"${CURL}" --silent \
          --show-error \
          --location \
          https://rvm.io/mpapis.asc | \
          gpg --import -

# installs Ruby
"${CURL}" --silent \
          --show-error \
          --location \
          https://get.rvm.io | \
          bash -s stable --ruby="${_RUBY_VERSION}"

# create symbolic links
"${LN}" --force \
        --symbolic \
        /usr/local/rvm/rubies/ruby-"${_RUBY_VERSION}"/bin/ruby \
        /etc/alternatives/ruby

"${LN}" --force \
        --symbolic \
        /usr/local/rvm/rubies/ruby-"${_RUBY_VERSION}"/bin/gem \
        /etc/alternatives/gem

"${LN}" --force \
        --symbolic \
        /usr/local/rvm/rubies/ruby-"${_RUBY_VERSION}"/bin/ruby \
        /usr/bin/ruby"${_RUBY_VERSION}"

"${LN}" --force \
        --symbolic \
        /usr/local/rvm/rubies/ruby-"${_RUBY_VERSION}"/bin/gem \
        /usr/bin/gem"${_RUBY_VERSION}"

# add environment variables to .bashrc
echo 'source /usr/local/rvm/scripts/rvm' >> ~/.bashrc

# gem binary check
GEM=$(which gem)

# define ruby packages
readonly RUBY_PACKAGES=" \
          bundler:${_RUBY_BUNDLER_VERSION} \
          compass:${_RUBY_COMPASS_VERSION} \
          "

# load rvm environment variables
set +u  #   unset OK \
source "/usr/local/rvm/scripts/rvm" \
set -u  #   unset NOK

# install bundler and compass
"${GEM}" install \
          ${RUBY_PACKAGES}

# remove tmp folder
cd /
"${RM}" --force \
        --recursive \
        /tmp/ruby
