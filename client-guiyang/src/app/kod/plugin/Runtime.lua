--[[
设备相关接口
--]]
local Version = require "app.kod.util.Version"

-- 加载平台包
if device.platform == "android" then
    cc.exports.luaj = require("cocos.cocos2d.luaj")
elseif device.platform == "ios" then
    cc.exports.luaoc = require("cocos.cocos2d.luaoc")
end

local ns = namespace("game.plugin")
local Version = require "app.kod.util.Version"
local Runtime = class("Runtime")
ns.Runtime = Runtime

-- 当前是否是运行库环境
function Runtime.isEnabled()
	if device.platform == "android" or device.platform == "ios" then
		return true;
	end
	return false;
end

function Runtime.getPlatform()
	return device.platform;
end

function Runtime.getStartupParameter()
	-- 4.1.0.0版本开始支持启动参数
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.1.0.0")
	if currentVersion:compare(supportVersion) < 0 then
		return nil
	end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/KodStartup", "getParameter", {}, "()Ljava/lang/String;")
	elseif device.platform == "ios" then
		ok, ret = luaoc.callStaticMethod("KodStartup", "getParameter")
	end
    if ret == "" then ret = nil end
	return ret
end

-- 获取App BundleId
-- @return string
function Runtime.getBundleId()
	if not Runtime.isEnabled() then return 0 end
	
	local ok = false
	local ret = 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getBundleId", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getBundleId")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return 0 end
	return ret;
end

-- 获取Runtime版本号
-- @return string
function Runtime.getBuildVersion()
	if not Runtime.isEnabled() then return "0.0.0.0" end
	
	local ok = false
	local ret = ""
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getBuildVersion", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getBuildVersion")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

-- 获取渠道号
-- @return string
function Runtime.getChannelId()
	if not Runtime.isEnabled() then return 0 end
	
	local ok = false
	local ret = 0
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getChannelID", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getChannelID")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return 0 end
	return ret;
end

-- 获取子渠道号
-- @return number
function Runtime.getSubChannelId()
	if not Runtime.isEnabled() then return 0 end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getSubChannelID", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getSubChannelID")
	end

	if Macro.assetTrue(ok == false, tostring(ret)) then return 0 end
	return ret;
end

-- 获取设备UDID
-- @return string
--[[function Runtime.getDeviceId()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getDeviceId", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getDeviceId")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end]]
local DEVICEID_OP_NONE = 0
local DEVICEID_OP_SUCC = 1
local DEVICEID_OP_FAILED = 2
function Runtime.getDeviceId()
	if not Runtime.isEnabled() then return "" end

	local ok = false
	local ret = nil
	local writeOp, readOp = DEVICEID_OP_NONE, DEVICEID_OP_NONE
	if device.platform == "android" then
        local deviceIdDir = Runtime.getExternalStoragePath() .. "/.lhcache"
        local deviceIdFile = deviceIdDir .. "/USERDATA"
        if cc.FileUtils:getInstance():isFileExist(deviceIdFile) then
			local deviceId = io.readfile(deviceIdFile)
            if deviceId and string.trim(deviceId) ~= "" then
                readOp = DEVICEID_OP_SUCC
                return deviceId, readOp, writeOp
            else
                readOp = DEVICEID_OP_FAILED
            end
        end
        
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getDeviceId", {}, "()Ljava/lang/String;")
        if ok then
        	if not cc.FileUtils:getInstance():isDirectoryExist(deviceIdDir) then
		        cc.FileUtils:getInstance():createDirectory(deviceIdDir)
        	end
            if io.writefile(deviceIdFile, ret) then
                writeOp = DEVICEID_OP_SUCC
            else
                writeOp = DEVICEID_OP_FAILED
            end
        end
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getDeviceId")		
    end

	if Macro.assetTrue(ok == false, tostring(ret)) then return "", readOp, writeOp end
	return ret, readOp, writeOp
end

-- 获取设备名称
-- @return string
function Runtime.getDeviceName()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getDeviceName", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getDeviceName")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

-- 获取系统名称
-- @return string
function Runtime.getSystemName()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = true, ""; -- android没有这个函数的实现
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getSystemName")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

-- 获取提供版本号
-- @return string
function Runtime.getSystemVersion()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getSystemVersion", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getSystemVersion")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

