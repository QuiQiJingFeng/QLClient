
--[[
	分享URL到钉钉
	@param url 分享的url地地址
	@param shareInfo info
	@param shareIcon icon
]]
local shareURLToDD = function(url, shareInfo, shareContent, shareIcon)
	if game.service.DingTalkService.getInstance():sendLinkURL(
		url,
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		shareContent or config.GlobalConfig.getShareInfo()[2], 
		shareIcon or config.GlobalConfig.getDefaultIcon()) then

		-- 记录分享渠道
		-- game.service.ActivityService.getInstance():setShareChannels(wxType == game.service.WeChatService.WXScene.WXSceneSession)
	end
	Logger.debug("钉钉分享了")
end

--[[
	分享到钉钉，带图片功能的，统一接口，简化参数调用
	@param fileName 分享的文件名
]]
local shareToDD = function(fileName, wxType, tagName, shareInfo)
	game.service.DingTalkService.getInstance():sendImageData(
		fileName
	)
	Logger.debug("钉钉分享了")
end

return {
    shareUrlFunc = shareURLToDD,
    sharePicFunc = shareToDD
}