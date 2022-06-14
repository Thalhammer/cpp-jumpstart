#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo $0 "<projectname>"
fi

LOWER_NAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
UPPER_NAME=`echo $1 | tr '[:lower:]' '[:upper:]'`

# Stash existing changes (there shouldn't be any, but make sure)
GIT_STASH_MESSAGE="${RANDOM}"
git stash push -m "${GIT_STASH_MESSAGE}"

# Replace jumpstart with lowercase projectname in config files
sed -i "s/jumpstart/$LOWER_NAME/g" CMakeLists.txt test/CMakeLists.txt example/CMakeLists.txt cmake/jumpstart-config.cmake.in
# Replace JUMPSTART with uppercase projectname in config files
sed -i "s/JUMPSTART/$UPPER_NAME/g" CMakeLists.txt test/CMakeLists.txt example/CMakeLists.txt cmake/jumpstart-config.cmake.in
# Rename include/jumpstart to include/$LOWER_NAME
mv include/jumpstart include/$LOWER_NAME
# Rename cmake/jumpstart-config.cmake.in to cmake/$LOWER_PROJECTNAME-config.cmake.in
mv cmake/jumpstart-config.cmake.in cmake/$LOWER_NAME-config.cmake.in

# Add modified files to git and commit
git add CMakeLists.txt test/CMakeLists.txt example/CMakeLists.txt cmake/jumpstart-config.cmake.in cmake/$LOWER_NAME-config.cmake.in include/jumpstart include/$LOWER_NAME
git commit -m "Rename Jumpstart project and remove init script"

# Restore stash (if we stashed anything)
git stash list | grep "${GIT_STASH_MESSAGE}" && git stash pop --index

# Remove self
rm -- "$0"