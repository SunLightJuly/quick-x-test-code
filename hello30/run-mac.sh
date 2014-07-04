#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BIN="$DIR/proj.mac/bin/hello30.app/Contents/MacOS/hello30"
if [ ! -f $BIN ]; then
    echo "PLEASE BUILD proj.mac/hello30.xcodeproj FIRST"
    exit
fi

echo $QUICK_V3_ROOT

ARG="-relaunch-off -quick $QUICK_V3_ROOT/quick -workdir $DIR"
SIZE="-portrait"
CMD="$BIN $ARG $SIZE"

until $CMD; do
    echo ""
    echo "------------------------------------------------------"
    echo ""
    echo ""
    echo ""
done
