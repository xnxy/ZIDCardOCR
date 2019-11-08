#!/bin/sh

#  build.sh
#  
#
#  Created by CNTP on 2019/11/07.
#

export LANG="en_US.UTF-8"

chmod  777 build-ocr-arm.sh

#工程项目路径
projectPath="$(pwd)/../ZIDCardOCRDemo"
#打包的target名称
buildSchemeName="ZScript"
#build configuration
buildConfiguration="Release"

echo "***********************开始build***********************"
echo "当前目录路径-------->${projectPath}"

workspace="ZIDCardOCRDemo.xcworkspace"
#获取xcworkspace
for workitem in `ls ${projectPath}`; do
workspaceDir=${projectPath}"/"$workitem
echo "workspaceDir-------->${workspaceDir}"
if [[ "${workspaceDir##*.}"x = "xcworkspace"x ]]; then
workspace="${workspaceDir}"
break
fi
done

echo "workspace-------->${workspace}"
echo "buildSchemeName-------->${buildSchemeName}"
echo "buildConfiguration-------->${buildConfiguration}"
#xcode9后build不指定任何签名信息
xcodebuild -workspace ${workspace} -scheme "$buildSchemeName" -configuration "$buildConfiguration"
