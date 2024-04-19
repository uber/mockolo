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

mkdir -p mockolo.artifactbundle/mockolo/macos
mkdir -p mockolo.artifactbundle/mockolo/ubuntu/x86_64-unknown-linux-gnu
mkdir -p mockolo.artifactbundle/mockolo/ubuntu/aarch64-unknown-linux-gnu

tar -xzf mockolo.macos-universal.tar.gz -C mockolo.artifactbundle/mockolo/macos/
tar -xzf mockolo.ubuntu-x86_64.tar.gz -C mockolo.artifactbundle/mockolo/ubuntu/x86_64-unknown-linux-gnu/
tar -xzf mockolo.ubuntu-aarch64.tar.gz -C mockolo.artifactbundle/mockolo/ubuntu/aarch64-unknown-linux-gnu/

sed 's/__VERSION__/'$VERSION'/g' $(dirname $0)/info.json > mockolo.artifactbundle/info.json

zip -r ./mockolo.artifactbundle.zip ./mockolo.artifactbundle
