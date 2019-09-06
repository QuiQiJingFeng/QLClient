--[[
安卓下载器接口
--]]

if device.platform == "android" then
    cc.exports.luaj = require("cocos.cocos2d.luaj")
elseif device.platform == "ios" then
    cc.exports.luaoc = require("cocos.cocos2d.luaoc")
end

local ns = namespace("game.plugin")
local Downloader = class("Downloader")
ns.Downloader = Downloader

function Downloader.start(url, onlyWifi, progressCallback, errorCallback, completedCallback)
	local ok, ret = false, 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/mahjong/FileDownload", "start", { url, onlyWifi, progressCallback, errorCallback, completedCallback })
	end
	return ret
end

function Downloader.stop()
	local ok, ret = false, 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/mahjong/FileDownload", "stop", {})
	end
	return ret
end

function Downloader.clear(reservedApkName)
	local ok, ret = false, 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/mahjong/FileDownload", "clear", { reservedApkName })
	end
	return ret
end

function Downloader.install(url)
	local ok, ret = false, 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/mahjong/FileDownload", "install", { url })
	end
	return ret
end
