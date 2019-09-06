local csbPath = "ui/csb/BigLeague/UIBigLeagueHelp.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueHelp:UIBase
local UIBigLeagueHelp = super.buildUIClass("UIBigLeagueHelp", csbPath)

local ScrollText = require("app.game.util.ScrollText")

--[[
    帮助界面
        参数：string 内容
]]

function UIBigLeagueHelp:ctor()

end

function UIBigLeagueHelp:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

    self._textContent = ScrollText.new(seekNodeByName(self, "Text_Content", "ccui.Text"), 26, true)

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIBigLeagueHelp:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueHelp:onShow(str)
    self._textContent:setString(str)
    self:playAnimation_Scale()
end

function UIBigLeagueHelp:onHide()

end

function UIBigLeagueHelp:needBlackMask()
    return true
end

function UIBigLeagueHelp:closeWhenClickMask()
    return false
end

function UIBigLeagueHelp:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueHelp