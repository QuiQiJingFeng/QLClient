local csbPath = "ui/csb/BigLeague/UIBigLeagueGameRuleLottery.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGameRuleLottery:UIBase
local UIBigLeagueGameRuleLottery = super.buildUIClass("UIBigLeagueGameRuleLottery", csbPath)

--[[
    第一版抽奖配置界面
        此界面暂时不用
]]

function UIBigLeagueGameRuleLottery:ctor()

end

function UIBigLeagueGameRuleLottery:init()
    self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")

    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)

    self._checkBox = {}
    for i = 1, 3 do
        local isSelected = false
        local checkBox = seekNodeByName(self, "CheckBox_" .. i, "ccui.CheckBox")
        checkBox:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = checkBox:isSelected()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                self:_onItemTypeClicked(self._isSuperLeague and i or self._prizeId)
                --checkBox:setSelected(true)
            elseif eventType == ccui.TouchEventType.canceled then
                checkBox:setSelected(isSelected)
            end
        end)
        self._checkBox[i] = checkBox
    end
end

function UIBigLeagueGameRuleLottery:_onItemTypeClicked(id)
    -- 按钮的显示与隐藏
    for k,v in pairs(self._checkBox) do
        if k == id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end

    self._prizeId = id
end

function UIBigLeagueGameRuleLottery:_onClickCancel()
    self:hideSelf()
end

function UIBigLeagueGameRuleLottery:_onClickOk()
    if self._callBack then
        self._callBack(self._prizeId)
        self:hideSelf()
    end
end

function UIBigLeagueGameRuleLottery:onShow(prizeId, callBack)
    self._isSuperLeague = game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() == false
    self._callBack = callBack
    self:_onItemTypeClicked(prizeId)
end

function UIBigLeagueGameRuleLottery:onHide()

end

function UIBigLeagueGameRuleLottery:needBlackMask()
    return true
end

function UIBigLeagueGameRuleLottery:closeWhenClickMask()
    return false
end

function UIBigLeagueGameRuleLottery:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueGameRuleLottery