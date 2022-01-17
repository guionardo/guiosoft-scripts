#!/usr/bin/env bash

BASE_FOLDER="${HOME}/.guiosoft/assistant"
LAST_RUN_FILE="${BASE_FOLDER}/.last_run"
MINIMUM_INTERVAL=$((60 * 15))
SOURCES_URL="https://github.com/guionardo/guiosoft-scripts/raw/main/src/assistant"
CURL_RESULT=0
CURL_FILE=""

function set_last_run() {
    date +"%s" >$LAST_RUN_FILE
}

function can_run_now() {
    if [ -f $LAST_RUN_FILE ]; then
        typeset -i last_run=$(cat $LAST_RUN_FILE)
        typeset -i now=$(date +"%s")
        ((interval = "$now" - "$last_run"))
        if [ "$interval" -gt "$MINIMUM_INTERVAL" ]; then
            return 0
        fi
    else
        return 0
    fi
    exit 1
}

function load {
    file="${BASE_FOLDER}/{$1}"
    if [ ! -f $file ]; then
        url="${SOURCES_URL}/$1"
        echo -n "Downloading: $url"
        tmpfile=$(mktemp load.$1.XXXXXX)
        result=$(eval curl -L -o "$tmpfile" -s -w "%{http_code}" --url "$url")
        if [ "$result" -ne "200" ]; then
            echo " - ERROR $result"
            rm $tmpfile
            exit 1
        fi
        echo " - OK"
        mv $tmpfile $file
        echo "File downloaded to $file"
    fi
    source $file
}

function check_setup {
    if [ ! -d $BASE_FOLDER ]; then
        echo -n "Creating folder $BASE_FOLDER"
        mkdir -p $BASE_FOLDER
        if [ ! -d $BASE_FOLDER ]; then
            echo "Failed operation!"
            exit 1
        fi
    fi
    load "colors.sh"
    load "tools.sh"
}

can_run_now

check_setup
# echo "Can run"
# set_last_run

# check_setup
# check_vscode
