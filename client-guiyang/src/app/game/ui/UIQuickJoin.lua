local csbPath = "ui/csb/UIQuickJoin.csb"
local super = require("app.game.ui.UIBase")

local room = require( "app.game.ui.RoomSettingHelper" )
-- room.RoomSettingHelper

local UIQuickJoin = class("UIQuickJoin", super, function () return kod.LoadCSBNode(csbPath) end)

function UIQuickJoin:ctor()
    self._btnClose = nil
    self._btnJoinRoom = nil
    self._btnCancelJoinRoom = nil
    self._imgHead = nil
    self._txtHostPlayerName = nil
    self._txtHostPlayerID = nil
    self._txtPlayRuleTitle = nil
    self._txtPlayRule = nil

    self._roomId = nil
end

function UIQuickJoin:init()
    self._btnClose = seekNodeByName(self, "Button_x_QuiteJoin", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    self._btnJoinRoom= seekNodeByName(self, "Button_qd_QuiteJoin", "ccui.Button")
    bindEventCallBack(self._btnJoinRoom, handler(self, self._onJoinRoom), ccui.TouchEventType.ended)
    self._btnCancelJoinRoom= seekNodeByName(self, "Button_qx_QuiteJoin", "ccui.Button")
    bindEventCallBack(self._btnCancelJoinRoom, handler(self, self._onCancelJoinRoom), ccui.TouchEventType.ended)

    self._imgHead = seekNodeByName(self, "Image_face_QuiteJoin", "ccui.ImageView")
    self._txtHostPlayerName = seekNodeByName(self, "Text_name_QuiteJoin", "ccui.Text")
    self._txtHostPlayerID = seekNodeByName(self, "Text_ID_QuiteJoin", "ccui.Text")
    self._txtPlayRuleTitle = seekNodeByName(self, "Text_topword_QuiteJoin", "ccui.Text")
    self._txtPlayRule = seekNodeByName(self, "Text_word3_QuiteJoin", "ccui.Text")
end

function UIQuickJoin:onShow(...)
    --[[
    self._roomId = 0
    local ruleValues = { 1, 2, 3, 4 }
    local creator = 100
    local nickname = "就阿发动机fakfklj"
    nickname = string.sub(nickname, 1, 6) .. "(房主)"
    local headimgurl = ""
    --]]

    local args = { ... }
    self._roomId = args[1]
    local ruleValues = args[2]
    local creator = args[3]
    local nickname = args[4]
    -- 修改玩家名字的截取函数
    nickname = kod.util.String.getMaxLenString(nickname, 8)
    nickname = nickname .. "(房主)"
    local headimgurl = args[5]

    -- 设置玩家的名称，id以及头像
    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, headimgurl)
    self._txtHostPlayerName:setString(nickname)
    self._txtHostPlayerID:setString("ID:" .. creator)

    -- set game play rules
    -- 将数字值转为字符串值
    local allRule = room.RoomSettingHelper.convert2OptionTypes(ruleValues)

    -- 玩法中文字
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    local gameType = ruleType[allRule[1]][2]

    -- 所有子规则
    local description = ""
    for i=2, #allRule do
        local ruleDesc = ruleType[allRule[i]][2]
        description = description .. ruleDesc .. " "
    end

    self._txtPlayRuleTitle:setString(gameType)

    -- local layout = seekNodeByName(self, "Panel_bd4_QuiteJoin", "ccui.Layout")
    -- local s1 = layout:getContentSize()
    -- self._txtPlayRule:ignoreContentAdaptWithSize(false)
    -- local s2 = self._txtPlayRule:getVirtualRendererSize()
    local s2 = self._txtPlayRule:getContentSize()
    self._txtPlayRule:setTextAreaSize(s2)
    self._txtPlayRule:setString(description)
end

function UIQuickJoin:needBlackMask()
	return true;
end

function UIQuickJoin:closeWhenClickMask()
	return false
end

function UIQuickJoin:_onClose()
    UIManager:getInstance():destroy("UIQuickJoin")
end

function UIQuickJoin:_onJoinRoom()
    game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._roomId, game.globalConst.JOIN_ROOM_STYLE.MagicWindow)
end

function UIQuickJoin:_onCancelJoinRoom()
    self:_onClose()
end

return UIQuickJoin
