local csbPath = "ui/csb/BigLeague/UIBigLeagueLottery.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueLottery:UIBase
local UIBigLeagueLottery = super.buildUIClass("UIBigLeagueLottery", csbPath)

function UIBigLeagueLottery:ctor()

end

function UIBigLeagueLottery:init()
    self._textScore = seekNodeByName(self, "Text_Name", "ccui.Text")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")

    bindEventCallBack(self._btnOk, function ()
        self:hideSelf()
    end , ccui.TouchEventType.ended)
end

function UIBigLeagueLottery:onShow(score)
    self._textScore:setString(string.format("恭喜您获得%s金币", score))
    self:playAnimation_Scale()
end

function UIBigLeagueLottery:onHide()

end

function UIBigLeagueLottery:needBlackMask()
    return true
end

function UIBigLeagueLottery:closeWhenClickMask()
    return false
end

function UIBigLeagueLottery:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIBigLeagueLottery