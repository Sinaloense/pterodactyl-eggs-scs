#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'debian:buster-slim'

##
#
# Variables
# HLDS_GAME - HLDS server game found here - https://developer.valvesoftware.com/wiki/Dedicated_Server_Name_Enumeration
#
##

apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget xz-utils

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
./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update ${HLDS_APPID} +app_set_config 90 mod ${HLDS_GAME} +quit ## other flags may be needed depending on install.

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## for fastdl add read and execute permissions to group
chmod 750 /mnt/server/





## SCS
# Download and extract Metamod-P 1.21p38 in server
mkdir -p /mnt/server/$HLDS_GAME/addons/metamod/dlls/
cd /mnt/server/$HLDS_GAME/addons/metamod/dlls/
metamodP="metamod_i686_linux_win32-1.21p38.tar.xz";
wget https://github.com/Bots-United/metamod-p/releases/download/v1.21p38/$metamodP
tar -xvf $metamodP
rm -f $metamodP
rm -f metamod.dll



# Download and extract Last AMX Mod X 1.9 Base
mkdir -p /mnt/server/$HLDS_GAME/
cd /mnt/server/$HLDS_GAME/
amxxBase="https://www.amxmodx.org/amxxdrop/1.9/$(curl -L https://www.amxmodx.org/amxxdrop/1.9/amxmodx-latest-base-linux)";
wget $amxxBase -O - | tar -xzvf -

# Enable Amx Mod x 1.9
echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' > /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini


## If hlds game is cstrike
if [ $HLDS_GAME = "cstrike" ]; then
    # Download and extract Last AMX Mod X 1.9 Counter-Strike
    mkdir -p /mnt/server/$HLDS_GAME/
    cd /mnt/server/$HLDS_GAME/
    amxxGame="https://www.amxmodx.org/amxxdrop/1.9/$(curl -L https://www.amxmodx.org/amxxdrop/1.9/amxmodx-latest-$HLDS_GAME-linux)";
    wget $amxxGame -O - | tar -xzvf -
fi



# Delete wget history
rm -f /mnt/server/.wget-hsts