# define phony targets
.PHONY: all install-composer install-drush install-ruby install-nodejs install-grunt

# define behavior for; make AND make all
all: install-drush install-ruby install-grunt

# install Composer and its components
install-composer:
	/root/ciandt/composer/install-composer.sh

# install Drush and its components
install-drush: install-composer
	/root/ciandt/drush/install-drush.sh

# install Ruby and its components
install-ruby:
	/root/ciandt/ruby/install-ruby.sh

# install Node.js
install-nodejs:
	/root/ciandt/nodejs/install-nodejs.sh

# install Grunt
install-grunt: install-nodejs
	/root/ciandt/grunt/install-grunt.sh
