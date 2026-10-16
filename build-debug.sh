#!/bin/bash
#: Title       : build-debug.sh
#: Date        : 2020-12-25
#: Author      : Kjetil Kristoffer Solberg <post@ikjetil.no>
#: Version     : 1.0
#: Description : Builds ccat.
# ----------------------------------------
# Helpers
# ----------------------------------------
step() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

# ----------------------------------------
# 1. Build
# ----------------------------------------
step "1. Building ccat in debug mode"

fpc -FE./build -FU./build ./src/ccat.pas -gw3 -gl -O- "$@"
if [[ $? -eq 0 ]]
then
    echo "======= Build process complete ======="
else
    fail "******** Build process error *********"
fi
