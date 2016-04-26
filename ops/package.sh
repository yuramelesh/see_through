#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"

function color() 
{
	local color=$2
	local nc='\033[0m' # No Color
	printf "${color}$1${nc}"
}

function validate {

    git status 1>/dev/null &2>1

    nc -z $PG_HOST $PG_PORT 1>/dev/null 2>&1
    if [ $? -ne 0 ] ; then
        echo "Postgres $PG_HOST:$PG_PORT can't be reached"
        exit 1
    fi

    echo "Postgres $PG_HOST:$PG_PORT is reachable"
}

function validate_host
{
	local msg_host_invalid=`color "Error: host '$1:$2' is invalid." $RED`	

	nc -z $1 $2 1>/dev/null 2>&1
	if [ $? -ne 0 ] ; then
		echo $msg_host_invalid
		exit 1
	fi	
}

function validate_dir
{
	local msg_dir_not_found=`color "Error: dir '$1' not found." $RED`

	[[ -d $1 ]]
	if [ $? -ne 0 ] ; then
		echo $msg_dir_not_found
		exit 1
	fi
}

function validate_file()
{
	msg_file_not_found=`color "Error: file '$1' not found." $RED`	
	
	[[ -e $1 ]]
	if [ $? -ne 0 ] ; then
		echo $msg_file_not_found
		exit 1
	fi
}

while getopts "h:u:k:w:" o; do
    case "${o}" in    
        h)
            DEPLOY_HOST=${OPTARG-$SEE_THROUGH_HOST}
            ;;
        u)
            DEPLOY_USER=${OPTARG-$SEE_THROUGH_USER}
            ;;            
        k)
            DEPLOY_KEY=${OPTARG-$SEE_THROUGH_KEY}
            ;;            
        d)
            LOCAL_DIR=${OPTARG}
            ;;            
        *)
            usage
            ;;
    esac
done


DEPLOY_HOST=${DEPLOY_HOST-$SEE_THROUGH_HOST}
DEPLOY_USER=${DEPLOY_USER-$SEE_THROUGH_USER}
PORT=22
DEPLOY_KEY=${DEPLOY_KEY-$SEE_THROUGH_KEY}

# Local dirs
LOCAL_DIR=${LOCAL_DIR-$PWD}
PACKAGE_DIR="$LOCAL_DIR/package"
OPS_DIR="$LOCAL_DIR/ops"

# Remote dirs
REMOTE_DIR=box
DEPLOY_DIR="$REMOTE_DIR/deploy"
TEMP_DIR=$DEPLOY_DIR"/temp"

validate_host $DEPLOY_HOST $PORT
validate_file $DEPLOY_KEY
validate_dir $LOCAL_DIR

msg_empty=`color "<EMPTY>" $RED`
msg_aborted=`color "Aborted." $RED`
msg_accepted=`color "Accepted." $GREEN`

echo `color "SeeThrough Deployment scenario" $GREEN`
echo 
echo_host=${DEPLOY_USER:-$msg_empty}@${DEPLOY_HOST:-$msg_empty}

echo "Host: $echo_host"
echo "Ssh key: ${DEPLOY_KEY:-$msg_empty}"
echo "Work dir: ${LOCAL_DIR:-$msg_empty}" 
echo "Deployment dir at $echo_host: '${DEPLOY_DIR-$msg_empty}'"

echo
echo "Are these params correct? Press 'y' to accept, any other key to abort"
read -s -n 1 KEY
[ "$KEY" != "y" ] && echo $msg_aborted && exit 1

echo $msg_accepted

# Compiling version into the app
VERSION_SHORT=$(git rev-parse --short HEAD)
VERSION_FULL=$(git rev-parse HEAD)
echo "VERSION_SHORT=\"$VERSION_SHORT\"" > version.rb
echo "VERSION_FULL=\"$VERSION_FULL\"" >> version.rb

# Creating packaged application

mkdir -p $PACKAGE_DIR
packaged_app="$PACKAGE_DIR/see_through_$VERSION_SHORT.zip"
rm -f $packaged_app
zip -rv $packaged_app * -x "db/data.db" ".git" ".idea" "package" "package.sh" "*.*~" 1>/dev/null 2>&1

echo "Packaged to $packaged_app"

echo "Deploying to $DEPLOY_USER@$DEPLOY_HOST ..."

# Create 'deploy' directory
ssh -i $DEPLOY_KEY -p $PORT $DEPLOY_USER@$DEPLOY_HOST mkdir -p $DEPLOY_DIR

# Copy packaged application the 'deploy' directory
scp -rp -P$PORT -i $DEPLOY_KEY $packaged_app "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR"

# Copy setup.sh to the 'deploy' directory
scp -rp -P$PORT -i $DEPLOY_KEY "$OPS_DIR/setup.sh" $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_DIR

# Stage for deployment
ssh -i $DEPLOY_KEY -p $PORT $DEPLOY_USER@$DEPLOY_HOST bash "$DEPLOY_DIR/setup.sh" $REMOTE_DIR "see_through_$VERSION_SHORT.zip"
