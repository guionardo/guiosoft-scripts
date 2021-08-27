#!/bin/bash

RELEASE_VERSION=""
RELEASE_URL=""
RELEASE_FILENAME=""
LOCAL_VERSION=""
LOCAL_BIN=""
LOCAL_PATH=""
ERRO=0
CURL_RESULT=0
CURL_FILE=""

function curl_get() {
    echo -n "Downloading: $1"
    tmpfile=$(mktemp /tmp/install_golang.XXXXXX)
    result=$(eval curl -L -o "$tmpfile" -s -w "%{http_code}" --url "$1")
    if [ "$result" -ne "200" ]; then
        echo " - ERRO $result"
    else
        echo " - OK"
    fi
    CURL_RESULT=$result
    CURL_FILE=$tmpfile
}

function verifica_env() {
    env | grep "$LOCAL_PATH"
    if [ $? -eq 0 ]; then
        echo "Path OK para $LOCAL_PATH"
        return
    fi
    echo "export PATH=\$PATH:$LOCAL_PATH" >> ~/.bashrc
    echo "Path atualizado em .bashrc"
}

function get_release() {
    echo "Obtendo dados da última release..."
    curl_get "https://golang.org/dl/"
    if [ "$CURL_RESULT" -eq "200" ]; then
        re='<a class=\"download downloadBox\" href=\"(\/dl\/go.*.linux-amd64.tar.gz)">'
        gourl=$(eval cat "$CURL_FILE" | grep -Eo "$re")
        [[ $gourl =~ href=\"([^\"]*)\" ]] && RELEASE_URL="https://golang.org${BASH_REMATCH[1]}"
        RELEASE_VERSION=$(eval getversion "$RELEASE_URL")
        RELEASE_FILENAME=$(eval basename "$RELEASE_URL")
        echo "Golang última release: $RELEASE_VERSION"
    else
        echo "Não foi possível obter a última release do go"
    fi
    unlink $CURL_FILE
}

function get_local() {
    echo "Obtendo dados da instalação local..."
    bin=$(eval which go)
    if [ $? != 0 ]; then
        echo "Não há golang instalado localmente"
        return
    fi

    LOCAL_BIN=$bin
    LOCAL_PATH=$(eval dirname $bin)
    LOCAL_PATH=$(eval dirname $LOCAL_PATH)
    version="$(eval $bin version)"
    LOCAL_VERSION=$(eval getversion "$version")

    echo "Golang local: $LOCAL_VERSION @ $LOCAL_PATH"
}

function backup_local() {
    if [ -z $LOCAL_PATH ]; then
        return
    fi
    folder_backup="${LOCAL_PATH}_$LOCAL_VERSION"
    echo "Efetuando backup $LOCAL_PATH -> $folder_backup"
    if sudo mv -v $LOCAL_PATH $folder_backup | grep -q .; then
        return
    fi
    echo "Erro ao efetuar o backup para $folder_backup"
    ERRO=1
}

function download_golang() {
    curl_get "$RELEASE_URL"
    if [ $CURL_RESULT -ne 200 ]; then
        ERRO=1
        unlink $CURL_FILE
        return
    fi
}

function untar_golang() {
    install_path=$(eval dirname "$LOCAL_PATH")
    if sudo tar -C $install_path -xzf "$CURL_FILE"; then
        return
    fi
    echo "Erro ao descompactar o arquivo"
    ERRO=1
}
function download_and_untar() {
    curl_get "$RELEASE_URL"
    if [ $CURL_RESULT -ne 200 ]; then
        ERRO=1
        unlink $CURL_FILE
        return
    fi
    install_path=$(eval dirname "$LOCAL_PATH")
    if sudo tar -C "$install_path" -xzf "$CURL_FILE"; then
        return
    fi
    echo "Erro ao descompactar o arquivo"
    ERRO=1

    unlink "$CURL_FILE"
}

function getversion() {
    [[ "$@" =~ ([0-9]+\.[0-9]{1,2}) ]] && echo "${BASH_REMATCH[0]}"
}

get_release
get_local

if [ -n $LOCAL_BIN ]; then
    if [ "$RELEASE_VERSION" == "$LOCAL_VERSION" ]; then
        echo "Você já tem a última release do golang"
        exit 0
    fi
    read -p "Deseja atualizar o golang ${LOCAL_VERSION} -> ${RELEASE_VERSION} [S/N]?" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 0
    fi
    backup_local
    if [ $ERRO -ne 0 ]; then
        exit 1
    fi
else
    read -p "Deseja instalar o golang ${RELEASE_VERSION} [S/N]?" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 0
    fi
fi

download_golang
if [ $ERRO -ne 0 ]; then
    exit 1
fi
untar_golang
if [ $ERRO -ne 0 ]; then
    exit 1
fi

get_local
echo "Golang atualizado para versão ${LOCAL_VERSION}"

verica_env

exit 0
