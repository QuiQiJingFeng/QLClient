local csbPath = "ui/csb/BigLeague/UIBigLeagueCreate.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueCreate:UIBase
local UIBigLeagueCreate = super.buildUIClass("UIBigLeagueCreate", csbPath)

--[[
    联盟创建界面
        暂时无用，不支持自主创建
]]

function UIBigLeagueCreate:ctor()

end

function UIBigLeagueCreate:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    self._btnCreate = seekNodeByName(self, "Button_Create", "ccui.Button") -- 关闭

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate, handler(self, self._onClickCreate), ccui.TouchEventType.ended)
end

function UIBigLeagueCreate:_onClickClose()
    self:hideSelf()
    GameFSM:getInstance():enterState("GameState_Lobby")
end

function UIBigLeagueCreate:_onClickCreate()

end

function UIBigLeagueCreate:onShow()
    self._action = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._action)
    self._action:play("animation0", true)
end

function UIBigLeagueCreate:onHide()

end

function UIBigLeagueCreate:needBlackMask()
    return true
end

function UIBigLeagueCreate:closeWhenClickMask()
    return false
end

function UIBigLeagueCreate:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueCreate