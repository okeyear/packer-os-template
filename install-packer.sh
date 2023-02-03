#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export LANG=en
set -e
# stty erase ^H
###########

function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function download_packer(){
    # https://www.packer.io/downloads
    packer_ver=$(get_github_latest_release "hashicorp/packer")
    packer_ver=${packer_ver/v/}
    download_filename="packer_${packer_ver}_windows_amd64.zip"
    [ ! -s "${download_filename}" ] && wget -c "https://releases.hashicorp.com/packer/${packer_ver}/${download_filename}"
}