function Runtime.isExternalStorageAvailable()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "isExternalStorageAvailable", {}, "()Z")
	elseif Macro.assetFalse(device.platform == "ios") then
		return false
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret
end

function Runtime.isExternalStorageWriteable()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "isExternalStorageWriteable", {}, "()Z")
	elseif Macro.assetFalse(device.platform == "ios") then
		return false
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret
end

function Runtime.getExternalStoragePath()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getExternalStoragePath", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		return nil
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret
end

function Runtime:getDeviceModel()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getDeviceModel", {}, "()Ljava/lang/String;")		
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getDeviceModel")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

-- 获取运行时是否强制不黑屏
-- @return bool
function Runtime.getIdleTimerDisabled()
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getIsKeepScreenOn", {}, "()Z")		
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getIdleTimerDisabled")
		ret = ret ~= 0
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret
end

-- 设置运行时不黑屏
-- @return bool
function Runtime.setIdleTimerDisabled(value)
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "setIsKeepScreenOn", { value })		
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "setIdleTimerDisabled", { value = value })
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 当前是否正在充电
-- @return bool
function Runtime.isBatteryCharging()
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "isBatteryCharging", {}, "()Z")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "isBatteryCharging")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret ~= 0;
end

-- 当前电池电量
-- @return int
function Runtime.getBatteryLevel()
	if not Runtime.isEnabled() then return 0 end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getBatteryLevel", {}, "()I")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getBatteryLevel")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return 0 end
	return ret;
end

-- 震动屏幕
-- @return bool
function Runtime.shake()
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shake")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "shake")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 获取Mac地址
-- @return string
function Runtime.getMacAddress()
	if not Runtime.isEnabled() then return "" end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getMacAddress", {}, "()Ljava/lang/String;")		
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getMacAddress")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
	return ret;
end

-- 设置剪切板
-- @return bool
function Runtime.setClipboard(value)
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "setClipboard", {value})
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "setClipboard",{value = value})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 获取剪切板内容
-- @return string
function Runtime.getClipboard(callbackFunc)
	if not Runtime.isEnabled() then return "" end
	
	if device.platform == "android" then
		if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.1.1.0")) >= 0 then
		    local ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getClipboard", {callbackFunc}, "(I)V")
		    if Macro.assetTrue(ok == false, tostring(ret)) then return false end
			return true
	    end
		return false
	elseif Macro.assetFalse(device.platform == "ios") then
	    local ok, ret = luaoc.callStaticMethod("Device", "getClipboard")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		
		if nil ~= callbackFunc then callbackFunc(tostring(ret)) end
	    return true
	end
	
	Macro.assetFalse(false);
end

-- 开启App更新
-- @return bool
function Runtime.updateAppFromURL(url)
	if not Runtime.isEnabled() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "updateAppFromURL",{url})
	elseif Macro.assetFalse(device.platform == "ios") then		
		return Runtime.openURL(url);
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

function Runtime.openURL(url)
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		return false
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "openURL", {url = url})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 打开app设置页
function Runtime.openAppSetting()
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		return false
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "openAppSetting")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 保存图片到相册
function Runtime.savePhoto(path)
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "savePhoto",{path},"(Ljava/lang/String;)I")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "savePhoto", { path = path })
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 分享图片 imagePath:imagePath  packageName:分享的包名(微信:com.tencent.mm)
function Runtime.shareImage(imagePath, packageName)
	if not Runtime.isEnabled() then return false end

	Logger.info("[Runtime Share Log Info] imagePath:" .. imagePath .. ", | packageName:" .. packageName)
	local ok = false
	local ret = nil
	if device.platform == "android" then
		Logger.info("[Runtime Share Log Info] Device requlas Android")
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareImage",{imagePath,packageName},"(Ljava/lang/String;Ljava/lang/String;)I")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "shareImage", { imagePath = imagePath, packageName = packageName})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- 分享图片 title:appname iconName:iconName,urlLink:urlLink,packageName:分享的包名(微信:com.tencent.mm)
function Runtime.shareUrl(title, iconName, urlLink, packageName)
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareUrl",{title,iconName,urlLink,packageName},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "shareUrl", { title = title, iconName = iconName, urlLink = urlLink, packageName = packageName})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

--[[-- 获取网络状态
-- @return int
function Runtime.getConnectedInternetStatus()
	return loho.getReachabilityStatus()
	if not Runtime.isEnabled() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getConnectedInternetStatus")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getConnectedInternetStatus")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret;
end--]]

function Runtime.hasSystemShare2()
	if device.platform == "android" then
        if LuaJavaBridge.isStaticMethodExisted and LuaJavaBridge.isStaticMethodExisted("com/lohogames/common/Device", "shareImage2",  "(Ljava/lang/String;Ljava/lang/String;)I") then
            return true
        end
    end
    return false
end

-- 系统分享 n个app 
-- tblPackageNames格式:
-- { { packageName = "com.tencent.mm", name = "com.tencent.mm.ui.tools.ShareImgUI" }, { packageName = "com.alibaba.android.rimet" } }

function Runtime.shareImage2(imagePath, tblPackageNames)
	Logger.debug("shareImage2")
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareImage2", { imagePath, json.encode(tblPackageNames) }, "(Ljava/lang/String;Ljava/lang/String;)I")
	end
	return true;
end

function Runtime.shareText2(text, tblPackageNames)
	Logger.debug("shareText2")
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareText2", { text, json.encode(tblPackageNames) }, "(Ljava/lang/String;Ljava/lang/String;)I")
	end
	return true;
end


-- 直接分享好友
function Runtime.shareImageToWXImgUI(imagePath)
	if not Runtime.isEnabled() then return false end
  
	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareImageToWXImgUI",{imagePath},"(Ljava/lang/String;)I")
	end
	return true;
  end
  
-- 直接分享朋友圈
function Runtime.shareImageToWXTimeLine(imagePath, text)
	if not Runtime.isEnabled() then return false end

	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "shareImageToWXTimeLine",{imagePath,text},"(Ljava/lang/String;Ljava/lang/String;)I")
	end
	return true;
end



-- 初始化Billing信息
function Runtime.setBillingBundleId(appId,serverType,domainUrl)
	if not Runtime.isEnabled() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "setBillingBundleId",{appId,serverType,domainUrl})
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "setBillingBundleId",{bundleId=appId,serverType=serverType,domainUrl=domainUrl})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret;
end

-- 支付
function Runtime.purchase(productId,rmb,playerid)
	if not Runtime.isEnabled() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "purchase",{productId,rmb,playerid}, "(Ljava/lang/String;II)V")
	elseif Macro.assetFalse(device.platform == "ios") then
		local str = string.format( "%9d", playerid )
		ok, ret = luaoc.callStaticMethod("Device", "purchase",{productId=productId,rmb=rmb,playerid=str})
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret;
end

function Runtime.downloadApk(url, isVisible, allowedNetworkTypes, onDownloadFinish, title, description)
	if not Runtime.isEnabled() then return end
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "downloadApk",
			{ url, isVisible, allowedNetworkTypes, onDownloadFinish, title or "", description or "" },
			"(Ljava/lang/String;ZIILjava/lang/String;Ljava/lang/String;)I")
	else
		Macro.assetFalse(false, "Not implement")
	end	
	return ret
end

function Runtime.getDownloadProgress(downloadId)
	if not Runtime.isEnabled() then return end
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getDownloadProgress", {downloadId},"(I)F")
	else
		Macro.assetFalse(false, "Not implement")
	end	
	return ret
end

function Runtime.installApk(url)
	if not Runtime.isEnabled() then return end
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "installApk", {url})
	else
		Macro.assetFalse(false, "Not implement")
	end	
end

-- 判断IOS评价否开启
function Runtime.isCommentSupported()
	if not Runtime.isEnabled() then return false end
	
	if device.platform == "android" then
		return false
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.1.0.0")
	return currentVersion:compare(supportVersion) >= 0;
end

--[[
    ios评价星级
--]]
function Runtime.sendCommentToApple()
	if not Runtime.isCommentSupported() then return end

    if device.platform == "android" then
		return false
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("Device", "sendCommentToApple")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false)
end



function Runtime.setMaxLogFiles(maxFiles)
	if not Runtime.isEnabled() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "setMaxLogFiles", { maxFiles }, "(I)V")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "setMaxLogFiles", { maxFiles = maxFiles })
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true
end

