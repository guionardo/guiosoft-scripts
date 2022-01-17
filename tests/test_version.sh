#!/usr/bin/env bash

test_parse_version_should_return_0_1_0() {
    SRC=${SRC:-"../src"}
    echo "SRC=$SRC"
    tree .
    source $SRC/version.sh
    assert_equals "0 1 0" "$(parse_version 0.1)"
}
