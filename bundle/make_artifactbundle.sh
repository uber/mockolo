#!/bin/bash -e

VERSION=$1

usage() {
    echo "[Usage] $0 <VERSION>"
}

if [ "$VERSION" = "" ]; then
    usage
    echo "VERSION is required"
    exit 1
fi

mkdir -p artifactbundle/mockolo/macos
mkdir -p artifactbundle/mockolo/ubuntu/x86_64-unknown-linux-gnu
mkdir -p artifactbundle/mockolo/ubuntu/aarch64-unknown-linux-gnu

tar -xzf mockolo.macos-universal.tar.gz -C artifactbundle/mockolo/macos/
tar -xzf mockolo.ubuntu-x86_64.tar.gz -C artifactbundle/mockolo/ubuntu/x86_64-unknown-linux-gnu/
tar -xzf mockolo.ubuntu-aarch64.tar.gz -C artifactbundle/mockolo/ubuntu/aarch64-unknown-linux-gnu/

sed 's/__VERSION__/'$VERSION'/g' $(dirname $0)/info.json > artifactbundle/info.json

zip -r ./mockolo.artifactbundle.zip ./artifactbundle
