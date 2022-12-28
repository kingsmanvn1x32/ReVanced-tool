#!/bin/bash

set -eu

rm -f ./github/Tools/sqlite3_arm ./github/Tools/sqlite3_arm64

req() { wget -nv --show-progress -O "$2" --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0" "$1"; }
req "https://github.com/j-hc/sqlite3-android/releases/latest/download/sqlite3-arm" "./.github/Tools/sqlite3_arm"
req "https://github.com/j-hc/sqlite3-android/releases/latest/download/sqlite3-arm64" "./.github/Tools/sqlite3_arm64"
