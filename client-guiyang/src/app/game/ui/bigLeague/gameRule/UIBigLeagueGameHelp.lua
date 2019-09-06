local csbPath = "ui/csb/BigLeague/UIBigLeagueGameHelp.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGameHelp:UIBase
local UIBigLeagueGameHelp = super.buildUIClass("UIBigLeagueGameHelp", csbPath)

local ScrollText = require("app.game.util.ScrollText")

--[[
    帮助界面
        参数：string 内容
]]

function UIBigLeagueGameHelp:ctor()

end

function UIBigLeagueGameHelp:init()
    self._textContent = ScrollText.new(seekNodeByName(self, "Text_help", "ccui.Text"), 24, true)
    self._btnClose = seekNodeByName(self, "Button_Closed", "ccui.Button")
    bindEventCallBack(self._btnClose,handler(self,self._onClose),ccui.TouchEventType.ended)
end

function UIBigLeagueGameHelp:onShow(str)
    self._textContent:setString(str)
end

function UIBigLeagueGameHelp:onHide()

end

function UIBigLeagueGameHelp:_onClose()
    UIManager:getInstance():destroy("UIBigLeagueGameHelp")
end

function UIBigLeagueGameHelp:needBlackMask()
    return true
end

function UIBigLeagueGameHelp:closeWhenClickMask()
    return false
end

function UIBigLeagueGameHelp:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueGameHelp