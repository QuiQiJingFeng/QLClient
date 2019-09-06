local csbPath = "ui/csb/BigLeague/UIBigLeagueMemberInvite.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

---@class UIBigLeagueMemberInvite:UIBase
local UIBigLeagueMemberInvite = super.buildUIClass("UIBigLeagueMemberInvite", csbPath)

function UIBigLeagueMemberInvite:ctor()

end

function UIBigLeagueMemberInvite:init()
    ---@type Button self._btnPlayerId
    self._btnPlayerId = seekNodeByName(self, "Button_PlayerId", "ccui.Button")
    self._btnFriend = seekNodeByName(self, "Button_Friend", "ccui.Button")
    self._btnClosed = seekNodeByName(self, "Button_Closed", "ccui.Button")

    bindEventCallBack(self._btnPlayerId, handler(self, self._onClickPlayerId), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFriend, handler(self, self._onClickFriend), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClosed, function () self:destroySelf() end, ccui.TouchEventType.ended)
	
	-- 监听关闭界面
	event.EventCenter:addEventListener("EVENT_CLUB_INVITE_SUC", function ()
		self:destroySelf()
	end , self)
end

function UIBigLeagueMemberInvite:_onClickPlayerId()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Invite_ByID)

	UIManager:getInstance():show("UIKeyboard", "邀请成员", 9, "请输入正确的玩家ID", "邀请", function (inviterId)
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Invite_KeyBoard)
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLSendClubInvitationREQ(self._clubInfo.data.clubId, inviterId, ClubConstant:getClubInvitationSourceType().NORMAL)
    end)
end

function UIBigLeagueMemberInvite:_onClickFriend()
    -- 统计联盟群主成员列表微信邀请点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Invite_ByWechat)

    local url, shareContent = self:_getShareURL(2)
    share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_INVITED_FRIENDS, {{url = url, shareContent = shareContent}})
end

function UIBigLeagueMemberInvite:_getShareURL(shareType)
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

function UIBigLeagueMemberInvite:destroy()
    event.EventCenter:removeEventListenersByTag(self)
end


function UIBigLeagueMemberInvite:onShow(clubinfo)
    self._clubInfo = clubinfo
end

function UIBigLeagueMemberInvite:onHide()

end

function UIBigLeagueMemberInvite:needBlackMask()
    return true
end

function UIBigLeagueMemberInvite:closeWhenClickMask()
    return false
end

function UIBigLeagueMemberInvite:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIBigLeagueMemberInvite