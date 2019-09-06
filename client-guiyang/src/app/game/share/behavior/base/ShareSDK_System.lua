
--[[
	系统分享URL
	@param url 分享的url地地址
	@param shareInfo 分享到内容
	@param shareIcon 分享的图标
	@param shareApp 要分享到的app，现在默认是微信
]]
local sharURLToSystem = function(url, shareInfo, shareIcon, shareApp)
	if Macro.assertTrue(type(url) ~= "string") then
		return
	end
	if game.plugin.Runtime.shareUrl(
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		shareIcon or config.GlobalConfig.getDefaultIcon(),
		url, 
		shareApp or "com.tencent.mm") then

		-- 记录分享渠道
		-- game.service.ActivityService.getInstance():setShareChannels(false)
	end
end

--[[
	分享到系统，带图片功能的，统一接口，简化参数调用
	@param fileName 分享的文件名，这里可能是带完整路径的
]]
local shareToSystem = function(fileName, data)
	if game.plugin.Runtime.hasSystemShare2() and data and (data.enter == "ROOM_INFO" or data.enter == "FINAL_REPORT") then
		game.plugin.Runtime.shareImage2(
			fileName,
			{ { packageName = "com.tencent.mm", name = "com.tencent.mm.ui.tools.ShareImgUI" }, { packageName = "com.aides.brother.brotheraides" } }
		)
	else
		game.plugin.Runtime.shareImage(
			fileName, 
			""
		)
	end
end

return {
    shareUrlFunc = sharURLToSystem,
    sharePicFunc = shareToSystem
}