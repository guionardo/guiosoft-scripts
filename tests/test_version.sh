#!/usr/bin/env bash

test_parse_version_should_return_0_1_0() {
    source ../src/version.sh
    assert_equals "0 1 0" "$(parse_version 0.1)"
    assert_equals "1 2 3" "$(parse_version 1.2.3)"
}
