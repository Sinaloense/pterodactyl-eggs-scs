#!/bin/bash
# NodeJS Bot Installation Script
#
# Server Files: /mnt/server
apt update
apt install -y git make gcc g++ python python-dev libtool

mkdir -p /mnt/server
cd /mnt/server

if [[ ! "${USERNAME}" == "" ]]; then
    if [[ ! https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git = *\.git ]]; then
      INSTALL_REPO=$(echo -e https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git | sed 's:/*$::')
      INSTALL_REPO="https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git"
    fi
    
    echo -e "working on installing a discord.js bot from https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git"
    
    if [ "${USER_UPLOAD}" == "true" ] || [ "${USER_UPLOAD}" == "1" ]; then
    	echo -e "assuming user knows what they are doing have a good day."
    	exit 0
    else
    	if [ "$(ls -A /mnt/server)" ]; then
    		echo -e "/mnt/server directory is not empty."
    	     if [ -d .git ]; then
    			echo -e ".git directory exists" 
    			if [ -f .git/config ]; then
    				echo -e "loading info from git config"
    				ORIGIN=$(git config --get remote.origin.url)
    			else
    				echo -e "files found with no git config"
    				echo -e "closing out without touching things to not break anything"
    				exit 10
    			fi
    		fi
    		if [ "${ORIGIN}" == "https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git" ]; then
    			echo "pulling latest from github"
    			git pull 
    		fi
    	else
        	echo -e "/mnt/server is empty.\ncloning files into repo"
    		if [ -z ${INSTALL_BRANCH} ]; then
    			echo -e "assuming master branch"
    			INSTALL_BRANCH=master
    		fi
            
    		echo -e "running 'git clone --single-branch --branch ${INSTALL_BRANCH} https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git .'"
    		git clone --single-branch --branch ${INSTALL_BRANCH} https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}.git .
    	fi
    fi 
else
    if [[ ! ${INSTALL_REPO} = *\.git ]]; then
      INSTALL_REPO=$(echo -e ${INSTALL_REPO} | sed 's:/*$::')
      INSTALL_REPO="${INSTALL_REPO}.git"
    fi
    
    echo -e "working on installing a discord.js bot from ${INSTALL_REPO}"
    
    if [ "${USER_UPLOAD}" == "true" ] || [ "${USER_UPLOAD}" == "1" ]; then
    	echo -e "assuming user knows what they are doing have a good day."
    	exit 0
    else
    	if [ "$(ls -A /mnt/server)" ]; then
    		echo -e "/mnt/server directory is not empty."
    	     if [ -d .git ]; then
    			echo -e ".git directory exists" 
    			if [ -f .git/config ]; then
    				echo -e "loading info from git config"
    				ORIGIN=$(git config --get remote.origin.url)
    			else
    				echo -e "files found with no git config"
    				echo -e "closing out without touching things to not break anything"
    				exit 10
    			fi
    		fi
    		if [ "${ORIGIN}" == "${INSTALL_REPO}" ]; then
    			echo "pulling latest from github"
    			git pull 
    		fi
    	else
        	echo -e "/mnt/server is empty.\ncloning files into repo"
    		if [ -z ${INSTALL_BRANCH} ]; then
    			echo -e "assuming master branch"
    			INSTALL_BRANCH=master
    		fi
            
    		echo -e "running 'git clone --single-branch --branch ${INSTALL_BRANCH} ${INSTALL_REPO} .'"
    		git clone --single-branch --branch ${INSTALL_BRANCH} ${INSTALL_REPO} .
    	fi
    fi 
fi

echo "Installing python requirements into folder"
if [[ ! -z ${NODE_PACKAGES} ]]; then
    /usr/local/bin/npm install ${NODE_PACKAGES}
fi

if [ -f /mnt/server/package.json ]; then
    /usr/local/bin/npm install --production
fi

echo -e "install complete"
exit 0