# iOS-AutoBuild
iOS自动打包

使用方法：
> iOS自动打包-sh的使用：下载压缩包后，解压，里面有后缀为.sh的文件和.plist的文件，将这两个文件放到  
.xcodeproj所在的文件夹下，然后配置一下plist文件，打开terminal，运行这个.sh文件即可。

然后来说一下调试中遇到的问题：
1. Scheme的问题，我不知道自己的sheme是什么？或者我的sheme明明就是这个但是提示我找不到
2. xcrun: error: unable to find utility "PackageApplication", not a developer tool or in PATH

### 问题一：Scheme的问题
不知道自己的Scheme是什么的，可以去Product->Scheme->Edit Scheme下查看  
![Scheme 查看1](https://ooo.0o0.ooo/2017/02/20/58aa93bb6da09.png)

### 问题二：xcrun: error: unable to find utility "PackageApplication", not a developer tool or in PATH

Xcode升级到8.3.1后PackageApplication被删除了，但是打包的时候需要用到该工具，去下载一份PackageApplication，然后放到下面目录

```
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/
```

然后执行命令下面两条命令

```
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/
chmod +x /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication
```

备注：

key 				| 是否必填	   | 作用 
---------  		| --- 		| -------------
identifier 		| 是 			| bundle id 
version 			| 是 			| 版本号
p12 				| 是 			| p12文件 相对于sh脚本的位置 
p12Password   	| 否 			| p12文件的密码 没有可以不填写 
mobileprovisionFile | 是  | 描述文件 相对于sh脚本的位置
appName 			| 是 			| ipa的英文名称
conf				| 是			| 打包环境 Debug Release 等
plistInfo		| 是			| 所要打包的工程文件的info.plist 这需要相对路径 
bundleDisplayName|是			| ipa安装后的的现实的名称
xcworkspace		| 是			| workspace的相对路径
scheme			| 是			| scheme的名称
