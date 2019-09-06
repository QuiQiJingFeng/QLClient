
--[[
	分享URL到微信
	@param url 分享的url地地址
	@param wxType 分享的类型，是朋友圈还是会话
	@param tagName 
	@param shareInfo info
	@param shareIcon icon
]]
local shareURLToWX = function(url, wxType, tagName, shareInfo, shareContent, shareIcon)
	if game.service.WeChatService.getInstance():sendLinkURL(
		url,
		tagName or "tagName", 
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		shareContent or config.GlobalConfig.getShareInfo()[2], 
		shareIcon or config.GlobalConfig.getDefaultIcon(),
		wxType) then

		-- 记录分享渠道
		game.service.ActivityService.getInstance():setShareChannels(wxType == game.service.WeChatService.WXScene.WXSceneSession)
	end
end

--[[
	分享到微信，带图片功能的，统一接口，简化参数调用
	@param fileName 分享的文件名
	@param tagName tag
	@param shareInfo shareInfo
	@param wxType 分享的类型
]]
local shareToWX = function(fileName, wxType, tagName, shareInfo)
	game.service.WeChatService.getInstance():sendImageData(
		fileName, 
		tagName or "tagName", 
		shareInfo or config.GlobalConfig.getShareInfo()[1], 
		"", 
		fileName, 
		wxType
	)
end

return {
    shareUrlFunc = shareURLToWX,
    sharePicFunc = shareToWX
}