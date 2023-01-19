#!/usr/bin/env bash

source semver

TEMP_DIR="temp"
BUILD_DIR="build"

if [ "${GITHUB_TOKEN:-}" ]; then GH_HEADER="Authorization: token ${GITHUB_TOKEN}"; else GH_HEADER=; fi
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0"

json_get() { grep -o "\"${1}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/'; }

get_prebuilts() {
	echo "Getting prebuilts"
	local rv_cli_url rv_integrations_url rv_patches rv_patches_changelog rv_patches_dl rv_patches_url
	rv_cli_url=$(gh_req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | json_get 'browser_download_url')
	RV_CLI_JAR="${TEMP_DIR}/${rv_cli_url##*/}"
	log "CLI: ${rv_cli_url##*/}"

	rv_integrations_url=$(gh_req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | json_get 'browser_download_url')
	RV_INTEGRATIONS_APK="${TEMP_DIR}/${rv_integrations_url##*/}"
	log "Integrations: ${rv_integrations_url##*/}"

	rv_patches=$(gh_req https://api.github.com/repos/revanced/revanced-patches/releases/latest -)
	rv_patches_changelog=$(echo "$rv_patches" | json_get 'body' | sed 's/\(\\n\)\+/\\n/g')
	rv_patches_dl=$(json_get 'browser_download_url' <<<"$rv_patches")
	RV_PATCHES_JSON="${TEMP_DIR}/patches-$(json_get 'tag_name' <<<"$rv_patches").json"
	rv_patches_url=$(grep 'jar' <<<"$rv_patches_dl")
	RV_PATCHES_JAR="${TEMP_DIR}/${rv_patches_url##*/}"
	log "Patches: ${rv_patches_url##*/}"
	log "\n${rv_patches_changelog//# [/### [}\n"

	dl_if_dne "$RV_CLI_JAR" "$rv_cli_url"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$rv_integrations_url"
	dl_if_dne "$RV_PATCHES_JAR" "$rv_patches_url"
	dl_if_dne "$RV_PATCHES_JSON" "$(grep 'json' <<<"$rv_patches_dl")"
}

abort() { echo "ABORT: $1" && exit 1; }

req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }
gh_req() { wget -nv -O "$2" --header="$GH_HEADER" "$1"; }
log() { echo -e "$1  " >>build.md; }
get_apk_vers() { req "https://www.apkmirror.com/uploads/?appcategory=${1}" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'; }
get_largest_ver() {
	read -r max
	while read -r v; do
		if ! semver_validate "$max" "$v"; then continue; fi
		if [ "$(semver_cmp "$max" "$v")" = 1 ]; then max=$v; fi
	done
	echo "$max"
}

dl_if_dne() {
	if [ ! -f "$1" ]; then
		echo -e "\nGetting '$1' from '$2'"
		req "$2" "$1"
	fi
}

