#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'debian:buster-slim'

##
#
# Variables
# SRCDS_GAME - SRCDS server game found here - https://developer.valvesoftware.com/wiki/Dedicated_Server_Name_Enumeration
#
##

apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
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
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /mnt/server +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit ## other flags may be needed depending on install. looking at you cs 1.6

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