local csbPath = "ui/csb/Club/UIClubWeChatInvited.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
	邀请加入亲友圈
]]

local UIClubWeChatInvited = class("UIClubWeChatInvited", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubWeChatInvited:ctor()
	self._clubInfo = nil
	self._beInviterId = nil
end

function UIClubWeChatInvited:init()
	self._btnclose = seekNodeByName(self, "Button_x_YQ_club",  "ccui.Button") -- 关闭
	self._btnInvite = seekNodeByName(self, "Button_yq_YQ_club",  "ccui.Button") -- 邀请
	self._btnWeiXinInvite = seekNodeByName(self, "Button_wxyq_YQ_club",  "ccui.Button") -- 微信邀请
	self._btnFriendsInvite = seekNodeByName(self, "Button_pyqyq_YQ_club",  "ccui.Button") -- 朋友圈邀请
	self._textInput = seekNodeByName(self, "TextField_PlayerId",  "ccui.TextField") -- 输入框
	self._panelFather = seekNodeByName(self, "Panel_YQ_club",	"ccui.Layout") 
	self._panelFather:setPositionY(display.height/2)


    bindEventCallBack(self._btnInvite, handler(self, self._onClickInviteButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnWeiXinInvite, handler(self, self._onClickWeiXinInviteButton), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnFriendsInvite, handler(self, self._onClickFriendsInviteButton), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnclose, handler(self, self._onClickCloseBtn),ccui.TouchEventType.ended);

	self._textInput:addEventListener(handler(self, self._onTextFieldChanged))
end

function UIClubWeChatInvited:_onTextFieldChanged(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime  then
		-- 统计亲友圈成员列表邀请输入框点击
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite_shurukuang);
	end
end

function UIClubWeChatInvited:_onClickInviteButton()
	-- 统计亲友圈成员列表邀请按钮点击
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite_button);

	self._beInviterId = self._textInput:getString()
	if tonumber(self._beInviterId) ~= nil then
		game.service.club.ClubService.getInstance():getClubMemberService():sendCCLSendClubInvitationREQ(self._clubInfo.data.clubId, self._beInviterId, ClubConstant:getClubInvitationSourceType().NORMAL)
		
		UIManager:getInstance():destroy("UIClubWeChatInvited");
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的玩家ID")
	end
end

-- 微信好友邀请
function UIClubWeChatInvited:_onClickWeiXinInviteButton()
	-- 统计亲友圈成员列表微信邀请点击
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite_Wechat)

	local url, shareContent = self:_getShareURL(2)
	share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_INVITED_FRIENDS, {{url = url, shareContent = shareContent}})
end

-- 朋友圈邀请
function UIClubWeChatInvited:_onClickFriendsInviteButton()
	-- 统计亲友圈成员列表朋友圈邀请点击
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite_Pengyouquan)

	local url = self:_getShareURL(3)
	share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_INVITED_MOMENTS, {{url = url}})
end

function UIClubWeChatInvited:_getShareURL(shareType)
	local ip = config.UrlConfig.getClubWeChatParameter()
	local clubId = self._clubInfo.data.clubId
	local clubName = self._clubInfo.data.clubName
	local managerName = self._clubInfo.data.managerName
	local createTime = self._clubInfo.data.clubCreateTime
	local shareTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
	local areaId = game.service.LocalPlayerService:getInstance():getArea()
	local playerId = game.service.LocalPlayerService:getInstance():getRoleId()
	local invitationCode = self._clubInfo.data.invitationCode
	local url = string.format("%s/clubInvitation?clubId=%s&clubName=%s&clubManager=%s&createTime=%s&area=%s&areaid=%s&playerId=%s&shareTime=%s&shareType=%s&imgUrl=%s",
		ip, 				-- 域名
		clubId, 			-- 俱乐部Id
		string.urlencode(clubName), 			-- 俱乐部名称
		string.urlencode(managerName), 		-- 经理昵称
		createTime, 		-- 创建时间
		areaId, 			-- 地区id
		areaId,				-- 地区id
		playerId, 			-- 邀请玩家id
		shareTime, 			-- 当前时间为分享时间
		shareType, 			-- 分享类型
		""					-- 头像链接（目前客户端自己配置）
	)
	local shareContent = string.format("邀请你加入%s\n%s:%s ID:%s\n邀请码:%s", config.STRING.COMMON, config.STRING.COMMON, clubName, clubId, invitationCode)
	return url, shareContent
end

function UIClubWeChatInvited:onShow(...)
	local args = {...}
	self._clubInfo = args[1]
	self._textInput:setTextColor(cc.c4b(151, 86, 31, 255))
	self._textInput:setString("")
	self._btnWeiXinInvite:setVisible(args[2])
	self._btnFriendsInvite:setVisible(args[2])
end

function UIClubWeChatInvited:onHide()
	local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIClubWeChatInvited:_onClickCloseBtn()
	UIManager:getInstance():hide("UIClubWeChatInvited")
end

function UIClubWeChatInvited:needBlackMask()
	return true;
end

function UIClubWeChatInvited:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubWeChatInvited:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubWeChatInvited
