#!/bin.sh
#iOS-Autobuild
########################################################

#定义变量变量名不加美元符号
PlistBuddy="/usr/libexec/PlistBuddy"

########################################################
#验证参数 共有两个参数 第一个是需要验证的值 第二个是验证的变量名
function verificationVar () {
verValue=$1
flagValue=$2
logVaule=$3
flage=","
if [ $flagValue = $flage  -a  $verValue ]
then
echo "The ${logVaule} = ${verValue} Validation Success"
else
echo "($verValue , $flagValue , $logVaule ),Validation Failure"
exit
fi
}

#验证文件是否存在
function verificationFile () {
verValue=$1
flagValue=$2
logVaule=$3
flage=","
if [ $flagValue = $flage  -a -e $verValue ]
then
echo "The ${logVaule} = ${verValue} file exit "
else
echo "($verValue , $flagValue , $logVaule ),file dont exit"
exit
fi
}

#查找配置文件 配置文件的名称是 脚本文件的文件名+.plist 如果查找不到 脚本则会退出
#查找到后赋值
function getConfig () {
#查找文件
selfFileName=$0
selfFileNamePre=${selfFileName:0:(${#selfFileName}-3)}
confileFileName=""$selfFileNamePre".plist"
configFile=$(find . -name "$confileFileName")
verificationVar $configFile "," "configFile"

#identifier
identifier=$($PlistBuddy -c "Print :identifier" $configFile)
verificationVar $identifier "," "identifier"

#bundleDisplayName
bundleDisplayName=$($PlistBuddy -c "Print :bundleDisplayName" $configFile)
verificationVar $bundleDisplayName "," "bundleDisplayName"

#appName
appName=$($PlistBuddy -c "Print :appName" $configFile)
verificationVar $appName "," "appName"

#version
version=$($PlistBuddy -c "Print :version" $configFile)
verificationVar $version "," "version"

#conf
conf=$($PlistBuddy -c "Print :conf" $configFile)
verificationVar $conf "," "conf"

#xcworkspace
xcworkspace=$($PlistBuddy -c "Print :xcworkspace" $configFile)
verificationVar $xcworkspace "," "xcworkspace"
verificationFile $xcworkspace "," "xcworkspace"
xcodeprojPath=${xcworkspace%/*}
echo $xcodeprojPath

#scheme
scheme=$($PlistBuddy -c "Print :scheme" $configFile)
verificationVar $scheme "," "scheme"

#p12
p12=$($PlistBuddy -c "Print :p12" $configFile)
verificationVar $p12 "," "p12"
verificationFile $p12 "," "p12"

#p12Password p12密码 不验证
p12Password=$($PlistBuddy -c "Print :p12Password" $configFile)
if [[ -z $p12Password ]]; then
p12Password=""
echo "p12 has no password!"
fi

#mobileprovisionFile
mobileprovisionFile=$($PlistBuddy -c "Print :mobileprovisionFile" $configFile)
verificationVar $mobileprovisionFile "," "mobileprovisionFile"
verificationFile $mobileprovisionFile "," "mobileprovisionFile"

#描述文件
PROVISIONING_PROFILE=$mobileprovisionFile

#infoPlist
plistFile=$($PlistBuddy -c "Print :plistInfo" $configFile)
verificationVar $plistFile "," "plistInfo"
verificationFile $plistFile "," "plistInfo"

#一些文件夹的设置
initDir=$(pwd)
commitID=$(git rev-parse HEAD | awk '{print substr($1,1,8)}')
echo "${commitID}-----"
ipaNamePre="${appName}_${version}_${commitID}"
ipaNamePre=${ipaNamePre//./_}

#dsym文件存放位置
DSYMDir=${initDir}/${version}/DSYM
DSYMBackupPathName=""$ipaNamePre".app.dSYM"
DSYMBackupPath="${initDir}/dSYM/${DSYMBackupPathName}"
echo $DSYMBackupPath
#ipa文件存放位置
ipaDir=${initDir}/${version}/IPA
ipaName=""$ipaNamePre".ipa"
ipapath="${ipaDir}/${ipaName}"
echo $ipapath
#appFile存放位置
appDir=${initDir}/${version}/AppFile
appName="${ipaNamePre}.app"
appFilePath="${appDir}/${appName}"
echo $appFilePath
#编译环境的配置
releaseDir="${HOME}/Library/Developer/Xcode/DerivedData/Build/Products/Debug-iphoneos"
#plist文件位置
buildDir=${initDir}/${version}/BuildDir
#创建文件夹
mkdir -p "$DSYMDir"
mkdir -p "$ipaDir"
mkdir -p "$appDir"
mkdir -p "$buildDir"
}

function setConfig () {
#version
$PlistBuddy -c "Set :CFBundleShortVersionString $version" $plistFile
$PlistBuddy -c "Set :CFBundleName ${bundleDisplayName}" $plistFile
$PlistBuddy -c "Set :CFBundleIdentifier ${identifier}" $plistFile

openssl smime -in ${PROVISIONING_PROFILE} -inform der -verify > profile || exit $?
echo "证书导入成功"

UUID=$(${PlistBuddy} -c "Print UUID" profile)
echo $UUID
lib_profile="${HOME}/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"
test ! -e "${lib_profile}" && open ${PROVISIONING_PROFILE}
Profile_UUID="PROVISIONING_PROFILE=${UUID}"
rm profile
echo $Profile_UUID
args=${args:+GCC_PREPROCESSOR_DEFINITIONS=$args}
}

function pkgAction () {
cd $xcodeprojPath
find . -name "AppIcon*" -exec touch {} \;
xcodebuild clean -configuration  $conf
cd ${initDir}
xcodebuild -workspace $xcworkspace  -scheme  $scheme  -configuration $conf  -archivePath ${buildDir}/${ipaNamePre}.xcarchive archive -sdk iphoneos ${Profile_UUID} ${args} || exit $?
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${buildDir}/${ipaNamePre}.xcarchive/Products/Applications/${scheme}.app" -o "${ipapath}" ${args} || exit $?
cp -r ${buildDir}/${ipaNamePre}.xcarchive/dSYMs/ShouldWin.app.dSYM  ${DSYMBackupPath}
cp -r ${buildDir}/${ipaNamePre}.xcarchive/Products/Applications/ShouldWin.app ${appFilePath}

open ${ipaDir}
echo sucessful!
}

getConfig
setConfig
pkgAction

