#!/bin/bash

CURL_RESULT=0
CURL_FILE=""

GOLANG_VERSION='0.0.0'
VSCODE_VERSION='0.0.0'

function curl_get() {
    echo -n "Downloading: $1"
    tmpfile=$(mktemp /tmp/chk_ver.XXXXXX)
    result=$(eval curl -L -o "$tmpfile" -s -w "%{http_code}" --url "$1")
    if [ "$result" -ne "200" ]; then
        echo " - ERRO $result"
    else
        echo " - OK"
    fi
    CURL_RESULT=$result
    CURL_FILE=$tmpfile
}

getversion() {
    [[ "$@" =~ ([0-9]+\.[0-9]{1,2}+\.[0-9]{1,2}) ]] && echo "${BASH_REMATCH[0]}"
}

get_golang_version() {
    curl_get "https://golang.org/dl/"
    if [ "$CURL_RESULT" -eq "200" ]; then
        re='<a class=\"download downloadBox\" href=\"(\/dl\/go.*.linux-amd64.tar.gz)">'
        gourl=$(eval cat "$CURL_FILE" | grep -Eo "$re")
        [[ $gourl =~ href=\"([^\"]*)\" ]] && RELEASE_URL="https://golang.org${BASH_REMATCH[1]}"
        GOLANG_VERSION=$(eval getversion "$RELEASE_URL")
        echo "Golang última release: $GOLANG_VERSION"
    else
        echo "Não foi possível obter a última release do go"
    fi    
}

get_vscode_version(){
    curl_get 'https://code.visualstudio.com/sha?build=stable'
    if [ $CURL_RESULT -eq 200 ]; then
        v=$(cat $CURL_FILE | jq '.products[0].productVersion')
        VSCODE_VERSION=$(eval getversion $v)
        echo "VSCode last release: $VSCODE_VERSION"
    else
    echo "Não foi possível obter a última release do vscode"
    fi
}

get_dbeaver_version(){
    curl_get 'https://api.github.com/repos/dbeaver/dbeaver/releases/latest'
    if [ $CURL_RESULT -eq 200 ]; then
        v=$(cat $CURL_FILE | jq '.tag_name')
        DBEAVER_VERSION=$(eval getversion $v)
        echo "DBeaver last release: $DBEAVER_VERSION"
    else
        echo "Não foi possível obter a última release do dbeaver"        
    fi    
}

get_golang_version
get_vscode_version
get_dbeaver_version