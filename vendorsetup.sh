#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2021-2023 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#
FDEVICE="sweet_k6a"
TREE_PATH="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

fox_get_target_device() {
local chkdev=$(echo "$BASH_SOURCE" | grep -w \"$FDEVICE\")
   if [ -n "$chkdev" ]; then 
      FOX_BUILD_DEVICE="$FDEVICE"
   else
      chkdev=$(set | grep BASH_ARGV | grep -w \"$FDEVICE\")
      [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
   fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if { [ -z "$1" ] || [ "$1" = "$FDEVICE" ]; } && { [ -z "$FOX_BUILD_DEVICE" ] || [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; }; then
    # initial setup
    export ALLOW_MISSING_DEPENDENCIES=true
    export FOX_BUILD_DEVICE="$FDEVICE"
    export LC_ALL="C"

    # add more builtins
    export FOX_USE_TAR_BINARY=1
    export FOX_USE_SED_BINARY=1
    export FOX_USE_XZ_UTILS=1
    export FOX_USE_NANO_EDITOR=1
    export FOX_USE_BASH_SHELL=1
    export OF_ENABLE_LPTOOLS=1

    # enable app manager
    export FOX_ENABLE_APP_MANAGER=1

    # disable led settings
    export OF_USE_GREEN_LED=0

    # maintainer info
    export OF_MAINTAINER="marat2509"

    # screen info
    export OF_SCREEN_H=2400
    export OF_STATUS_H=93
    export OF_STATUS_INDENT_LEFT=48
    export OF_STATUS_INDENT_RIGHT=48
    export OF_CLOCK_POS=1

    # always enabled navbar
    export OF_ALLOW_DISABLE_NAVBAR=0

    # prevent recovery overwriting
    export OF_PATCH_AVB20=1

    # compability fixes
    export FOX_TARGET_DEVICES="sweet_k6a,sweet"
    export TARGET_DEVICE_ALT=$FOX_TARGET_DEVICES

    # Magisk
    MAGISK_VER=$(curl -fSsl https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep tag_name | sed 's/,//g' | awk '{print $2}' | sed 's/["v]//g')
    MAGISK_ZIP="$(pwd)/vendor/recovery/FoxFiles/Magisk-v$MAGISK_VER.zip"
        if [ ! -e $MAGISK_ZIP ]; then
            echo "I: Downloading Magisk v$MAGISK_VER"
            wget -q -O "$MAGISK_ZIP" "https://github.com/topjohnwu/Magisk/releases/download/v$MAGISK_VER/Magisk-v$MAGISK_VER.apk"
        fi;
    export FOX_USE_SPECIFIC_MAGISK_ZIP=$MAGISK_ZIP

    # delete unneeded addons
    export FOX_DELETE_AROMAFM=1
    export FOX_DELETE_INITD_ADDON=1

    # version meta
    export FOX_BUILD_TYPE=Stable
    export FOX_VERSION=$(git -C $TREE_PATH rev-parse --short origin/HEAD)

    # prevent settings reset
    export FOX_RESET_SETTINGS=0

    # extras
    export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1

    # let's see what are our build VARs
    if [ -n "$FOX_BUILD_LOG_FILE" -a -f "$FOX_BUILD_LOG_FILE" ]; then
       export | grep "FOX" >> $FOX_BUILD_LOG_FILE
       export | grep "OF_" >> $FOX_BUILD_LOG_FILE
       export | grep "TARGET_" >> $FOX_BUILD_LOG_FILE
       export | grep "TW_" >> $FOX_BUILD_LOG_FILE
    fi
else
    if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
        echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
    fi
fi
