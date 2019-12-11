#!/usr/bin/python
# -*- encoding=utf8 -*-
import os
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
from Tkinter import *
from Util import Util
import json
import shutil
from AssetSetting import AssetSetting

Util.changeWorkDirectory(os.path.split(os.path.realpath(__file__))[0])

CHANNEL_CONFIG = AssetSetting.getChanelConfig()

def generalInfo(targetDir,info,assetsInfo):
    version = info["version"]
    host = info["host"]
    versionInfo = AssetSetting.getVersionInfo(host,version)
    assetsInfo = AssetSetting.getAssetInfo(host,version,assetsInfo)
    # 生成热更的版本号列表
    with open(targetDir+"/version.manifest", 'w') as f:
        json.dump(versionInfo, f, indent=4, sort_keys=True)
    # 生成资源MD5列表
    with open(targetDir+"/project.manifest", 'w') as f:
        json.dump(assetsInfo, f, indent=4, sort_keys=True)


localStoryge = {
	"selectId":-1,
    "inputPath":"",
    "outputPath":""
}
if Util.isExist("config.json"):
	content = Util.getStringFromFile("config.json")
	localStoryge = json.loads(content)


def makePackage(selectId,inputPath,outDir):
    info = CHANNEL_CONFIG[selectId]
    print u'当前渠道信息'
    print info

    srcDir = inputPath + "/src"
    resDir = inputPath + "/res"
    if(not os.path.exists(outDir)):  
        os.makedirs(outDir)
    else:
        print u"清理旧的数据"
        shutil.rmtree(outDir)

    targetDir = outDir + "/package"
    #将资源目录拷贝到指定目录
    shutil.copytree(resDir,targetDir + "/res/")
    print u"res文件夹拷贝成功"

    #将src文件夹加密后导出到指定目录
    Util.encryptFolder(srcDir, targetDir, info["xxteKey"], info["xxteaSign"],['*.lua'])
    print u"src文件夹拷贝成功"

    assetsInfo = Util.zipFolderEx(targetDir)
    generalInfo(outputPath,info,assetsInfo)
    print u"zip压缩成功"
    print u"热更文件生成成功"

    shutil.rmtree(targetDir)
    print u"临时文件夹删除成功"

inputPath = localStoryge['inputPath']
outputPath = localStoryge["outputPath"]
selectId = localStoryge["selectId"]
if outputPath == "":
    raise RuntimeError(u'输出目录不存在')
elif inputPath == "":
    raise RuntimeError(u'输入目录不存在')
elif selectId < 0:
    raise RuntimeError(u'渠道错误')


makePackage(selectId,inputPath,outputPath)
