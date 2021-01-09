#!/bin/ash
# FiveM Installation Script
#
# Server Files: /mnt/server
apt update -y
apt install -y tar xz-utils curl git file

mkdir -p /mnt/server/resources

cd /mnt/server

echo "updating citizenfx resource files"
git clone https://github.com/citizenfx/cfx-server-data.git /tmp
cp -Rf /tmp/resources/* resources/ 

RELEASE_PAGE=$(curl -sSL https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/)

if [ "${FIVEM_VERSION}" == "latest" ] || [ -z ${FIVEM_VERSION} ] ; then
    LATEST_RECOMMENDED=$(echo -e "${RELEASE_PAGE}" | grep "LATEST RECOMMENDED" -B1 | grep -Eo 'href=".*/*.tar.xz"' | grep -Eo '".*"' | sed 's/\"//g' | sed 's/\.\///1')
    DOWNLOAD_LINK=$(echo https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${LATEST_RECOMMENDED})
else
    VERSION_LINK=$(echo -e "${RELEASE_PAGE}" | grep -Eo 'href=".*/*.tar.xz"' | grep -Eo '".*"' | sed 's/\"//g' | sed 's/\.\///1' | grep ${FIVEM_VERSION})
    if [ "${VERSION_LINK}" == "" ]; then
        echo -e "defaulting to latest as the version requested was invalid."
    else
        DOWNLOAD_LINK=$(echo https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${VERSION_LINK})
    fi
fi

if [ ! -z "${DOWNLOAD_URL}" ]; then 
    if curl --output /dev/null --silent --head --fail ${DOWNLOAD_URL}; then
        echo -e "link is valid. setting download link to ${DOWNLOAD_URL}"
        DOWNLOAD_LINK=${DOWNLOAD_URL}
    else
        echo -e "link is invalid closing out"
        exit 2
    fi
fi

echo -e "Running curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}"

curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}

echo "Extracting fivem files"

FILETYPE=$(file -F ',' ${DOWNLOAD_LINK##*/} | cut -d',' -f2 | cut -d' ' -f2)
if [ "$FILETYPE" == "gzip" ]; then
    tar xzvf ${DOWNLOAD_LINK##*/}
elif [ "$FILETYPE" == "Zip" ]; then
    unzip ${DOWNLOAD_LINK##*/}
elif [ "$FILETYPE" == "XZ" ]; then
    tar xvf ${DOWNLOAD_LINK##*/}
else
    echo -e "unknown filetype. Exiting"
    exit 2 
fi

rm -rf ${DOWNLOAD_LINK##*/} run.sh

if [ -e server.cfg ]; then
    echo "server config file exists"
else
    echo "Downloading default fivem config"
    curl https://raw.githubusercontent.com/parkervcp/eggs/master/gta/fivem/server.cfg >> server.cfg
fi

mkdir logs/

echo "install complete"