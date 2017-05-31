FROM centos:7

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum update -y && yum install -y \
  httpd.x86_64 \
  php55w-opcache.x86_64 \
  php55w.x86_64 \
  php55w-common.x86_64 \
  php55w-cli.x86_64 \
  php55w-devel.x86_64 \
  php55w-gd.x86_64 \
  php55w-pecl-memcache.x86_64 \
  php55w-ldap.x86_64 \
  php55w-mbstring.x86_64 \
  php55w-mysqlnd.x86_64 \
  php55w-pgsql.x86_64 \
  php55w-xml.x86_64 \
  mod_ssl.x86_64 \
  wget \
  lsof \
  vim \
  git \
  gcc \
  iproute \
  mysql \
  openssh-clients.x86_64

# Include virtualhost in Apache Configuration
RUN echo "NameVirtualHost *:80" >> /etc/httpd/conf/httpd.conf
RUN echo "Listen 443" >> /etc/httpd/conf/httpd.conf
RUN echo "NameVirtualHost *:443" >> /etc/httpd/conf/httpd.conf
RUN mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
RUN echo "Include /local/apache/conf/*.conf" >> /etc/httpd/conf/httpd.conf

# Install Drush
RUN wget --quiet -O - http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz | tar -zxf - -C /usr/local/share
RUN ln -s /usr/local/share/drush/drush /usr/local/bin/drush

RUN mkdir -p /local/apache/conf && \
    mkdir -p /local/apache/keys && \
    mkdir -p /local/apache/logs

COPY apache/conf/* /local/apache/conf/
COPY apache/keys/* /local/apache/keys/

# if there is a X-Forwarded-Proto set HTTPS=on
RUN echo "SetEnvIf X-Forwarded-Proto https HTTPS=on" > /local/apache/conf/https-forward-flag.conf

# Xdebug configuration
RUN yes | pecl install xdebug

RUN echo "zend_extension=$(find /usr/lib64/php/modules/ -name xdebug.so)" > /etc/php.d/xdebug.ini \
    && echo "[xdebug]" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_autostart=true" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_enable = On" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.default_enable = On" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_connect_back = On" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_port = 9000" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_mode=req" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.idekey=netbeans-xdebug" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.var_display_max_data = 2048" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.var_display_max_depth = 128" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.max_nesting_level = 500" >> /etc/php.d/xdebug.ini

# Error logs
RUN echo "log_errors = On" > /etc/php.d/error_log.ini \
    && echo "display_errors= On" >> /etc/php.d/error_log.ini \
    && echo "error_log=/local/apache/logs/php.error.log" >> /etc/php.d/error_log.ini
