#! /bin/sh

#  build.sh
#  Build ios universal dynamic framework.
#  Created by CNTP on 2019/11/07.
#  Copyright © 2019 TP. All rights reserved.

set -e
set +u
### Avoid recursively calling this script.
if [[ $UF_MASTER_SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export UF_MASTER_SCRIPT_RUNNING=1
### Constants.
UF_TARGET_NAME=${PRODUCT_NAME}
FRAMEWORK_VERSION="A"
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
IPHONE_DEVICE_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos
#IPHONE_SIMULATOR_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator
### Functions
## List files in the specified directory, storing to the specified array.
#
# @param $1 The path to list
# @param $2 The name of the array to fill
#
##
list_files ()
{
filelist=$(ls "$1")
while read line
do
eval "$2[\${#$2[*]}]=\"\$line\""
done <<< "$filelist"
}
### Take build target.
if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
SF_SDK_PLATFORM=${BASH_REMATCH[1]} # "iphoneos" or "iphonesimulator".
echo "SF_SDK_PLATFORM=$SF_SDK_PLATFORM"
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

### Build simulator platform. (i386, x86_64)
#echo "========== Build Simulator Platform =========="
#echo "===== Build Simulator Platform: i386 ====="
#xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${IPHONE_SIMULATOR_BUILD_DIR}/i386" SYMROOT="${SYMROOT}" ARCHS='i386' VALID_ARCHS='i386' $ACTION

#echo "===== Build Simulator Platform: x86_64 ====="
#xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${IPHONE_SIMULATOR_BUILD_DIR}/x86_64" SYMROOT="${SYMROOT}" ARCHS='x86_64' VALID_ARCHS='x86_64' $ACTION

### Build device platform. (armv7, arm64)
echo "========== Build Device Platform =========="
echo "===== Build Device Platform: armv7 ====="
xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphoneos BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}"  CONFIGURATION_BUILD_DIR="${IPHONE_DEVICE_BUILD_DIR}/armv7" SYMROOT="${SYMROOT}" ARCHS='armv7' VALID_ARCHS='armv7' -UseModernBuildSystem=NO $ACTION

echo "===== Build Device Platform: arm64 ====="
xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk iphoneos BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${IPHONE_DEVICE_BUILD_DIR}/arm64" SYMROOT="${SYMROOT}" ARCHS='arm64'  VALID_ARCHS='arm64' -UseModernBuildSystem=NO $ACTION

### Build device platform. (arm64, armv7)
echo "========== Build Universal Platform =========="
## Copy the framework structure to the universal folder (clean it first).
rm -rf "${UNIVERSAL_OUTPUTFOLDER}"
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
## Copy the last product files of xcodebuild command.
cp -R "${IPHONE_DEVICE_BUILD_DIR}/arm64/${PRODUCT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework"
echo "Smash them together to combine all architectures."
lipo -create  "${BUILD_DIR}/${CONFIGURATION}-iphoneos/armv7/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/arm64/${PRODUCT_NAME}.framework/${PRODUCT_NAME}" -output "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

# base dir
basedir=$(dirname ${SRCROOT})
echo $basedir
# dynamic framework output dir
outputdir=${basedir}/Framework
echo $outputdir
# dynamic framework output path
echo "${outputdir}/${PRODUCT_NAME}.framework"
# delete same name dynamic framework in output dir
rm -rf "${outputdir}/${PRODUCT_NAME}.framework"
# copy file
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework" "${outputdir}/${PRODUCT_NAME}.framework"
### Open the universal folder.
open "${outputdir}"
