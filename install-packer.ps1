function get_github_latest_release([string]$repo) {
    $res = Invoke-WebRequest -SkipCertificateCheck -Uri "https://api.github.com/repos/$repo/releases/latest" 
    return (ConvertFrom-Json -InputObject $res.Content).tag_name
}

function download_packer(){
    # https://www.packer.io/downloads
    packer_ver=$(get_github_latest_release "hashicorp/packer")
    packer_ver=${packer_ver/v/}
    download_filename="packer_${packer_ver}_windows_amd64.zip"
    [ ! -s "${download_filename}" ] && wget -c "https://releases.hashicorp.com/packer/${packer_ver}/${download_filename}"
}