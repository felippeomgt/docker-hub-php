### CI&T Acquia mimic Docker base image

This Docker image intends to be containerized mimic solution of Acquia environment.

The source code is available under GPLv3 at Bitbucket in this [link](https://bitbucket.org/ciandt_it/docker-hub-acquia).

Our intent is to have a Docker container that mimics Acquia environment with the same version of softwares and OS.

Utilizing Docker technologies that already provides an easy way of spinning up new environments and its dependecies, this image can speed-up developers which different backgrounds and equipments to have a fast local environment allowing them to easily integrate in automated tests and deployment pipelines.

Keeping it short, this image contains the same working set of Ubuntu, Apache and PHP that Acquia utilizes. Plus, there are also pre-loaded scripts that can easily customized to install other components if they are required like Drush, Grunt, etc...

### [*Quick Start*](#quickstart)

__Download the image__

```
docker pull ciandtsoftware/acquia:2016-11-08
```

__Run a container__

```
docker run \
  --volume /your/code/folder/before/docroot:/var/www/html \
  --volume /your/file/server/mounted/folder:/nfs \
  --name myContainer \
  --detach \
  ciandtsoftware/acquia:2016-11-08
```

__Check running containers__

```
docker ps --all
```

* * *

### [Software Versions](#software-versions)

These are the currently versions bundled in this image.

Already installed

* Ubuntu 12.04.5
* Apache 2.2
* PHP 5.6.24 (plus extensions)
    * Gnupg 1.4.0
    * HTTP 2.5.5
    * Igbinary 1.2.1
    * Imagick 3.3.0
    * Memcache 3.0.8
    * Mongo 1.6.12
    * Oauth 1.2.3
    * Propro 1.0.2
    * Raphf 1.1.2
    * SSH2 BETA
    * Upload Progress 1.0.3.1
    * Xdebug 2.4.1
    * Xhprof beta
* Dumb-init 1.2.0

Pre-loaded scripts for customization

* Composer 1.2.1
* Drush 8.1.3
* Grunt CLI 1.2.0
    * Compass 1.1.1
* Node.js 0.10.37
* Ruby 2.3.0
    * Bundler 1.13.6
    * Compass 1.0.3  

* * *

### [Running standalone](#running-standalone)

If you just need the container there is a snippet that can help running in standalone mode.

```
# define variables
HOST_CODE_FOLDER=""${HOME}"/workspace/mySite"
HOST_FILES_FOLDER=""${HOME}"/workspace/myNFSstorage"
DOCKER_CONTAINER_NAME="myContainer"
DOCKER_IMAGE="ciandtsoftware/acquia:2016-11-08"

# run your container
docker run \
  --volume "${HOST_CODE_FOLDER}":/var/www/html \
  --volume "${HOST_FILES_FOLDER}":/nfs \
  --name "${DOCKER_CONTAINER_NAME}" \
  --detach \
  "${DOCKER_IMAGE}"
```

After run, you can inquiry Docker service and get the IP address of your newly running container named __myContainer__ by using the following command:

```
docker inspect --format '{{ .NetworkSettings.IPAddress }} myContainer'
```

Let's suppose that the returned IP address was __172.17.0.2__.
Just open a browser and try to access:

> http://172.17.0.2

Your website should be displayed perfectly.

* * *

### [Customizing](#customizing)

As intended, you can take advantage from this image to build your own and already configure everything that a project requires.

#### [CI&T scripts](#scripts)

There are available scripts to help customization:

- install-composer
- install-drush
- install-grunt
- install-nodejs
- install-ruby

Scripts are composed by two parts;

- one executable file *script-name*__.sh__
- one variables file *script-name*__.env__

The *script-name* __.env__ contains the variables that *script-name* __.sh__ requires to perform its task.

All scripts are located inside folder __/root/ciandt__ and must be declared in the *__Makefile__*. Thus, it is easy to run any of them and have its dependency.

Just to give an quick example, you can create your own Docker image based on this one that already ships Drush installed as well. A Dockerfile performing it could be like:

```
FROM ciandtsoftware/acquia:2016-11-08

# installs required package
RUN apt-get update \
    && apt-get install \
                --no-install-recommends \
                --assume-yes \
                make

# defines Drush version
ENV DRUSH_VERSION 8.1.3

# installs Drush
RUN cd /root/ciandt \
    && make install-drush
```

Then you just need to build / run your new customized Docker image and you are ready to go.

* * *

### [Running in Docker-Compose](#running-docker-compose)

Since a project is not going to use solely this container, it may need a Docker-Compose file.

Just to exercise, follow an example of this running customized and als behind a __Nginx__ proxy.

Create a new folder and fill with these 3 files and respective folders;

##### [__conf/acquia.local.env__](#acquia-env)

```
## Nginx proxy configuration
# https://hub.docker.com/r/jwilder/nginx-proxy/
VIRTUAL_HOST=mySite.local
```

##### [__app/acquia/Dockerfile__](#dockerfile)

```
FROM ciandtsoftware/acquia:2016-11-08

# installs required package
RUN apt-get update \
    && apt-get install \
                --no-install-recommends \
                --assume-yes \
                make

# defines Drush version
ENV DRUSH_VERSION 8.1.3

# installs Drush
RUN cd /root/ciandt \
    && make install-drush
```

##### [__docker-compose.yml__](#docker-compose)

```
acquia:
  build: ./acquia
  container_name: acquia
  env_file: ../conf/acquia.local.env

nginx:
  image: jwilder/nginx-proxy:latest
  container_name: nginx
  volumes:
    - /var/run/docker.sock:/tmp/docker.sock:ro
  ports:
    - "80:80"
    - "443:443"
```

Then just spin-up your Docker-Compose with the command:

```
docker-compose up -d
```

Inspect Nginx container IP address:

```
docker inspect \
        --format \
        "{{.NetworkSettings.Networks.bridge.IPAddress }}" \
        "nginx"
```

Use the IP address to update __hosts__ file. Let's suppose that was 172.17.0.2.

Then, add an entry to __/etc/hosts__.
> 172.17.0.2 acquia.local

And now, try to access in the browser
> http://acquia.local

Voilà!
Your project now have Nginx and Acquia up and running.
\\o/

* * *

### [Contributing](#contributing)

If you want to contribute, suggest improvements and report issues, please go to our [Bitbucket repository](https://bitbucket.org/ipinatti_cit/docker-hub-acquia).

* * *

Please feel free to drop a message in the comments section.

Happy coding, enjoy!!

"We develop people before we develop software" - Cesar Gon, CEO

* * *
