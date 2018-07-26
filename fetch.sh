#!/bin/sh

# print help
help() {
    echo "Usage: $0 <url> <destination>"
}

# help option
if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then
    help
    exit 0
fi

# check for sufficient arguments
if [[ $# < 2 ]]; then
    echo "Error: not enough arguments."
    help
    exit 1
fi

# check if already downloaded
if [ -e "$2" ]; then
    echo "Cached $2"
    exit 0
fi

# autodetect download tool
if [ -z "$DLCMD" ]; then
    DLCMD=$(which wget) ||
        DLCMD=$(which curl) ||
        (echo 'Could not detect wget or curl.'; exit 1)
fi

# detect whether downloader is wget or curl
DLSTYLE=dlcurl
case $(basename "$(echo $DLCMD | awk '{print $NF}')") in
    wget)
        DLSTYLE=dlwget
        ;;
    curl)
        DLSTYLE=dlcurl
        ;;
esac

# download with curl
dlcurl() {
    curl $CURLFLAGS "$1" > "$2" ||
        (echo 'Download failed.'; exit 2)
}

# download with wget
dlwget() {
    wget $WGETFLAGS "$1" -O "$2" ||
        (echo 'Download failed.'; exit 2)
}

# Download file.
$DLSTYLE "$1" "$2"
