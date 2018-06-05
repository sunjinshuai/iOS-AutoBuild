# iOS-AutoBuild

<p align='left'>
<img src="https://img.shields.io/badge/build-passing-brightgreen.svg">
<img src="https://img.shields.io/badge/language-shell-orange.svg">
<img src="https://img.shields.io/badge/made%20with-%3C3-red.svg">
</p>

## 一、背景

在实际开发中，需要不停的打各种包，开发人员忙于新需求实现，打包时重复而且没有意义的事情。于是造了这个轮子，配置好参数一键上传到内测网站(蒲公英、Fir等)或者APPStore;

## 二、Requirements 要求
* Xcode 8+

## 三、Usage 使用方法
```
step 1. 将AutoPackageScript整个文件夹拖入到项目主目录,项目主目录,项目主目录~~~(重要的事情说3遍!😊😊😊)
step 2. 配置该脚本;
step 2. cd 该脚本目录，运行chmod +x XCodeAutoBuild.sh;
step 3. 运行 sh XCodeAutoBuild.sh;
step 4. 选择不同选项....
step 5. Success  🎉 🎉 🎉!
```

## 四、配置脚本

![配置脚本](https://github.com/iOS-Advanced/iOS-Advanced/blob/master/resource/shell.png)

## 五、构建

![构建](https://github.com/iOS-Advanced/iOS-Advanced/blob/master/resource/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-06-05%20%E4%B8%8A%E5%8D%8810.17.45.png)

## 六、功能

* 支持 xcworkspace 和 xcodeproj 两种类型的工程；
* 可以自动化清理、编译、构建工程导出 ipa；
* 支持 Debug 和 Release；
* 支持导出 app-store, ad-hoc, enterprise, development 的包；
* 支持自动上传到蒲公英或者 Fir 等内测网站；

## 七、注意事项

自动生成 ExportOptions.plist

```
# 指定导出ipa包需要用到的plist配置文件的路径
__ExportOptionsPlistPath=${__PROGECT_PATH}/ExportOptions.plist

# 先删除ExportOptionsPlistPath文件
if [ -f "$__ExportOptionsPlistPath" ] ; then
echo "${__ExportOptionsPlistPath}文件存在，进行删除"
rm -f $__ExportOptionsPlistPath
fi
# 根据参数生成export_options_plist文件
/usr/libexec/PlistBuddy -c  "Add :method String ${__METHOD}"  $__ExportOptionsPlistPath
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:"  $__ExportOptionsPlistPath
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${__BUNDLE_IDENTIFIER} String ${__MOBILEPROVISION_NAME}"  $__ExportOptionsPlistPath

echo "${__LINE_BREAK_LEFT} 使用打包配置文件路径=${__ExportOptionsPlistPath} ${__LINE_BREAK_RIGHT}"
```

