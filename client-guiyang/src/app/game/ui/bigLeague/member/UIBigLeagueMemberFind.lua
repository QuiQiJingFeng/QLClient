local csbPath = "ui/csb/BigLeague/UIBigLeagueMemberFind.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMemberFind:UIBase
local UIBigLeagueMemberFind = super.buildUIClass("UIBigLeagueMemberFind", csbPath)

--[[
    成员查找界面
]]

function UIBigLeagueMemberFind:ctor()

end

function UIBigLeagueMemberFind:init()
    self._btnFind = seekNodeByName(self, "Button_Find", "ccui.Button")
    self._btnClosed = seekNodeByName(self, "Button_Closed", "ccui.Button")
    self._textFieldSearch = seekNodeByName(self, "TextField_PlayerId", "ccui.TextField")

    bindEventCallBack(self._btnFind, handler(self, self._onClickFind), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClosed, function () self:destroySelf() end, ccui.TouchEventType.ended)
end

function UIBigLeagueMemberFind:_onClickFind()
    self._callBack(self._textFieldSearch:getString())
end

function UIBigLeagueMemberFind:onShow(callBack)
    self._callBack = callBack
end

function UIBigLeagueMemberFind:onHide()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIBigLeagueMemberFind:needBlackMask()
    return true
end

function UIBigLeagueMemberFind:closeWhenClickMask()
    return false
end

function UIBigLeagueMemberFind:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIBigLeagueMemberFind