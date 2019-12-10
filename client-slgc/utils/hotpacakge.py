# -*- encoding=utf8 -*-
import os
from Tkinter import *
from Util import Util
import json
import shutil

content = Util.getStringFromFile("channelConfig.json")
CHANNEL_CONFIG = json.loads(content)

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
	"selectId":0,
    "inputPath":"",
    "outputPath":""
}
if Util.isExist("export.db"):
	content = Util.getStringFromFile("export.db")
	localStoryge = json.loads(content)

window = Tk()
window.title("更新包导出工具")
window.geometry('300x500')  # 这里的乘是小x
group = LabelFrame(window, text="请选择要打包的渠道", padx=5, pady=5)
group.pack(padx=10, pady=10)

selectVar = StringVar()
selectVar.set(localStoryge["selectId"])
for index in range(len(CHANNEL_CONFIG)):
	b = Radiobutton(group, text=CHANNEL_CONFIG[index]["name"], variable=selectVar, value=index)
	b.pack(anchor=W)

textLabel = Label(window, text="项目路径", padx=10)
textLabel.pack()
textVarInput = StringVar()
textVarInput.set(localStoryge["inputPath"])
inputBoxInput = Entry(window,width =200,borderwidth=3,textvariable=textVarInput)
inputBoxInput.pack()

textLabel = Label(window, text="导出路径", padx=10)
textLabel.pack()
textVarOutPut = StringVar()
textVarOutPut.set(localStoryge["outputPath"])
inputBoxOutPut = Entry(window,width =200,borderwidth=3,textvariable=textVarOutPut)
inputBoxOutPut.pack()

def makePacakge(selectId,inputPath,outputPath):
    info = CHANNEL_CONFIG[selectId]
    srcDir = inputPath + "/src"
    resDir = inputPath + "/res"
    outDir = outputPath + "/" + info["version"]
    if(not os.path.exists(outDir)):  
        os.makedirs(outDir)
    else:
        print u"该版本号的包已经存在"
        return window.destroy()
    targetDir = outDir + "/pacakge"

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

def btnExportClick():
    selectId = int(selectVar.get())
    inputPath = inputBoxInput.get()
    outputPath = inputBoxOutPut.get()
    inputPath = inputPath.replace("\\","/")
    outputPath = outputPath.replace("\\","/")
    localStoryge["inputPath"] = inputPath
    localStoryge["outputPath"] = outputPath
    localStoryge["selectId"] = selectId
    json_str = json.dumps(localStoryge)
    Util.writeStringToFile("export.db",json_str)
    makePacakge(selectId,inputPath,outputPath)

def btnUploadClick():
    workDir = localStoryge["outputPath"]
    info = CHANNEL_CONFIG[localStoryge["selectId"]]
    Util.uploadHotPacakge(workDir, info["version"])

b = Button(window, text='导出',command=btnExportClick).pack()
c = Button(window, text='上传',command=btnUploadClick).pack()

window.mainloop()