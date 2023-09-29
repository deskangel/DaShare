#!/bin/bash

BUILD_NUMBER=`cat .build_number`
BUILD_NUMBER=$[BUILD_NUMBER+1]

YEAR_NUMBER=`date +"%Y"`

###################################################################

OPT_APP_FORMAT=""
OPT_DEPLOYMENT=""
OPT_UPLOAD=""
BUILD_RESULT=0

for optname in "$@"
do
    case $optname in
        app)
            OPT_APP_FORMAT="app"
            ;;
        apk)
            OPT_APP_FORMAT="apk"
            ;;
        -d)
            OPT_DEPLOYMENT="-d"
            ;;
        -u)
            OPT_UPLOAD="-u"
            ;;
        -h)
            echo "usage: $0 [apk | app] [-d]"
            exit 0
            ;;
    esac
done

clrecho() {
    printf "\e[38;5;196m$1\e[0m\n"
}

###################################################################


if [[ "$OPT_APP_FORMAT" == "app" ]]; then
    set -x
    sed -Ei '' "s/version: (.*)\+([0-9]+$)/version: \1\+$BUILD_NUMBER/g" pubspec.yaml
    sed -Ei '' "s/static const int COPYRIGHT_DATE = ([0-9]+);$/static const int COPYRIGHT_DATE = $YEAR_NUMBER;/g" lib/settings.dart

    fvm flutter build appbundle --obfuscate --release --split-debug-info=debug_info/$BUILD_NUMBER
    BUILD_RESULT=$?

    set +x
    # Update the build number
    echo $BUILD_NUMBER > .build_number
elif [[ "$OPT_APP_FORMAT" == "apk" ]]; then
    fvm flutter build apk --obfuscate --release --split-per-abi --split-debug-info=debug_info/$BUILD_NUMBER --build-number $BUILD_NUMBER
    BUILD_RESULT=$?

    if [[ $BUILD_RESULT == 0 ]]; then
        # Update the build number
        echo $BUILD_NUMBER > .build_number

        open "build/app/outputs/bundle/release"
    else
        clrecho "Failed to build the $OPT_APP_FORMAT"
        return;
    fi
fi

if [[ $BUILD_RESULT == 0 && $OPT_DEPLOYMENT == "-d" ]]; then
    scp2p30p build/app/outputs/apk/release/app-arm64-v8a-release.apk /root/download/
fi

if [[ $BUILD_RESULT == 0 && $OPT_UPLOAD == "-u" ]]; then
    local VERSION_NUM=`awk '/version:/ {gsub(/.*: /,"",$0); gsub(/\+.*/,"",$0); print $0}' pubspec.yaml`
    scp2da build/app/outputs/apk/release/app-arm64-v8a-release.apk "~/dashare/download/dashare-v${VERSION_NUM}.apk"
fi

