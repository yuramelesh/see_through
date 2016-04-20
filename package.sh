#!/bin/bash

VERSION_SHORT=$(git rev-parse --short HEAD)
VERSION_FULL=$(git rev-parse HEAD)

echo $VERSION_SHORT > version.txt
echo $VERSION_FULL >> version.txt

zip -r see_through_$VERSION_SHORT * -x ".git" -x ".idea" -x "package.sh" -x "*.sh~"