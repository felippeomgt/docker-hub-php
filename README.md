## CI&T Acquia mimic Docker base image

This is the source code of [CI&T Acquia Docker image](https://hub.docker.com/r/ciandtsoftware/acquia/) hosted at [Docker hub](https://hub.docker.com/).

It contents the source code for building the publicly accessible Docker image and some scripts to easy maintain and update its code.

Our intent is to have a Docker container that mimics Acquia environment with the same version of softwares and OS.

Utilizing Docker technologies that already provides an easy way of spinning up new environments and its dependecies, this image can speed-up developers which different backgrounds and equipments to have a fast local environment allowing them to easily integrate in automated tests and deployment pipelines.

Keeping it short, this image contains a working set of Ubuntu, Apache and PHP. Plus, there are also pre-loaded scripts that can easily customized to install other components if they are required like Drush, Grunt, etc...

* * *

## [*Quick Start*](#quickstart)

__Clone the project code__

```
git clone https://bitbucket.org/ciandt_it/docker-hub-acquia.git
```

__Checkout the latest tag__

By the time this was written it was 2016-11-14, please check if there is a new one.

```
git checkout 2016-11-14
```

__Build__

```
make
```
* * *

## [*Requirements*](#requirements)

Before proceeding please check the required packages below:

 - docker engine => 1.12
 - make
 - grep
 - curl

* * *

## [Software Versions](#software-versions)

These are the currently versions bundled in this image.

Already installed

* Ubuntu 12.04.5
* Apache 2.2
+ PHP 5.6.24 (plus extensions)
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
+ Grunt CLI 1.2.0
    * Compass 1.1.1
* Node.js 0.10.37
+ Ruby 2.3.0
    * Bundler 1.13.6
    * Compass 1.0.3  

* * *

## [Build process](#build-process)

There are some required environment variables that are already pre-defined in Dockerfile to specify software versions for the build step, if you need to modify them, please look for any line starting with __ENV__.

More information about ENV is available at this [link](https://docs.docker.com/engine/reference/builder/#/env).

* * *

## [.env](#env)

Thinking in a multi-stage environment, a file name __.env__ is provided at repository root and it is used to define which set of ENV variables are going to load-up during Docker run.

Default value is:

> __ENVIRONMENT="local"__

It is possible to change to any desired string value. This is just an ordinary alias to load one of configuration files that can exist in __conf__ folder.

Example, if you change it to:

> ENVIRONMENT="__dev__"

When you run the container it will load variables from:

> conf/acquia.__dev__.env

It is an easy way to inject new variables when developing a new script.

* * *

## [Run process](#run-process)

As described in .env section, run will load environment variables from a file.
This approach is better describe in official Docker docs in the [link](https://docs.docker.com/compose/env-file/).

* * *

## [Debug and Shell access](#debug-shell)

Case there is a need of debug or inspect inside the container there are two options to help:

> make debug

and

> make shell

The first one runs the container and attaches __stderr__ and __stdout__ to current terminal and prints relevant information.

Second one runs the container and connects to its shell (bash) with root access. So, you can inspect files, configurations and the whole container environment.

* * *

## [Testing](#testing)

After any modification we strongly recommend to run tests against the container to check if everything is running smoothly.
This can be done with the command:

> make tests

These are simple tests at the moment, therefore, very usefull.

* * *

## [All steps](#all-steps)

Now that you __already__ __read__ the previous steps, you are aware of each function. Having said that, the easisest way of wrapping up everything together is to just run:

> make

or

> make all

This command will __build__, __run__ and __test__ your recently created container.

## [Cleaning up](#cleaning-up)

Since Docker generates tons of layers that can fast outgrow your hard drive, after that you have finished any modification, we encourage to clean up your environment.

There are two commands for this task:

> make clean

That stops the running container, removes it and deletes its Docker image.
This particular one is very usefull when you are performing cjanges and you need to rebuild your container to check for modifications.
In addition, you can combine with __make shell__ for instance, like in this example:

> make clean && make shell

And the second one is:

> make clean-all

Actually, this one calls __make clean__ and then removes Docker dangling images and volumes.
More information about dangling can be found at this [link](https://docs.docker.com/engine/reference/commandline/images/).

* * *

## [How-to](#how-to)

There is a Makefile in the root of the repository with all actions that can be performed.

#### [Build](#how-to-build)

```
make build
```

#### [Run](#how-to-run)

```
make run
```

#### [Test](#how-to-test)

```
make test
```

#### [Debug](#how-to-debug)

```
make debug
```

#### [Shell access](#how-to-shell)

```
make shell
```

#### [Clean](#how-to-clean)

```
make clean
```

#### [Clean All](#how-to-clean-all)

```
make clean-all
```

#### [All - Build / Run / Test](#how-to-all)

```
make all
```

Or simply

```
make
```

* * *

## [CI&T scripts](#scripts)

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
FROM ciandtsoftware/acquia

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

## [More](#more)

Furthermore, there is an additional documentation at our Docker Hub page at https://hub.docker.com/r/ciandtsoftware/acquia/ .

We strongly encourage reading it too!

* * *

Happy coding, enjoy!!

"We develop people before we develop software" - Cesar Gon, CEO
