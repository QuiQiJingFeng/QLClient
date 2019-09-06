local csbPath = "ui/csb/BigLeague/UIBigLeagueMask.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMask:UIBase
local UIBigLeagueMask = super.buildUIClass("UIBigLeagueMask", csbPath)

--[[
    遮罩界面
        暂时无用
]]

function UIBigLeagueMask:ctor()

end

function UIBigLeagueMask:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIBigLeagueMask:_onClickClose()
    if self._callBack then
        self._callBack()
        self:hideSelf()
    end
end

function UIBigLeagueMask:onShow(callBack)
    self._callBack = callBack
end

function UIBigLeagueMask:onHide()

end

function UIBigLeagueMask:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIBigLeagueMask