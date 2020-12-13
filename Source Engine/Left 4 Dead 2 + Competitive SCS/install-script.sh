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
#
##

apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates git

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
# Download configs in a tmp folder
mkdir -p /mnt/server/ZtMCQm/
rm -Rf /mnt/server/ZtMCQm/*
cd /mnt/server/ZtMCQm/

# Download L4D2-Competitive-Rework
echo "Downloading https://github.com/SirPlease/L4D2-Competitive-Rework.git..."
git clone https://github.com/SirPlease/L4D2-Competitive-Rework.git
# Specific version https://github.com/SirPlease/L4D2-Competitive-Rework/commit/
cd L4D2-Competitive-Rework/
git checkout e8fca1d2fcb09eb32eca5520286517758481db83
cd /mnt/server/ZtMCQm/

# Download left-4-dead-2-competitive-scs
echo "Downloading https://github.com/Sinaloense/left-4-dead-2-competitive-scs.git"
git clone https://github.com/Sinaloense/left-4-dead-2-competitive-scs.git
# Specific version https://github.com/Sinaloense/left-4-dead-2-competitive-scs/commit/
cd left-4-dead-2-competitive-scs/
git checkout 1568d7b975a27f9298b654ababc17635b45860e1
cd /mnt/server/ZtMCQm/

# Merge configs
mkdir competitive/
mv L4D2-Competitive-Rework/addons/ competitive/
mv L4D2-Competitive-Rework/cfg/ competitive/
mv L4D2-Competitive-Rework/scripts/ competitive/
yes | cp -avr left-4-dead-2-competitive-scs/* competitive/



# Backup maps
mkdir -p backup/addons-mapas-custom/
mv /mnt/server/left4dead2/addons/*.vpk backup/addons-mapas-custom/
mv /mnt/server/left4dead2/addons/readme.txt backup/addons-mapas-custom/

# Backup cfgs sourcebans
mkdir -p backup/addons-sourcebans/sourcemod/configs/sourcebans/
mv /mnt/server/left4dead2/addons/sourcemod/configs/databases.cfg backup/addons-sourcebans/sourcemod/configs/
mv /mnt/server/left4dead2/addons/sourcemod/configs/sourcebans/sourcebans.cfg backup/addons-sourcebans/sourcemod/configs/sourcebans/

# Backup cfgs
mkdir -p backup/cfg/sourcemod/
mv /mnt/server/left4dead2/cfg/server.cfg backup/cfg/
mv /mnt/server/left4dead2/cfg/sourcemod/* backup/cfg/sourcemod/

# Backup logs
mkdir -p backup/addons-logs/sourcemod/logs/
mv /mnt/server/left4dead2/addons/sourcemod/logs/* backup/addons-logs/sourcemod/logs/

# Backup mymotd.txt
mv /mnt/server/left4dead2/mymotd.txt backup/



# Delete old cfg
rm -Rf /mnt/server/left4dead2/addons/*
rm -Rf /mnt/server/left4dead2/cfg/cfgogl/
rm -Rf /mnt/server/left4dead2/cfg/sourcemod/
rm -Rf /mnt/server/left4dead2/cfg/stripper/
rm -f /mnt/server/left4dead2/cfg/generalfixes.cfg
rm -f /mnt/server/left4dead2/cfg/server.cfg
rm -f /mnt/server/left4dead2/cfg/sharedplugins.cfg
rm -Rf /mnt/server/left4dead2/scripts/vscripts/



# Put config in server
yes | cp -avr competitive/* /mnt/server/left4dead2/

# Put backup maps in server
mv backup/addons-mapas-custom/* /mnt/server/left4dead2/addons/

# Put backup cfgs sourcebans in server
yes | cp -avr backup/addons-sourcebans/* /mnt/server/left4dead2/addons/

# Put backup cfgs in server
yes | cp -avr backup/cfg/* /mnt/server/left4dead2/cfg/

# Put backup logs in server
mv backup/addons-logs/sourcemod/logs/ /mnt/server/left4dead2/addons/sourcemod/

# Put backup mymotd.txt in server
yes | cp -avr backup/mymotd.txt /mnt/server/left4dead2/

# Delete tmp folder
cd /mnt/server/
rm -Rf ZtMCQm/



# Add maps (Not possible, container dont have access)
#cp -avrn /var/lib/pterodactyl/games/left-4-dead-2/maps/* /mnt/server/left4dead2/addons/