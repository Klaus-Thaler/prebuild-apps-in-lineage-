#!/bin/bash
#
# Copyright (C) 2014 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

echo "######## prebuild #################"

# sample for lineage 19
cd ~/lineage-19.x-build-gsi

# replace hosts (if you want)
cp ~/myBuiltScripte/BuildMyAndroid/hosts system/core/rootdir/etc/hosts

if [ ! -e prebuilts/mApps ]; then mkdir prebuilts/mApps; fi
if [ ! -e prebuilts/mApps/tmp ]; then mkdir prebuilts/mApps/tmp; fi

echo -e "/tmp" > prebuilts/mApps/.gitignore
echo -e '\nPRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true\n' >> build/target/product/handheld_product.mk
echo -e 'PRODUCT_PACKAGES += \\' >> build/target/product/handheld_product.mk

installSystemApk () {
	mkdir -p prebuilts/mApps/$1
	echo -e "/$1" >> prebuilts/mApps/.gitignore
	touch prebuilts/mApps/$1/Android.mk
	for _arch in $3; do
		_apk="$(xmlstarlet sel -t -m '//application[id="'"$2"'"]/package[starts-with(nativecode,"'"$_arch"'")][1]' -v ./apkname prebuilts/mApps/tmp/$_index)"
		echo "$_apk"
		if [ ! -f prebuilts/mApps/$1/$_apk ];then
			echo -e "Download and install -> $_apk\n"
			while ! wget --connect-timeout=10 $_repo/$_apk -O prebuilts/mApps/$1/$_apk; do sleep 10; echo "install"; done     
		fi
	done
    # apps eintragen
    echo -e "\t$1\\" >> build/target/product/handheld_product.mk
}

# download repo bromite index.xml
_repo="https://fdroid.bromite.org/fdroid/repo"
_index="bromite_index.xml"
wget --connect-timeout=10 $_repo/index.xml -O prebuilts/mApps/tmp/$_index

# install Bromite Webview
_name="WebView"
_app="org.bromite.webview"
_arch="arm64-v8a armeabi-v7a"
_override="webview"
installSystemApk $_name $_app $_arch

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH :=  \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_OVERRIDES_PACKAGES := $_override
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
# Only move to /product, if Android 11 or above)
ifeq ( ,\$(filter 24 25 26 27 28 29, \$(PLATFORM_SDK_VERSION)))
LOCAL_PRODUCT_MODULE := true
endif
LOCAL_REQUIRED_MODULES := \\
	libwebviewchromium_loader \\
	libwebviewchromium_plat_support	
LOCAL_MODULE_TARGET_ARCH := arm arm64 x86 x86_64
LOCAL_PREBUILT_JNI_LIBS_arm := @lib/armeabi-v7a/libwebviewchromium.so
LOCAL_PREBUILT_JNI_LIBS_arm64 := @lib/arm64-v8a/libwebviewchromium.so
include \$(BUILD_PREBUILT)
EOF

# install Bromite HTML-Viewer
_name="Bromite"
_app="org.bromite.bromite"
_arch="arm64-v8a armeabi-v7a"
_override="Jelly"
installSystemApk $_name $_app $_arch

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_OVERRIDES_PACKAGES := $_override
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_PRIVILEGED_MODULE := true
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF

# user apps
installUserApk () {
	mkdir -p prebuilts/mApps/$1
	echo -e "/$1" >> prebuilts/mApps/.gitignore
	touch prebuilts/mApps/$1/Android.mk
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$2"'"]' -v ./marketvercode prebuilts/mApps/tmp/$_index || true)"
	_apk="$(xmlstarlet sel -t -m '//application[id="'"$2"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname prebuilts/mApps/tmp/$_index || xmlstarlet sel -t -m '//application[id="'"$2"'"]/package[1]' -v ./apkname prebuilts/mApps/tmp/$_index)"
    if [ ! -f prebuilts/mApps/$1/$_apk ];then
		echo -e "Download and install -> $_apk\n"
        while ! wget --connect-timeout=10 $_repo/$_apk -O prebuilts/mApps/$1/$_apk; do sleep 10; echo "install"; done     
    fi
    # apps eintragen
    echo -e "\t$1 \\" >> build/target/product/handheld_product.mk
    
    cat > prebuilts/mApps/$1/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $1
LOCAL_OVERRIDES_PACKAGES := $3
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF
}

# download repo f-droid index.xml
_repo="https://f-droid.org/repo"
_index="f-droid_index.xml"
wget --connect-timeout=10 $_repo/index.xml -O prebuilts/mApps/tmp/$_index

# install f-droid extra privileg
_name="FDroidPrivilegedExtension"
_app="org.fdroid.fdroid.privileged"
installUserApk $_name $_app "F-Droid"
cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := privapp-permissions-org.fdroid.fdroid.privileged.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := \$(TARGET_OUT_ETC)/permissions
LOCAL_SRC_FILES := \$(LOCAL_MODULE)
include \$(BUILD_PREBUILT)
include \$(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := $_name
LOCAL_SRC_FILES := $_apk
LOCAL_MODULE_CLASS := APPS
LOCAL_PRIVILEGED_MODULE := true
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_REQUIRED_MODULES := privapp-permissions-org.fdroid.fdroid.privileged.xml
include \$(BUILD_PREBUILT)
EOF
cat > prebuilts/mApps/$_name/privapp-permissions-org.fdroid.fdroid.privileged.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="$_app">
        <permission name="android.permission.DELETE_PACKAGES"/>
        <permission name="android.permission.INSTALL_PACKAGES"/>
    </privapp-permissions>
</permissions>
EOF

#installUserApk
# install F-Droid
installUserApk "F-Droid" "org.fdroid.fdroid"

# install Neo Backup
installUserApk "Neo-Backup" "com.machiav3lli.backup" "backup"

# install DavDroid
installUserApk "DavDroid" "at.bitfire.davdroid" ""

# install FairMail
installUserApk "FairMail" "eu.faircode.email" "E-Mail"

# install OpenCamera
installUserApk "OpenCamera" "net.sourceforge.opencamera" "Camera2"

# install KeePassX
installUserApk "KeePassX" "com.kunzisoft.keepass.libre" "keepass"

# install newpipe
_repo="https://archive.newpipe.net/fdroid/repo/"
_index="newpipe_index.xml"
wget --connect-timeout=10 $_repo/index.xml -O prebuilts/mApps/tmp/$_index
installUserApk "NewPipe" "org.schabi.newpipe" ""

echo "fine"
exit 0
