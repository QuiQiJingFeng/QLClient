local UIShareNode = class("UIShareNode")

--[[    1.此类是用来获取截图的node
    
    2.只用于此share.constants.FORM.NODE分享类型
    
    3.channel 分享类型 share.constants.CHANNEL  朋友  朋友圈  系统 比如以后的钉钉。。。
    
    4.data 是所需要的数据（每个类型所需要的数据不同 根据需求传参写方法）
    
    5.图片路径为字符串拼接的 比如art/guiyang/main/common.jpg
        art/guiyang 在地区文件中配置的
        main则是指大厅分享图片的文件夹名
        每个文件夹中必须要一个commom的图片
]]
-- 房间玩法分享的图片
local getShareRoomRule = function(channel, tip, title, content, enter)
	local uishare = require("app.game.ui.UIShareRoomInfo").new()
	
	local filePath = share.config.getShareImg(enter, "jpg")
	local erweimaUrl = share.config.getQRCodeUrl("room")
	-- -- 如果没有就调用通用的图片
	-- if cc.FileUtils:getInstance():isFileExist(filePath) == false then
	--     filePath = share.config.getShareImg(enter, "jpg")
	-- end
	uishare:onShow(tip, title, content, filePath, erweimaUrl)
	
	return uishare:getSharePannel()
end

local getOfflineRoomInfo = function()
	local uishare = require("app.game.ui.UIOfflineRoomInfo").new()
	uishare:onShow()
	return uishare:getSharePannel()
end

-- 分享一个node中带一个更换的图片（可选的）的（比如：比赛分享奖状的图片）
local getShareCampaign = function(channel, enter, panel, img)
	-- local filePath = share.config.getShareImg(enter, "png")
	if img then
		-- img:loadTexture(filePath)
		game.util.PlayerHeadIconUtil.setIcon(img, share.config.getQRCodeUrl("campaign"));
	end
	
	return panel
end

-- 分享一张图片的（比如大厅分享图片）
local getShareMain = function(channel, enter, erweima)
	-- local filePath = share.config.getShareImg(enter, "jpg")
	-- local sp = ccui.ImageView:create(filePath)
	erweima = erweima or "hall"
	local node = kod.LoadCSBNode("ui/csb/UIHallShare.csb")
	local sp = seekNodeByName(node, "QRCode", "ccui.ImageView")
	game.util.PlayerHeadIconUtil.setIcon(sp, share.config.getQRCodeUrl(erweima))
	local root = seekNodeByName(node, "Image_1", "ccui.ImageView")
	return root
end

-- 图片生成node
local getShareNodeFromRes = function(res)
	local sp = ccui.ImageView:create(res)
	
	return sp
end

-- 分享一张图片加二维码的接口
local getSharePullNew = function(code, img)
	-- 这个UI会在下一帧自动释放
	local sharePullNew = kod.LoadCSBNode("ui/csb/Activity/UIActivity_pullNew.csb")
	local imgCode = seekNodeByName(sharePullNew, "Image_code", "ccui.ImageView")
	local panel = seekNodeByName(sharePullNew, "Panel_pullNew", "ccui.Layout")
	panel:setBackGroundImage(img)
	-- imgCode:loadTexture(code)
	game.util.PlayerHeadIconUtil.setIcon(imgCode, share.config.getQRCodeUrl("activity"))
	return panel
end

-- 分享回放码
local getShareNodeReplay = function(info)
	local UIShareReplayCode = kod.LoadCSBNode("ui/csb/UIShareReplayCode.csb")
	local roomText = seekNodeByName(UIShareReplayCode, "Text_ip", "ccui.Text")
	local roomRoundText = seekNodeByName(UIShareReplayCode, "Text_ip_0", "ccui.Text")
	local replayCodeText = seekNodeByName(UIShareReplayCode, "Text_id", "ccui.Text")
	local textName = seekNodeByName(UIShareReplayCode, "Text_name", "ccui.Text")
	local imgErweima = seekNodeByName(UIShareReplayCode, "Image_head", "ccui.ImageView")
	
	roomText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_1, tostring(info.roomId)))
	roomRoundText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_2, config.CONVERT_NUM[info.roundIndex]))
	replayCodeText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_3, info.playbackCode))
	textName:setString(info.name)
	game.util.PlayerHeadIconUtil.setIcon(imgErweima, share.config.getQRCodeUrl("other"));
    local node = UIShareReplayCode:getChildByName("Panel_Playinfo2_0")
	return node
end

-- 新分享图片
local getNewShareNode = function(idx)
	local sp = ccui.ImageView:create(config.NewShareConfig.shareImage[idx])
	local imageDimen = ccui.ImageView:create(cc.FileUtils:getInstance():getAppDataPath() .. "dimpump.png")
	imageDimen:setAnchorPoint(cc.p(0.5, 0.5))
	imageDimen:setPosition(cc.p(sp:getContentSize().width/2 -2, 604))
	sp:addChild(imageDimen)
	return sp
end

-- 获取截图的node
function UIShareNode:getShareNode(channel, data)
	local node = ""
	if data.enter == share.constants.ENTER.HALL then
		node = getShareMain(channel, data.enter, "hall")
	elseif data.enter == share.constants.ENTER.CAMPAIGN then
		node = getShareCampaign(channel, data.enter, data.panel, data.img)
	elseif data.enter == share.constants.ENTER.ROOM_INFO or data.enter == share.constants.ENTER.CLUB_ROOM_INFO then
		node = getShareRoomRule(channel, data.tip, data.title, data.content, data.enter)
	elseif data.enter == share.constants.ENTER.TURN_CARD_SHARE then
		node = getShareMain(channel, data.enter, "activity")
	elseif data.enter == share.constants.ENTER.ACTIVITY_FOR_SCREEN_SHOT then
		node = getShareMain(channel, data.enter, "activity")
	elseif data.enter == share.constants.ENTER.SHARE_PULLNEW then
		node = getSharePullNew(data.code, data.img)
	elseif data.enter == share.constants.ENTER.NEW_SHARE_FRIEND or data.enter == share.constants.ENTER.NEW_SHARE_CIRCLE then
		node = getNewShareNode(data.img)
	elseif data.enter == share.constants.ENTER.REPLAY then
		node = getShareNodeReplay(data.info)
	elseif data.enter == share.constants.ENTER.OFFLINE_ROOM_INFO then
		node = getOfflineRoomInfo()
	elseif data.res ~= nil then
		node = getShareNodeFromRes(data.res)
	end

	return node
end


return UIShareNode 