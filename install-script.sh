#!/bin/bash

# Causes the shell to exit if any subcommand returns a non-zero status
set -e

showhelp() {
    echo "Description: Builds and installs target specified
Usage: -s/--source-dir [source dir], -t/--target [name of target to build/install], -d/--destination-dir [destination dir], -o/--output [output file name in tar.gz]"
    exit
}

if [[ $1 == "" ]]
then
showhelp
fi

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--source-dir)
    SRCDIR=$(realpath "$2")
    shift # past argument
    shift # past value
    ;;
    -d|--destination-dir)
    DESTDIR=$(realpath "$2")
    shift # past argument
    shift # past value
    ;;
    -t|--target)
    TARGET="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--output)
    OUTFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    showhelp
    ;;
    *)
    showhelp
    ;;
esac
done


CUR=$PWD

echo "** Clean/Build..."

echo "SOURCE DIR = ${SRCDIR}"
echo "TARGET = ${TARGET}"
echo "DESTINATION DIR = ${DESTDIR}"
echo "OUTPUT FILE = ${OUTFILE}"

cd "$SRCDIR"
rm -rf .build
case $(uname -s) in
    Linux*)     swift build -c release
                cd .build/release;;
    Darwin*)    swift build -c release --arch arm64 --arch x86_64
                cd .build/apple/Products/Release;;
    *)          echo "unknown destination"
                exit;;
esac

echo "** Install..."

tar -cvzf "$OUTFILE" "$TARGET"

mv "$OUTFILE" "$DESTDIR"

cd "$CUR"

echo "** Output file is at $DESTDIR/$OUTFILE"
echo "** Done."