function Runtime.getLogFilePath()
	if not Runtime.isEnabled() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
		ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "getLogFilePath", {}, "()Ljava/lang/String;")
	elseif Macro.assetFalse(device.platform == "ios") then
		ok, ret = luaoc.callStaticMethod("Device", "getLogFilePath")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return nil end
	return ret
end

-- 是否为账号互通的新版
function Runtime.isAccountInterflow()
	local currentVersion = Version.new(Runtime.getBuildVersion())
	local supportVersion = Version.new("4.10.0.0")
	return currentVersion:compare(supportVersion) >= 0;
end

-- 判断通知权限是否打开
-- return int(1 打开  0 关闭)
function Runtime.notificationsEnabled()
	if not Runtime.isEnabled() or not Runtime.isAccountInterflow() then return nil end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "notificationsEnabled", {}, "()I")    
	elseif Macro.assetFalse(device.platform == "ios") then
	  ok, ret = luaoc.callStaticMethod("Device", "notificationsEnabled")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return nil end
	return ret;
  end
  
-- 打开设置
function Runtime.openSetting()
	if not Runtime.isEnabled() or not Runtime.isAccountInterflow() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("com/lohogames/common/Device", "openSetting")
	elseif Macro.assetFalse(device.platform == "ios") then
	  ok, ret = luaoc.callStaticMethod("Device", "openSetting")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return true;
end

-- android版本 int
function Runtime.getSDKVersion()
	if not Runtime.isEnabled() and not Runtime.isAccountInterflow() then return false end
	
	local ok = false
	local ret = nil
	if device.platform == "android" then
	  ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getSDKVersion", {}, "()I")
	end
	
	if Macro.assetTrue(ok == false, tostring(ret)) then return false end
	return ret;
end

-- Test
-- Logger.debug("Runtime.isEnabled(),"..(tostring(Runtime.isEnabled())))
-- Logger.debug("Runtime.getChannelId(),"..(tostring(Runtime.getChannelId())))
-- Logger.debug("Runtime.getSubChannelId(),"..(tostring(Runtime.getSubChannelId())))
-- Logger.debug("Runtime.getBuildVersion(),"..(tostring(Runtime.getBuildVersion())))
-- Logger.debug("Runtime.getBundleId(),"..(tostring(Runtime.getBundleId())))
-- Logger.debug("Runtime.getUDID(),"..(tostring(Runtime.getUDID())))
-- Logger.debug("Runtime.getDeviceName(),"..(tostring(Runtime.getDeviceName())))
-- Logger.debug("Runtime.getSystemName(),"..(tostring(Runtime.getSystemName())))
-- Logger.debug("Runtime.getSystemVersion(),"..(tostring(Runtime.getSystemVersion())))
-- Logger.debug("Runtime.getDeviceMode(),"..(tostring(Runtime.getDeviceMode())))

-- Logger.debug("Runtime.setIdleTimerDisabled(),"..(tostring(Runtime.setIdleTimerDisabled(true))))
-- Logger.debug("Runtime.getIdleTimerDisabled(),"..(tostring(Runtime.getIdleTimerDisabled())))
-- Logger.debug("Runtime.setIdleTimerDisabled(),"..(tostring(Runtime.setIdleTimerDisabled(false))))
-- Logger.debug("Runtime.getIdleTimerDisabled(),"..(tostring(Runtime.getIdleTimerDisabled())))
-- Logger.debug("Runtime.isBatteryCharging(),"..(tostring(Runtime.isBatteryCharging())))
-- Logger.debug("Runtime.getBatteryLevel(),"..(tostring(Runtime.getBatteryLevel())))
-- Logger.debug("Runtime.shake(),"..(tostring(Runtime.shake())))
-- Logger.debug("Runtime.getMacAddress(),"..(tostring(Runtime.getMacAddress())))
-- Logger.debug("Runtime.setClipboard(),"..(tostring(Runtime.setClipboard(""))))
-- Logger.debug("Runtime.getClipboard(),"..(tostring(Runtime.getClipboard())))
-- Logger.debug("Runtime.setClipboard(),"..(tostring(Runtime.setClipboard("test"))))
-- Logger.debug("Runtime.getClipboard(),"..(tostring(Runtime.getClipboard())))
-- Logger.debug("Runtime.getClipboard(),"..(tostring(Runtime.openURL("www.baidu.com"))))