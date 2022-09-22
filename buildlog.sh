#!/usr/bin/env bash

set -eu -o pipefail

source get_buildlog.sh
source ./github/install.sh

>build.log
log "$(date +'%Y-%m-%d')\n"
mkdir -p "$BUILD_DIR" "$TEMP_DIR"

get_prebuilts
