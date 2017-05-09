#!/usr/bin/env bash

: ' Creates and mounts NFS folders
    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# variables
_NFS_FOLDERS="${NFS_FOLDERS}"

# mount NFS folders
_NFS_FOLDERS_ARRAY=(${_NFS_FOLDERS//,/ })
for NFS_FOLDER in ${_NFS_FOLDERS_ARRAY}
do
    _NFS_FOLDER_ARRAY=(${NFS_FOLDER//:/ })
    mkdir -p ${_NFS_FOLDER_ARRAY[1]}
done

mount -a
