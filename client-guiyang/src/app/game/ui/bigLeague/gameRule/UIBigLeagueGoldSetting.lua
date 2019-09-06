local csbPath = "ui/csb/BigLeague/UIBigLeagueGoldSetting.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGoldSetting:UIBase
local UIBigLeagueGoldSetting = super.buildUIClass("UIBigLeagueGoldSetting", csbPath)

--[[
    金币抽奖配置界面
        用于A设置金币抽奖最小值最大值，B、C查看
]]

function UIBigLeagueGoldSetting:ctor()

end

function UIBigLeagueGoldSetting:init()
    self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")
    self._btnOk1 = seekNodeByName(self, "Button_Ok_1", "ccui.Button")
    self._textTips = seekNodeByName(self, "Text_Tips", "ccui.Text")

    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk1, handler(self, self._onClickOk), ccui.TouchEventType.ended)

    self._textMin = seekNodeByName(self, "Text_Min", "ccui.Text")
    self._textMax = seekNodeByName(self, "Text_Max", "ccui.Text")
    self._btnMin = seekNodeByName(self, "Button_Min", "ccui.Button")
    self._btnMax = seekNodeByName(self, "Button_Max", "ccui.Button")

    bindEventCallBack(self._btnMin, handler(self, self._onClickMin), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMax, handler(self, self._onClickMax), ccui.TouchEventType.ended)
end

function UIBigLeagueGoldSetting:_onClickMin()
    if self._isSuperLeague then
        UIManager:getInstance():show("UIKeyboard", "抽奖金币最低分", 5, "分数输入有误，请重新输入", "确定", function (point)
            if tonumber(point) < 1 then
                game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖金币范围:1-10000")
                return
            end
            self._textMin:setString(tonumber(point))
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end
end

function UIBigLeagueGoldSetting:_onClickMax()
    if self._isSuperLeague then
        UIManager:getInstance():show("UIKeyboard", "抽奖金币最高分", 5, "分数输入有误，请重新输入", "确定", function (point)
            if tonumber(point) > 10000 then
                game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖金币范围:1-10000")
                return
            end
            self._textMax:setString(tonumber(point))
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end
end

function UIBigLeagueGoldSetting:_onClickCancel()
    self:hideSelf()
end

function UIBigLeagueGoldSetting:_onClickOk()
    if tonumber(self._textMin:getString()) > tonumber(self._textMax:getString()) then
        game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖金币最低值应小于最高值")
        return
    end

    if self._callBack then
        self._callBack(self._textMin:getString(), self._textMax:getString())
        self:hideSelf()
    end
end

function UIBigLeagueGoldSetting:onShow(min, max, callBack)
    self._isSuperLeague = game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague()
    self._callBack = callBack

    self._textMin:setString(min)
    self._textMax:setString(max)

    self._btnOk:setVisible(self._isSuperLeague)
    self._btnOk1:setVisible(not self._isSuperLeague)
    self._btnCancel:setVisible(self._isSuperLeague)
    self._textTips:setVisible(self._isSuperLeague)

    self:playAnimation_Scale()
end

function UIBigLeagueGoldSetting:onHide()

end

function UIBigLeagueGoldSetting:needBlackMask()
    return true
end

function UIBigLeagueGoldSetting:closeWhenClickMask()
    return false
end

function UIBigLeagueGoldSetting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueGoldSetting