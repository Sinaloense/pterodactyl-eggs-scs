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
./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update ${HLDS_APPID} +app_set_config 90 mod ${HLDS_GAME} +quit ## other flags may be needed depending on install.

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## for fastdl add read and execute permissions to group
chmod 750 /mnt/server/





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



## If hlds game is cstrike
if [ $HLDS_GAME = "cstrike" ]; then
    # Download and extract ReGameDLL_CS in a tmp folder
    mkdir -p /mnt/server/ZtMCQm/regamedll-cs/
    cd /mnt/server/ZtMCQm/regamedll-cs/
    curl -Ls https://api.github.com/repos/s1lentq/ReGameDLL_CS/releases/latest | grep -wo "https.*.zip" | wget -qi -
    unzip *.zip bin/linux32/* -d /mnt/server/ZtMCQm/regamedll-cs/

    # Add ReGameDLL_CS to server
    chmod -R 755 *
    yes | cp -avr bin/linux32/* /mnt/server/
fi



# Download and extract Metamod-R in a tmp folder
mkdir -p /mnt/server/ZtMCQm/metamod-r/
cd /mnt/server/ZtMCQm/metamod-r/
curl -Ls https://api.github.com/repos/theAsmodai/metamod-r/releases/latest | grep -wo "https.*.zip" | wget -qi -
unzip *.zip addons/* -d /mnt/server/ZtMCQm/metamod-r/
rm -f addons/metamod/metamod.dll

# Add Metamod-R to server
chmod -R 755 *
mkdir -p /mnt/server/$HLDS_GAME/
yes | cp -avr /mnt/server/ZtMCQm/metamod-r/addons/ /mnt/server/$HLDS_GAME/



# Download and extract Reunion in a tmp folder
mkdir -p /mnt/server/ZtMCQm/reunion/
cd /mnt/server/ZtMCQm/reunion/
wget https://dev-cs.ru/resources/68/download -O reunion.zip
unzip *.zip

# Replace Reunion config
sed -i 's/cid_RevEmu = 1/cid_RevEmu = 8/g' reunion.cfg
sed -i 's/cid_RevEmu2013 = 1/cid_RevEmu2013 = 8/g' reunion.cfg
sed -i 's/cid_SC2009 = 1/cid_SC2009 = 8/g' reunion.cfg
sed -i 's/cid_OldRevEmu = 1/cid_OldRevEmu = 8/g' reunion.cfg
sed -i 's/cid_SteamEmu = 1/cid_SteamEmu = 8/g' reunion.cfg
sed -i 's/cid_AVSMP = 1/cid_AVSMP = 8/g' reunion.cfg
sed -i 's/cid_Setti = 3/cid_Setti = 8/g' reunion.cfg
sed -i 's/cid_SXEI = 1/cid_SXEI = 8/g' reunion.cfg
sed -i 's/cid_SSE3 = 1/cid_SSE3 = 8/g' reunion.cfg
sed -i 's/ServerInfoAnswerType = 0/ServerInfoAnswerType = 2/g' reunion.cfg
sed -i 's/PGen_Prefix2 = 4/PGen_Prefix2 = 8/g' reunion.cfg
sed -i 's/AVSMP_Prefix1 = 4/AVSMP_Prefix1 = 8/g' reunion.cfg

# Add Reunion to server
chmod -R 755 *
mkdir -p /mnt/server/$HLDS_GAME/addons/reunion/
yes | cp -avr reunion.cfg /mnt/server/
yes | cp -avr bin/Linux/* /mnt/server/$HLDS_GAME/addons/reunion/

# Enable Reunion
echo 'linux addons/reunion/reunion_mm_i386.so' > /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini



# Download and extract VoiceTranscoder in a tmp folder
mkdir -p /mnt/server/ZtMCQm/VoiceTranscoder/
cd /mnt/server/ZtMCQm/VoiceTranscoder/
curl -Ls https://api.github.com/repos/WPMGPRoSToTeMa/VoiceTranscoder/releases/latest | grep -wo "https.*.zip" | wget -qi -
unzip *.zip
rm -f addons/VoiceTranscoder/VoiceTranscoder.dll

# Add VoiceTranscoder to server
chmod -R 755 *
mkdir -p /mnt/server/$HLDS_GAME/
yes | cp -avr /mnt/server/ZtMCQm/VoiceTranscoder/addons/ /mnt/server/$HLDS_GAME/

# Enable VoiceTranscoder
echo 'linux addons/VoiceTranscoder/VoiceTranscoder.so' >> /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini



# Download and extract ReAuthCheck in a tmp folder
mkdir -p /mnt/server/ZtMCQm/reauthcheck/
cd /mnt/server/ZtMCQm/reauthcheck/
wget 'https://drive.google.com/uc?export=download&id=1mjdbGgIA91s2jheMeJQhmpa8VpvyM0gK' -O reauthcheck.zip
unzip *.zip

# Add ReAuthCheck to server
chmod -R 755 *
yes | cp -avr /mnt/server/ZtMCQm/reauthcheck/addons/ /mnt/server/$HLDS_GAME/

# Enable ReAuthCheck
echo 'linux addons/reauthcheck/reauthcheck_mm_i386.so' >> /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini



# Download and extract SafeNameAndChat in a tmp folder
mkdir -p /mnt/server/ZtMCQm/SafeNameAndChat/
cd /mnt/server/ZtMCQm/SafeNameAndChat/
wget https://dev-cs.ru/resources/806/download -O SafeNameAndChat.zip
unzip *.zip
rm -f /mnt/server/ZtMCQm/SafeNameAndChat/addons/SafeNameAndChat/SafeNameAndChat.dll

# Add SafeNameAndChat to server
chmod -R 755 *
yes | cp -avr /mnt/server/ZtMCQm/SafeNameAndChat/addons/ /mnt/server/$HLDS_GAME/

# Enable SafeNameAndChat
echo 'linux addons/SafeNameAndChat/SafeNameAndChat.so' >> /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini



# Download and extract ReChecker in a tmp folder
mkdir -p /mnt/server/ZtMCQm/rechecker/
cd /mnt/server/ZtMCQm/rechecker/
wget 'https://drive.google.com/uc?export=download&id=1WevItCRYzO84n1Iu1l7ufUxTO9n-wMBB' -O rechecker.zip
unzip *.zip

# Add ReChecker to server
chmod -R 755 *
yes | cp -avr /mnt/server/ZtMCQm/rechecker/addons/ /mnt/server/$HLDS_GAME/

# Enable ReChecker
echo 'linux addons/rechecker/rechecker_mm_i386.so' >> /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini



## If hlds game is cstrike
if [ $HLDS_GAME = "cstrike" ]; then
    # Download and extract ReAPI in a tmp folder
    mkdir -p /mnt/server/ZtMCQm/reapi/
    cd /mnt/server/ZtMCQm/reapi/
    curl -Ls https://api.github.com/repos/s1lentq/reapi/releases/latest | grep -wo "https.*.zip" | wget -qi -
    unzip *.zip
    rm -f addons/amxmodx/modules/reapi_amxx.dll

    # Add ReAPI to server
    chmod -R 755 *
    mkdir -p /mnt/server/$HLDS_GAME/
    yes | cp -avr /mnt/server/ZtMCQm/reapi/addons/ /mnt/server/$HLDS_GAME/
fi



# Download and extract Last AMX Mod X 1.9 Base
mkdir -p /mnt/server/$HLDS_GAME/
cd /mnt/server/$HLDS_GAME/
amxxBase="https://www.amxmodx.org/amxxdrop/1.9/$(curl -L https://www.amxmodx.org/amxxdrop/1.9/amxmodx-latest-base-linux)";
wget $amxxBase -O - | tar -xzvf -

# Enable Amx Mod x 1.9
echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' >> /mnt/server/$HLDS_GAME/addons/metamod/plugins.ini


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

# Delete tmp folder
cd /mnt/server/
rm -Rf ZtMCQm/