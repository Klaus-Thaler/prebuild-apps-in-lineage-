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

echo $(pwd)
cd 
# sample for lineage 19
cd ~/lineage-19.x-build-gsi
pwd

echo $(pwd)
exit
# replace hosts (if you want)
cp ~/myBuiltScripte/BuildMyAndroid/hosts system/core/rootdir/etc/hosts

if [ ! -e prebuilts/mApps ]; then mkdir prebuilts/mApps; fi
if [ ! -e prebuilts/mApps/tmp ]; then mkdir prebuilts/mApps/tmp; fi

# download repo index.xml
wget --connect-timeout=10 https://f-droid.org/repo/index.xml -O prebuilts/mApps/tmp/f-droid_index.xml
wget --connect-timeout=10 https://fdroid.bromite.org/fdroid/repo/index.xml -O prebuilts/mApps/tmp/bromite_index.xml
wget --connect-timeout=10 https://archive.newpipe.net/fdroid/repo/index.xml -O prebuilts/mApps/tmp/newpipe_index.xml

echo -e "/tmp" > prebuilts/mApps/.gitignore
echo -e '\nPRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true\n' >> build/target/product/handheld_product.mk
echo -e 'PRODUCT_PACKAGES += \\' >> build/target/product/handheld_product.mk

downloadFromRepo () {
	mkdir -p prebuilts/mApps/$_name
	echo -e "/$_name" >> prebuilts/mApps/.gitignore
	touch prebuilts/mApps/$_name/Android.mk
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$_app"'"]' -v ./marketvercode prebuilts/mApps/tmp/$_index || true)"
	_apk="$_search"
    if [ ! -f prebuilts/mApps/$_name/$_apk ];then
		echo -e "Download and install -> $_apk\n"
        while ! wget --connect-timeout=10 $_repo/$_apk -O prebuilts/mApps/$_name/$_apk; do sleep 10; echo "install"; done     
    fi
    # apps eintragen
    echo -e "\t$_name \\" >> build/target/product/handheld_product.mk
}

# install Bromite Webview
_repo="https://fdroid.bromite.org/fdroid/repo"
_index="bromite_index.xml"
_name="WebView"
_app="org.bromite.webview"
_arch="arm64-v8a"
_search=`xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[starts-with(nativecode,"'"$_arch"'")][1]' -v ./apkname prebuilts/mApps/tmp/$_index`
downloadFromRepo

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH :=  \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_OVERRIDES_PACKAGES := webview
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
LOCAL_PREBUILT_JNI_LIBS_arm64 := @lib/$_arch/libwebviewchromium.so
include \$(BUILD_PREBUILT)

EOF

# install Bromite HTML-Viewer
_repo="https://fdroid.bromite.org/fdroid/repo"
_index="bromite_index.xml"
_name="Bromite"
_app="org.bromite.bromite"
_arch="arm64-v8a"
_search=`xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[starts-with(nativecode,"'"$_arch"'")][1]' -v ./apkname prebuilts/mApps/tmp/$_index`
downloadFromRepo

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_PRIVILEGED_MODULE := true
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF

# install Neo-Store
_repo="https://f-droid.org/repo"
_index="f-droid_index.xml"
_name="Neo-Store"
_app="com.machiav3lli.fdroid"
_arch="arm64-v8a"
_search=`xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname prebuilts/mApps/tmp/$_index || xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[1]' -v ./apkname prebuilts/mApps/tmp/$_index`
downloadFromRepo

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF

# install DavDroid
_repo="https://f-droid.org/repo"
_index="f-droid_index.xml"
_name="DavDroid"
_app="at.bitfire.davdroid"
_arch="arm64-v8a"
_search=`xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname prebuilts/mApps/tmp/$_index || xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[1]' -v ./apkname prebuilts/mApps/tmp/$_index`
downloadFromRepo

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF

# install NewPipe
_repo="https://archive.newpipe.net/fdroid/repo/"
_index="newpipe_index.xml"
_name="NewPipe"
_app="org.schabi.newpipe"
_arch="arm64-v8a"
_search=`xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname prebuilts/mApps/tmp/$_index || xmlstarlet sel -t -m '//application[id="'"$_app"'"]/package[1]' -v ./apkname prebuilts/mApps/tmp/$_index`
downloadFromRepo

cat > prebuilts/mApps/$_name/Android.mk <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $_name
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $_apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRODUCT_MODULE := true
include \$(BUILD_PREBUILT)

EOF

echo "fine"
exit 0
