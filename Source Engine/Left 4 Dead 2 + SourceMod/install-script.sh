#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'debian:buster-slim'

##
#
# Variables
# STEAM_USER, STEAM_PASS, STEAM_AUTH - Steam user setup. If a user has 2fa enabled it will most likely fail due to timeout. Leave blank for anon install.
# WINDOWS_INSTALL - if it's a windows server you want to install set to 1
# SRCDS_APPID - steam app id found here - https://developer.valvesoftware.com/wiki/Dedicated_Servers_List
# EXTRA_FLAGS - when a server has extra glas for things like beta installs or updates.
# SRCDS_GAME - SRCDS server game found here - https://developer.valvesoftware.com/wiki/Dedicated_Server_Name_Enumeration
#
##

apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget unzip git

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +force_install_dir /mnt/server +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## for fastdl add read and execute permissions to group
chmod 750 /mnt/server/





## SCS
# Download and extract Metamod:Source in server
mkdir -p /mnt/server/$SRCDS_GAME/
cd /mnt/server/$SRCDS_GAME/
metamod="https://mms.alliedmods.net/mmsdrop/1.11/$(curl -L https://mms.alliedmods.net/mmsdrop/1.11/mmsource-latest-linux)";
wget $metamod -O - | tar -xzvf -



# Download and extract Last SourceMod
mkdir -p /mnt/server/$SRCDS_GAME/
cd /mnt/server/$SRCDS_GAME/
sourceMod="https://sm.alliedmods.net/smdrop/1.10/$(curl -L https://sm.alliedmods.net/smdrop/1.10/sourcemod-latest-linux)";
wget $sourceMod -O - | tar -xzvf -



# Download configs in a tmp folder
mkdir -p /mnt/server/ZtMCQm/
rm -Rf /mnt/server/ZtMCQm/*
cd /mnt/server/ZtMCQm/

# Download and extract packets-enviroment-variables in a tmp folder: https://steamcommunity.com/discussions/forum/14/2974028351344359625/
mkdir -p /mnt/server/ZtMCQm/packets-enviroment-variables/
cd /mnt/server/ZtMCQm/packets-enviroment-variables/
wget 'https://drive.google.com/uc?export=download&id=1Uk0FTu6rkj_TaxWwBAfyyWB9vJG1xqUJ' -O packets-enviroment-variables.zip
unzip *.zip
rm -Rf /mnt/server/ZtMCQm/packets-enviroment-variables/*.zip
# Add packets-enviroment-variables to server
chmod -R 755 *
yes | cp -avr /mnt/server/ZtMCQm/packets-enviroment-variables/* /mnt/server/
cd /mnt/server/ZtMCQm/

# Download left-4-dead-2-scs
echo "Downloading https://github.com/Sinaloense/left-4-dead-2-scs.git"
git clone https://github.com/Sinaloense/left-4-dead-2-scs.git
# Specific version https://github.com/Sinaloense/left-4-dead-2-scs/commit/
cd left-4-dead-2-scs/
git checkout 934eb61d60b7b57f8c1c222f88e14acc02909dd4
cd /mnt/server/ZtMCQm/

# Put config in server
yes | cp -avr left-4-dead-2-scs/* /mnt/server/left4dead2/