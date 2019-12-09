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

Util.changeWorkDirectory(os.path.split(os.path.realpath(__file__))[0])

CHANNEL_CONFIG = [
    {
        "name" : "zh-CN",
        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
        "version" : "1.0.3",
        "baseVersion" : "1.0.0",
        "xxteKey" : "10cc4fdee2fcd047",
        "xxteaSign" : "gclR3cu9"
    },
    {
        "name" : "zh-TW",
        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
        "version" : "1.0.1",
        "baseVersion" : "1.0.0",
        "xxteKey" : "10cc4fdee2fcd047",
        "xxteaSign" : "gclR3cu9"
    },
    {
        "name" : "zh-HK",
        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
        "version" : "1.0.1",
        "baseVersion" : "1.0.0",
        "xxteKey" : "10cc4fdee2fcd047",
        "xxteaSign" : "gclR3cu9"
    },
    {
        "name" : "R2",
        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
        "version" : "1.0.1",
        "baseVersion" : "1.0.0",
        "xxteKey" : "10cc4fdee2fcd047",
        "xxteaSign" : "gclR3cu9"
    },
    {
        "name" : "QIKU",
        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
        "version" : "1.0.1",
        "baseVersion" : "1.0.0",
        "xxteKey" : "10cc4fdee2fcd047",
        "xxteaSign" : "gclR3cu9"
    }
]
# 更最新包的时候,如果baseVersion比本地版本号大,说明要先更新全量包,在更新增量包
def generalInfo(targetDir,info,assetsInfo):
    VERSION = info["version"]
    URL = info["host"]
    VERSION_INFO = {
        "packageUrl": URL,
        "version": VERSION,
        "remoteVersionUrl": URL + "version.manifest",
        "remoteManifestUrl": URL + "project.manifest",
        "engineVersion": "3.15.1",
        "baseVersion" : info["baseVersion"]
    }

    ASSETS_INFO = {
        "searchPath": [], 
        "packageUrl": URL+"{0}/".format(VERSION), 
        "version": VERSION, 
        "assets": assetsInfo,
        "remoteVersionUrl": URL + "version.manifest", 
        "operator": "android", 
        "remoteManifestUrl": URL + "project.manifest", 
        "engineVersion": "3.15.1"
    }
    # 生成热更的版本号列表
    with open(targetDir+"/version.manifest", 'w') as f:
        json.dump(VERSION_INFO, f, indent=4, sort_keys=True)
    # 生成资源MD5列表
    with open(targetDir+"/project.manifest", 'w') as f:
        json.dump(ASSETS_INFO, f, indent=4, sort_keys=True)


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
