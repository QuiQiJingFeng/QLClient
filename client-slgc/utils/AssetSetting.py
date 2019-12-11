# -*- coding: utf-8 -*-
import os
import sys
# reload(sys)
# sys.setdefaultencoding("utf-8")

class AssetSetting:
	@staticmethod
	def getChanelConfig():
		config = [
		    {
		        "name" : "zh-CN",
		        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
		        "version" : "1.0.2",
		        "xxteKey" : "10cc4fdee2fcd047",
		        "xxteaSign" : "gclR3cu9"
		    },
		    {
		        "name" : "zh-TW",
		        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
		        "version" : "1.0.1",
		        "xxteKey" : "10cc4fdee2fcd047",
		        "xxteaSign" : "gclR3cu9"
		    },
		    {
		        "name" : "zh-HK",
		        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
		        "version" : "1.0.1",
		        "xxteKey" : "10cc4fdee2fcd047",
		        "xxteaSign" : "gclR3cu9"
		    },
		    {
		        "name" : "R2",
		        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
		        "version" : "1.0.1",
		        "xxteKey" : "10cc4fdee2fcd047",
		        "xxteaSign" : "gclR3cu9"
		    },
		    {
		        "name" : "QIKU",
		        "host" : "http://lsjgame.oss-cn-hongkong.aliyuncs.com/HotUpdate/",
		        "version" : "1.0.1",
		        "xxteKey" : "10cc4fdee2fcd047",
		        "xxteaSign" : "gclR3cu9"
		    }
		]
		return config


	@staticmethod
	def getVersionInfo(url, version):
		versionInfo = {
		    "packageUrl": url,
		    "version": version,
		    "remoteVersionUrl": url + "version.manifest",
		    "remoteManifestUrl": url + "project.manifest",
		    "engineVersion": "3.15.1",
		}
		return versionInfo

	@staticmethod
	def getAssetInfo(url, version, assetsInfo):
		assetInfo = {
		    "searchPath": [], 
		    "packageUrl": url+"{0}/".format(version), 
		    "version": version, 
		    "assets": assetsInfo,
		    "remoteVersionUrl": url + "version.manifest", 
		    "operator": "android", 
		    "remoteManifestUrl": url + "project.manifest", 
		    "engineVersion": "3.15.1"
		}
		return assetInfo
