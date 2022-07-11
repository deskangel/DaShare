#!/bin/bash

BUILD_NUMBER=`cat .build_number`
BUILD_NUMBER=$[BUILD_NUMBER+1]

if [[ "$1" == "-h" ]]; then
    echo "usage: $0 [apk | app | --deploy] [--deploy]"
elif [[ "$1" == "app" ]]; then
    set -x
    sed -Ei '' "s/version: (.*)\+([0-9]+$)/version: \1\+$BUILD_NUMBER/g" pubspec.yaml
    sed -Ei '' "s/static const int COPYRIGHT_DATE = ([0-9]+);$/static const int COPYRIGHT_DATE = 2022;/g" lib/settings.dart
    fvm flutter build appbundle --obfuscate --release --split-debug-info=debug_info/$BUILD_NUMBER
    set +x
elif [[ "$1" == "apk" ]]; then
    set -x
    fvm flutter build apk --obfuscate --release --split-per-abi --split-debug-info=debug_info/$BUILD_NUMBER --build-number $BUILD_NUMBER
    set +x
elif [[ "$1" == "--deploy" || "$1" == "-d" ]]; then
    scp2p30p build/app/outputs/apk/release/app-arm64-v8a-release.apk /root/download/
    exit 0
fi
# Update the build number
echo $BUILD_NUMBER > .build_number

if [[ "$2" == "--deploy" || "$2" == "-d" ]]; then
    scp2p30p build/app/outputs/apk/release/app-arm64-v8a-release.apk /root/download/
fi
