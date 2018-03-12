FROM centos:7

# define Docker image label information
LABEL com.ciandt.vendor="CI&T Software SA" \
      com.ciandt.maintainers.1="Halison Alan Fernandes - @halisonfernandes"

# defines root user, to perform privileged operations
USER root

# environment variables
ENV APACHE2_MAJOR_VERSION 2.4
ENV PHP_VERSION 70

# upgrade CentOS packages, install security updates and required packages
RUN readonly CENTOS_PACKAGES=" \
                initscripts \
                systemd \
                curl \
                centos-release-scl \
                " \
    && yum -y update \
    && yum -y install \
                  ${CENTOS_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && yum clean all

# Apache
# required packages
RUN readonly APACHE_PACKAGES=" \
      httpd24 \
      mod_ssl \
      " \ 
    && yum-config-manager --enable rhel-server-rhscl-7-rpms \
    && yum -y install \
                ${APACHE_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && yum clean all

# PHP
# required packages
RUN readonly PHP_PACKAGES=" \
      rh-php${PHP_VERSION} \
      rh-php${PHP_VERSION}-php \
      rh-php${PHP_VERSION}-php-fpm \
      rh-php${PHP_VERSION}-php-cli \
      rh-php${PHP_VERSION}-php-mysqlnd \
      rh-php${PHP_VERSION}-php-pgsql \
      rh-php${PHP_VERSION}-php-gd \
      rh-php${PHP_VERSION}-php-xml \
      rh-php${PHP_VERSION}-php-pdo \
      rh-php${PHP_VERSION}-php-mbstring \
      php-devel \
      " \    
    && yum -y install \
                ${PHP_PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && yum clean all

# Create local instance httpd-default
RUN cp -R /etc/httpd /etc/httpd-default \
    && rm -rf /etc/httpd-default/conf.d/*.* \
    && cp -R /opt/rh/httpd24/root/usr/sbin/* /usr/sbin/

# create conf file
COPY app/httpd/httpd.conf \
     /etc/httpd-default/conf/httpd.conf

# copy docroot config
COPY app/httpd/default.conf \
     /etc/httpd-default/conf.d/default.conf
COPY app/httpd/default-ssl.conf \
     /etc/httpd-default/conf.d/default-ssl.conf

# load php module
COPY app/httpd/conf.modules.d/php.conf \
     /etc/httpd-default/conf.modules.d/php.conf

# create service file
COPY app/httpd/httpd-default.service \
     /usr/lib/systemd/system/httpd-default.service

# create docroot folder
RUN mkdir --parents /var/www/html/docroot

# copy init script
COPY app/init.sh /usr/local/bin

# change workdir to Apache2 folder
WORKDIR /var/www/html

EXPOSE 80 443

# docker configuration
CMD ["init.sh"]