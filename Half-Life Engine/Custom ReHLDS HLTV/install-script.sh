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
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget xz-utils unzip

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
./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update 90 +app_set_config 90 mod valve +quit ## other flags may be needed depending on install.

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## for fastdl add read and execute permissions to group
chmod 750 /mnt/server/

# hltv_run
echo '#!/bin/bash
export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
if test -e "hltv"; then
	if test -x "hltv"; then
		./hltv $@
	else
		echo "hltv: binary not executable."
	fi
else
	echo "hltv: file not found."
fi' > /mnt/server/hltv_run
chmod +x /mnt/server/hltv_run

# hltv.cfg
echo 'name "HLTV"
hostname "HLTV"
offlinetext "Sorry, game is delayed. Please try again later."
delay 60.0
maxrate 3500
chatmode 1
serverpassword ""
adminpassword ""
loopcmd 1 60 localmsg "You&apos;re watching HLTV. Visit www.valvesoftware.com" 5 -1 0.85 FFA000FF
signoncommands "voice_scale 2; voice_overdrive 16; volume 0.5; echo Voice adjusted for HLTV"

#connect IP:PORT' > /mnt/server/hltv.cfg




## SCS
# Create empty tmp folder
mkdir -p /mnt/server/ZtMCQm/
rm -Rf /mnt/server/ZtMCQm/*
cd /mnt/server/ZtMCQm/



# Download and extract ReHLDS in a tmp folder
mkdir -p /mnt/server/ZtMCQm/rehlds/
cd /mnt/server/ZtMCQm/rehlds/
curl -Ls https://api.github.com/repos/dreamstalker/rehlds/releases/latest | grep -wo "https.*.zip" | wget -qi -
unzip *.zip bin/linux32/* -d /mnt/server/ZtMCQm/rehlds/

# Add ReHLDS to server
chmod -R 755 *
yes | cp -avr bin/linux32/* /mnt/server/



# Delete wget history
rm -f /mnt/server/.wget-hsts

# Delete tmp folder
cd /mnt/server/
rm -Rf ZtMCQm/