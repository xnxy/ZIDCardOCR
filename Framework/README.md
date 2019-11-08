# ZIDCardOCR SDK存放目录
选中ZIDCardOCRScript 将会自定将Framework存放到该目录下

### 1、脚本

```
build-ocr-all.sh   打包armv7、arm64、i386、x86_64指令集的Framework
```

```
build-ocr-arm.sh  打包armv7、arm64指令集的Framework
```

### 2、切换打包的指令集
切换脚本，在ZIDCardOCRScript -> Build Phases -> Run Script 中下脚本的路径即可。

### 3、查看打包的指令集

###### cd 到Framework的位置

###### 输入lipo -info ZIDCardOCR 即可查看打包的Framework所包含的指令集:
