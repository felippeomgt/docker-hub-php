FROM ubuntu:16.04

# define Docker image label information
LABEL com.ciandt.vendor="CI&T Software SA" \
      com.ciandt.maintainers.1="Ivan Pinatti - @ivan_pinatti" \
      com.ciandt.maintainers.2="Thomas Bryan - @thobryan"

# defines root user, to perform privileged operations
USER root

# upgrade Ubuntu packages, install security updates and required packages
RUN readonly UBUNTU_PACKAGES=" \
                curl \
                " \
    && apt-get update \
    && apt-get upgrade --assume-yes \
    && apt-get install --no-install-recommends \
                        --assume-yes \
                        ${UBUNTU_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && apt-get clean

## Apache2
# environment variables
ENV APACHE2_MAJOR_VERSION 2.4
ENV APACHE2_MINOR_VERSION 18
ENV APACHE2_VERSION ${APACHE2_MAJOR_VERSION}.${APACHE2_MINOR_VERSION}

# declare required packages
RUN readonly APACHE2_PACKAGES=" \
              apache2=${APACHE2_VERSION}-* \
              apache2-dev \
              libapache2-mod-xsendfile \
              libapache2-mod-passenger \
              libapache2-mod-fastcgi \
              ssl-cert \
              " \
    # install packages
    && apt-get install \
                --no-install-recommends \
                --assume-yes \
                ${APACHE2_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && apt-get clean

# disable modules
# Apache 2.4 comes with mpm_event enabled by default. We'll switch that for mpm_prefork.
# Reference: https://serverfault.com/questions/383526/how-do-i-select-which-apache-mpm-to-use
RUN readonly APACHE2_MODULES_TO_DISABLE=" \
              autoindex \
              mpm_event \
              " \
    # Force disabling apache modules that might be considered "essential" such
    # as autoindex.
    && a2dismod --force ${APACHE2_MODULES_TO_DISABLE} \
    # enable modules
    && readonly APACHE2_MODULES_TO_ENABLE=" \
              actions \
              expires \
              proxy_fcgi \
              headers \
              passenger \
              rewrite \
              ssl \
              suexec \
              vhost_alias \
              xsendfile \
              mpm_prefork \
              " \
    && a2enmod ${APACHE2_MODULES_TO_ENABLE}

# if exists X-Forwarded-Proto in header set HTTPS=on
RUN echo "SetEnvIf X-Forwarded-Proto https HTTPS=on" > \
      /etc/apache2/conf-available/https-forward-flag.conf \
      && a2enconf https-forward-flag

# tweak conf
RUN readonly APACHE2_CONF_FILE="/etc/apache2/apache2.conf" \
    # set ServerName - to avoid the warning message "apache2 could not fully qualified domain name"
    && echo "ServerName localhost" >> \
        "${APACHE2_CONF_FILE}" \
    # configure log
    && sed --in-place \
            --regexp-extended \
  		      --expression \
              's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
	          --expression \
              's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
	          ${APACHE2_CONF_FILE}

# create docroot folder
RUN mkdir --parents /var/www/html/docroot

# create conf file to accept any site
COPY apache2/any-site.conf \
     /etc/apache2/sites-available/any-site.conf

# disable default site - enable any-site
RUN a2dissite 000-default \
    && a2ensite any-site

# create run foreground script
COPY apache2/apache2-foreground.sh \
     /usr/local/bin/apache2-foreground

# start/stop service
RUN service apache2 start \
    && service apache2 stop

## PHP
# environment variables
ENV PHP_MAJOR_VERSION 7.1
ENV PHP_MINOR_VERSION 18
ENV PHP_VERSION ${PHP_MAJOR_VERSION}.${PHP_MINOR_VERSION}
ENV PHP_EXTENSION_APCU_VERSION 5.1.11
ENV PHP_EXTENSION_GNUPG_VERSION 1.6.0
ENV PHP_EXTENSION_HTTP_VERSION 3.1.0
ENV PHP_EXTENSION_IGBINARY_VERSION 2.0.6
ENV PHP_EXTENSION_IMAGICK_VERSION 3.4.3
ENV PHP_EXTENSION_MEMCACHED_VERSION 3.0.4
# ENV PHP_EXTENSION_MONGO_VERSION 1.6.14
ENV PHP_EXTENSION_OAUTH_VERSION 2.0.2
ENV PHP_EXTENSION_PROPRO_VERSION 2.1.0
ENV PHP_EXTENSION_RAPHF_VERSION 2.0.0
ENV PHP_EXTENSION_SSH2_VERSION 1.1.2
# ENV PHP_EXTENSION_UPLOADPROGRESS_VERSION 1.0.3.1
ENV PHP_EXTENSION_XDEBUG_VERSION 2.5.5
# ENV PHP_EXTENSION_XHPROF_VERSION 0.9.4
ENV PHP_EXTENSION_YAML_VERSION 2.0.2

# required packages
RUN readonly PHP_DEV_PACKAGES=" \
      make \
      gcc \
      build-essential \
      pkg-config \
      apache2-dev \
      libxml2-dev \
      libcurl4-openssl-dev \
      libbz2-dev \
      libdb5.3-dev \
      libjpeg-dev \
      libpng12-dev \
      libxpm-dev \
      libfreetype6-dev \
      postgresql-server-dev-9.5 \
      libxfont-dev \
      libgd2-xpm-dev \
      libgmp-dev \
      libmysqlclient-dev \
      libsasl2-dev \
      libmhash-dev \
      # unixodbc-dev \
      freetds-dev \
      libpspell-dev \
      libsnmp-dev \
      libtidy-dev \
      libmcrypt-dev \
      libc-client-dev \
      libreadline6-dev \
      libssh2-1-dev \
      libgpgme11-dev \
      libmagickwand-dev \
      libxslt1-dev \
      libyaml-dev \
      libkrb5-dev \
      libmemcached-dev \
      " \
    && readonly PHP_PACKAGES=" \
                  autoconf \
                  libbsd0 \
                  libedit2 \
                  libxml2 \
                  libmagic1 \
                  ucf \
                  sgml-base \
                  xml-core \
                  libc-client2007e \
                  libxslt1.1 \
                  libudev1 \
                  # libdb4.8 \
                  libfreetype6 \
                  # unixodbc \
                  libreadline6 \
                  libssh2-1 \
                  libgpgme11 \
                  # php-pear \
                  libmemcached11 \
                  " \
    && apt-get install \
                --no-install-recommends \
                --assume-yes \
                ${PHP_DEV_PACKAGES} \
                ${PHP_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && apt-get clean

# STEP: download php sources
# create temp folder
RUN mkdir --parents /tmp/php/src/${PHP_VERSION} \
    # download
    && cd /tmp/php/src/${PHP_VERSION} \
    && curl --silent \
             --show-error \
             --location \
             --output php-${PHP_VERSION}.tar.gz \
             https://php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror \
    && tar --gunzip \
            --extract \
            --file \
            php-${PHP_VERSION}.tar.gz \
    # fix link for required library
    && ln --force \
          --symbolic \
          /usr/lib/libc-client.a \
          /usr/lib/x86_64-linux-gnu/libc-client.a \
    && ln --force \
          --symbolic \
          /usr/include/x86_64-linux-gnu/gmp.h \
          /usr/include/gmp.h \
    # configure
    && cd /tmp/php/src/${PHP_VERSION}/php-${PHP_VERSION} \
    && ./configure \
         --enable-fpm \
         --enable-cli \
         --with-config-file-path=/usr/local/php${PHP_MAJOR_VERSION}/etc/cli \
         --with-config-file-scan-dir=/usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d \
         --prefix=/usr/local/php${PHP_MAJOR_VERSION} \
         --enable-bcmath \
         --with-gmp \
         --with-bz2=/usr \
         --enable-calendar \
         --with-curl \
         --enable-dba \
         --with-db4 \
         --enable-exif \
         --with-gd \
         --with-jpeg-dir=/usr/lib \
         --with-png-dir=/usr/lib \
         --with-freetype-dir=/usr \
         --enable-ftp \
         --with-gettext \
         --with-imap \
         --with-kerberos \
         --with-imap-ssl \
         --enable-inline-optimization \
         --with-ldap \
         --with-ldap-sasl \
         --with-openssl=/usr \
         --enable-mbstring \
         --enable-mbregex \
         --with-mcrypt \
         --with-mhash \
         --with-mysql-sock=/var/run/mysqld/mysqld.sock \
         --with-mysqli=/usr/bin/mysql_config \
         --enable-pcntl \
         --with-pcre-regex \
         --with-pgsql \
         --with-pdo-mysql \
         --with-pdo-pgsql \
         --with-pdo-dblib \
         --with-pspell=/usr \
         --with-readline \
         --enable-shmop \
         --enable-soap \
         --enable-sockets \
         --enable-sysvsem \
         --enable-sysvshm \
         --enable-sysvmsg \
         --with-tidy \
         --enable-wddx \
         --enable-xml \
         --with-xmlrpc \
         --with-xsl \
         --with-xpm-dir=/usr \
         --enable-zip \
         --with-zlib \
         --with-libdir=/lib/x86_64-linux-gnu \
         CFLAGS="-g -O2 -fno-omit-frame-pointer" \
         CXXFLAGS="-fno-omit-frame-pointer" \
    # compile
    && make -j$(nproc) \
    # install
    && make install \
    # create CLI folder and copy php.ini
    && mkdir --parents /usr/local/php${PHP_MAJOR_VERSION}/etc/cli \
    && readonly PHP_CONF="/usr/local/php${PHP_MAJOR_VERSION}/etc/cli/php.ini" \
    && cp /tmp/php/src/${PHP_VERSION}/php-${PHP_VERSION}/php.ini-production \
          ${PHP_CONF} \
    # set PHP configuration parameters according Acquia environment
    && sed --in-place \
           --regexp-extended \
           --expression \
              's!^display_errors = .*$!display_errors = STDOUT!g' \
           --expression \
              's!^enable_dl = .*$!enable_dl = On!g' \
           --expression \
              's!^expose_php = .*$!expose_php = Off!g' \
           --expression \
              's!^ignore_repeated_errors = .*$!ignore_repeated_errors = On!g' \
           --expression \
              's!^mail.add_x_header = .*$!mail.add_x_header = Off!g' \
           --expression \
              's!^short_open_tag = .*$!short_open_tag = On!g' \
           --expression \
              's!^memory_limit = .*$!memory_limit = 512M!g' \
           --expression \
              's!^post_max_size = .*$!post_max_size = 256M!g' \
           --expression \
              's!^request_order = .*$!request_order = GP!g' \
           --expression \
              's!^upload_max_filesize = .*$!upload_max_filesize = 256M!g' \
           --expression \
              's!^variables_order = .*$!variables_order = EGPCS!g' \
           ${PHP_CONF} \
    && echo "realpath_cache_size = 900K" >> "${PHP_CONF}" \
    && echo "realpath_cache_ttl = 300" >> "${PHP_CONF}" \
    && echo "sendmail_path = /usr/sbin/sendmail -t -i" >> "${PHP_CONF}" \
    && echo "error_log = syslog" >> "${PHP_CONF}" \
    && echo "date.timezone = UTC" >> "${PHP_CONF}" \
    # purge source files
    && cd / \
    && rm --recursive \
       --force \
       /tmp/php \
    # create link for PHP binary
    && ln --force --symbolic \
         /usr/local/php${PHP_MAJOR_VERSION}/bin/php \
         /usr/local/bin/php \
    # create link for Pecl binary
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/bin/pecl \
       /usr/local/bin/pecl \
    # set PECL in php.ini
    && pecl config-set \
       php_ini \
       /usr/local/php"${PHP_MAJOR_VERSION}"/etc/cli/php.ini \
    # install extensions (3rd party) through PECL, configure its ini files and links
    # avoid issues with memcache extension: https://bugs.php.net/bug.php?id=66230
    && CFLAGS="-fgnu89-inline" pecl install \
       apcu-"${PHP_EXTENSION_APCU_VERSION}" \
       gnupg-"${PHP_EXTENSION_GNUPG_VERSION}" \
       igbinary-"${PHP_EXTENSION_IGBINARY_VERSION}" \
       imagick-"${PHP_EXTENSION_IMAGICK_VERSION}" \
       memcached-"${PHP_EXTENSION_MEMCACHED_VERSION}" \
       OAuth-"${PHP_EXTENSION_OAUTH_VERSION}" \
       propro-"${PHP_EXTENSION_PROPRO_VERSION}" \
       raphf-"${PHP_EXTENSION_RAPHF_VERSION}" \
       ssh2-"${PHP_EXTENSION_SSH2_VERSION}" \
       xdebug-"${PHP_EXTENSION_XDEBUG_VERSION}" \
       yaml-"${PHP_EXTENSION_YAML_VERSION}"

# php configuration files
RUN mkdir --parents /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d \
    && cd /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d \
    && echo "extension=apcu.so" > apcu.ini \
    && echo "extension=gnupg.so" > gnupg.ini \
    && echo "extension=igbinary.so" > igbinary.ini \
    && echo "extension=imagick.so" > imagick.ini \
    && echo "extension=memcached.so" > memcached.ini \
    && echo "extension=oauth.so" > oauth.ini \
    && echo "extension=oauth.so" > oauth.ini \
    && echo "extension=propro.so" > propro.ini \
    && echo "extension=raphf.so" > raphf.ini \
    && echo "extension=ssh2.so" > ssh2.ini \
    && echo "extension=yaml.so" > yaml.ini \
    && echo "zend_extension=/usr/local/php${PHP_MAJOR_VERSION}/lib/php/extensions/no-debug-non-zts-20160303/opcache.so" \
       > opcache.ini \
    && echo "zend_extension=/usr/local/php${PHP_MAJOR_VERSION}/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so" \
        > xdebug.ini \
    # modify xdebug options
    && echo "xdebug.remote_enable=On" >> xdebug.ini \
    && echo "xdebug.remote_connect_back=On" >> xdebug.ini \
    && echo "xdebug.remote_port=9000" >> xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> xdebug.ini \
    && echo "xdebug.remote_mode=req" >> xdebug.ini \
    && echo "xdebug.profiler_enable=Off" >> xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=On" >> xdebug.ini \
    && echo "xdebug.var_display_max_data=1024" >> xdebug.ini \
    && echo "xdebug.var_display_max_depth=128" >> xdebug.ini \
    && echo "xdebug.max_nesting_level=256" >> xdebug.ini \
    && mkdir --parents /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/apcu.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/apcu.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/gnupg.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/gnupg.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/igbinary.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/igbinary.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/imagick.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/imagick.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/memcached.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/memcached.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/oauth.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/oauth.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/opcache.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/opcache.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/propro.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/propro.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/raphf.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/raphf.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/ssh2.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/ssh2.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/xdebug.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/xdebug.ini \
    # pecl_http is dependent of raphf and it needs to be installed later
    && echo '' | pecl install pecl_http-"${PHP_EXTENSION_HTTP_VERSION}" \
    && echo "extension=http.so" > http.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/http.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/http.ini \
    && ln --force --symbolic \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/conf.d/yaml.ini \
       /usr/local/php${PHP_MAJOR_VERSION}/etc/cli/conf.d/yaml.ini \
    # remove DEV packages
    && apt-get autoremove \
                --purge \
                --assume-yes \
                ${PHP_DEV_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && apt-get clean

# set PHP FPM configuration
COPY php/www.conf.default \
     /usr/local/php${PHP_MAJOR_VERSION}/etc/php-fpm.d

# create run foreground script
COPY php/php-fpm-daemon.sh \
    /usr/local/bin/php-fpm-daemon.sh

# symlink to php dir
RUN ln --force --symbolic \
    /usr/local/php${PHP_MAJOR_VERSION}/ \
    /usr/local/php

# create a simple test page
# RUN echo '<?php phpinfo(); ?>' > /var/www/html/docroot/info.php

# create GFS folder like Acquia in order of mounting files
RUN mkdir --parents /mnt/gfs

## DUMB-init
# more information at: https://github.com/Yelp/dumb-init

# environment variables
ENV DUMB_INIT_VERSION 1.2.0

# download
RUN mkdir --parents /tmp/dumb-init \
    && cd /tmp/dumb-init \
    && curl --silent \
             --show-error \
             --location \
             --remote-name \
             https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64.deb \
    # install
    && dpkg --install dumb-init_${DUMB_INIT_VERSION}_amd64.deb \
    # remove temp folder
    && cd / \
    && rm --force \
          --recursive \
          /tmp/dumb-init

## Docker specifics

# expose HTTP and HTTPS ports
EXPOSE 80 443

# change workdir to Apache2 folder
WORKDIR /var/www/html

# copy init script
COPY init.sh /usr/local/bin

# docker entrypoint/cmd configuration
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["init.sh"]

## CI&T

# copy pre-built scripts
COPY ciandt /root/ciandt
