#!/bin/env bash

LOCAL_BIN=""
LOCAL_PATH=""
LOCAL_VERSION=""

REMOTE_URL=""
REMOTE_VERSION=""

function assertBins() {
    for bin in $@; do
        if ! command -v $bin &>/dev/null; then
            echo "Command $bin not found"
            exit 1
        fi
    done
}

function getRelease() {
    if [ -z "$1" ]; then
        echo "Missing program [golang|vscode|dbeaver]"
        exit 1
    fi
    release=$(curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/versions.json | jq ".$1")
    if [ "$release" == "null" ]; then
        echo "Program $1 not found"
        exit 1
    fi
    REMOTE_URL=$(echo $release | jq -r ".artifact_url")
    REMOTE_VERSION=$(echo $release | jq -r ".version")
    echo "Program $1: $REMOTE_VERSION @ $REMOTE_URL"
}

function getLocal() {
    echo "Getting data from local $1 ..."
    bin=$(eval which $1)
    if [ $? != 0 ]; then
        echo "$1 not found locally"
        return
    fi

    LOCAL_BIN=$bin
    LOCAL_PATH=$(eval dirname "$bin")
    LOCAL_VERSION=$(eval $2)
    LOCAL_VERSION=$(echo $LOCAL_VERSION | egrep '[0-9]+\.[0-9]+\.[0-9]+' -o)

    echo "$1 local: $LOCAL_VERSION @ $LOCAL_PATH"
}

function getLocal_golang() {
    getLocal go "go version"
}

function getLocal_vscode() {
    getLocal code "code -v 2>&1 | head -n 1"
}

function getLocal_dbeaver() {
    user=$(logname)
    ws_prop="/home/$user/.local/share/DBeaverData/workspace6/.metadata/dbeaver-workspace.properties"
    getLocal dbeaver "cat $ws_prop | grep \"product-version\" | cut -d \"=\" -f 2"
}

vercomp() {
    if [[ $LOCAL_VERSION == $REMOTE_VERSION ]]; then
        echo "Local version is up-to-date"
        exit 1
    fi
    local IFS=.
    local i ver1=($LOCAL_VERSION) ver2=($REMOTE_VERSION)
    # fill empty fields in ver1 with zeros
    for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i = 0; i < ${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo "Local $LOCAL_VERSION is newer than remote $REMOTE_VERSION"
            exit 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            echo "Newer version $REMOTE_VERSION is available"
            return
        fi
    done
    echo "Local version is up-to-date"
    exit 1
}

function doUpdate_vscode() {
    echo "Updating VSCode to $REMOTE_VERSION"
    curl -L -o /tmp/vscode.deb $REMOTE_URL
    sudo dpkg -i /tmp/vscode.deb
    rm /tmp/vscode.deb
}

function doUpdate_dbeaver() {
    echo "Updating DBeaver to $REMOTE_VERSION"
    curl -L -o /tmp/dbeaver.deb $REMOTE_URL
    sudo dpkg -i /tmp/dbeaver.deb
    rm /tmp/dbeaver.deb
}

function doUpdate_golang() {
    echo "Updating Golang to $REMOTE_VERSION"
    curl -L -o /tmp/go.tar.gz $REMOTE_URL
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
}

assertBins curl jq
getRelease $1
getLocal_$1

vercomp

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

read -p "Do you want to update $1 ${LOCAL_VERSION} -> ${REMOTE_VERSION} [Y/N]?" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

doUpdate_$1

get_local_$1

echo "Update done -> $LOCAL_VERSION"
