#!/bin/bash

VSCODE_LOCAL_VERSION=""
VSCODE_LOCAL_BIN=""
VSCODE_RELEASE_VERSION=""
VSCODE_RELEASE_HASH=""
VSCODE_RELEASE_URL=""
VSCODE_RELEASE_FILE=""

function get_jq() {
    jq=$(eval which jq)
    if [ $? != 0 ]; then
        echo "js não está disponível. Providencie a instalação (sudo apt install jq)"
        exit 1
    fi
}
function get_vscode_local() {
    echo "Obtendo dados da instalação local"
    bin=$(eval which code)
    if [ $? != 0 ]; then
        echo "Não há vscode instalado localmente"
        return
    fi
    VSCODE_LOCAL_BIN=$bin
    version="$($bin -v 2>&1 | head -n 1)"
    VSCODE_LOCAL_VERSION=$(eval getversion "$version")

    echo "VSCode local: $VSCODE_LOCAL_VERSION @ $VSCODE_LOCAL_BIN"
}

function getversion() {
    [[ "$@" =~ ([0-9]+\.[0-9]{1,2}+\.[0-9]{1,2}) ]] && echo "${BASH_REMATCH[0]}"
}

function get_vscode_release() {
    get_jq
    deb_release=$(curl -s 'https://code.visualstudio.com/sha?build=stable' | jq '.products[] | {version: .productVersion, sha256hash: .sha256hash, name: .platform.prettyname, platform: .platform.os,url:.url} | select(.platform =="linux-deb-x64")')
    VSCODE_RELEASE_URL=$(echo "$deb_release" | jq '. | .url' | sed "s/\"//g")
    VSCODE_RELEASE_HASH=$(echo "$deb_release" | jq ". | .sha256hash" | sed "s/\"//g")
    VSCODE_RELEASE_VERSION=$(echo "$deb_release" | jq ". | .version" | sed "s/\"//g")
}

function download_vscode() {
    if [ -z $VSCODE_RELEASE_URL ]; then
        echo "URL para download não identificada"
        exit 1
    fi
    output=$(basename "$VSCODE_RELEASE_URL")
    expected_sha="${output}.sha"
    echo "$VSCODE_RELEASE_HASH  -" >"$expected_sha"
    curl -L --url "$VSCODE_RELEASE_URL" | tee "$output" | sha256sum -c "$expected_sha"
    if [ $? -eq 0 ]; then
        echo "Download OK"
        VSCODE_RELEASE_FILE=$output
    fi
}

vercomp() {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
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
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

get_vscode_local
get_vscode_release

vercomp $VSCODE_LOCAL_VERSION $VSCODE_RELEASE_VERSION
case $? in
0)
    echo "Versão $VSCODE_LOCAL_VERSION está atualizada"
    ;;
1)
    echo "Versão $VSCODE_LOCAL_VERSION é mais recente do que a da release $VSCODE_RELEASE_VERSION"
    ;;
2)
    echo "Versão $VSCODE_RELEASE_VERSION disponível"
    download_vscode
    ;;
esac

