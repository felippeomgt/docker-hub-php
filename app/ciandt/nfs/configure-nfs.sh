#!/usr/bin/env bash

: ' Installs NFS and map folders
    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
APT_GET=$(which apt-get)

# variables
_NFS_SERVER="${NFS_SERVER}"
_NFS_FOLDERS="${NFS_FOLDERS}"

# define required packages
readonly NFS_PACKAGES=" \
          nfs-common \
          "
# install required packages
"${APT_GET}" update \
&& "${APT_GET}" install \
                --no-install-recommends \
                --assume-yes \
                ${NFS_PACKAGES}

# remove apt cache in order to improve Docker image size
"${APT_GET}" clean

# fstab mounting information
_NFS_FOLDERS_ARRAY=(${_NFS_FOLDERS//,/ })
for NFS_FOLDER in ${_NFS_FOLDERS_ARRAY}
do
    _NFS_FOLDER_ARRAY=(${NFS_FOLDER//:/ })
    echo "${_NFS_SERVER}:${_NFS_FOLDER_ARRAY[0]} ${_NFS_FOLDER_ARRAY[1]} nfs rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab
done
