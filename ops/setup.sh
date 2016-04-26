#!/bin/bash

HOME_DIR=$1

DEPLOY_DIR="$HOME_DIR/deploy"
PACKAGED_APP="$DEPLOY_DIR/$2"
TEMP_DIR="$DEPLOY_DIR/temp"
unzip -o $PACKAGED_APP -d $TEMP_DIR -x "setup.sh" 1>/dev/null 2>&1

echo "Provisioning environment variables"
echo "export SEE_THROUGH_HOME=`readlink -f $TEMP_DIR`" > $HOME_DIR/.env

echo "Staging a Vagrant box ..."
if [ ! -f $HOME_DIR/Vagrantfile ]; then
<<<<<<< HEAD
    vagrant init ubuntu/trusty32
=======
    vagrant init ubuntu/trusty32   
>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
fi

cp -u "$TEMP_DIR/Vagrantfile" box/

echo "Done."