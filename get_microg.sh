#!/bin/bash

set -eu

rm -f ./github/Tools/Microg.apk

req() { wget -nv --show-progress -O "$2" --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0" "$1"; }
req "https://github.com/inotia00/VancedMicroG/releases/latest/download/microg.apk" "./.github/Tools/Microg.apk"
