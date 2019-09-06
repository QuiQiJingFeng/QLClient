local csbPath = "ui/csb/Club/UIClubGroupLeaderInfo.csb"
local super = require("app.game.ui.UIBase")

local UIClubGroupLeaderInfo = class("UIClubGroupLeaderInfo", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubGroupLeaderInfo:ctor()
   
end

function UIClubGroupLeaderInfo:init()
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
    self._imgFrame = seekNodeByName(self, "Image_frame", "ccui.ImageView") -- 头像框
    self._textPlayerName = seekNodeByName(self, "Text_playerName", "ccui.Text") -- 玩家昵称
    self._textInfo = seekNodeByName(self, "Text_info", "ccui.Text") -- 玩家信息

    self._btnDefine = seekNodeByName(self, "Button_define", "ccui.Button")
    self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")

    bindEventCallBack(self._btnDefine, handler(self, self._onClickDefine), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
end

function UIClubGroupLeaderInfo:onShow(playerInfo)
    self._playerInfo = playerInfo
    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, playerInfo.leaderIcon)
    self._textPlayerName:setString(game.service.club.ClubService.getInstance():getInterceptString(playerInfo.leaderName, 12))
    self._textInfo:setString(string.format("即将任命%s为搭档，备注为%s,赢家分超%s分额外记录。", playerInfo.leaderName, playerInfo.groupName, playerInfo.minScore))
end

function UIClubGroupLeaderInfo:onHide()
    -- body
end

function UIClubGroupLeaderInfo:_onClickCancel()
    UIManager:getInstance():destroy("UIClubGroupLeaderInfo")
end

function UIClubGroupLeaderInfo:_onClickDefine()
    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLCreateClubGroupREQ(
        self._playerInfo.clubId,
        self._playerInfo.groupName,
        self._playerInfo.leaderId,
        self._playerInfo.minScore
    )
    self:_onClickCancel()
end

function UIClubGroupLeaderInfo:needBlackMask()
	return true
end

function UIClubGroupLeaderInfo:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubGroupLeaderInfo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubGroupLeaderInfo