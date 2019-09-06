local csbPath = "ui/csb/BigLeague/UIBigLeagueScoreSetting.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueScoreSetting:UIBase
local UIBigLeagueScoreSetting = super.buildUIClass("UIBigLeagueScoreSetting", csbPath)

--[[
    分数设置界面
        目前用于成员设置初始分、调整分数
]]

function UIBigLeagueScoreSetting:ctor()

end

function UIBigLeagueScoreSetting:init()
    self._textTitle = seekNodeByName(self, "BitmapFontLabel_Title", "ccui.TextBMFont")
    self._textScoreTips = seekNodeByName(self, "Text_tips", "ccui.Text")

    self._btnScore = seekNodeByName(self, "Button_Score", "ccui.Button")
    self._textScore = seekNodeByName(self, "Text_Score", "ccui.Text")

    self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")

    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnScore, handler(self, self._onClickScore), ccui.TouchEventType.ended)
end
function UIBigLeagueScoreSetting:_onClickCancel()
    self:hideSelf()
end

function UIBigLeagueScoreSetting:_onClickScore()
    if self._isSymbol then
        if self._symbol == "" then
            UIManager:getInstance():show("UIKeyboard2", self._title, 6, "请输入正确的赛事分", "确定", function (score)
                self._textScore:setString(score)
                event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
            end)
        else
            UIManager:getInstance():show("UIKeyboard3", self._title, 6, "请输入正确的赛事分", "确定", function (score)
                score = string.format("%s%0.2f", self._symbol, math.round(tonumber(score) * 100) / 100)
                self._textScore:setString(score)
                event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
            end)
        end
    else
        UIManager:getInstance():show("UIKeyboard", self._title, 6, "请输入正确的赛事分", "确定", function (score)
            self._textScore:setString(tonumber(score))
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end

end

function UIBigLeagueScoreSetting:_onClickOk()
    if tonumber(self._textScore:getString()) == nil then
        game.ui.UIMessageTipsMgr.getInstance():showTips(self._tips)
        return
    end
    if self._callBack then
        self._callBack(tonumber(self._textScore:getString()))
        self:hideSelf()
    end
end

--[[
    title：标题
    tips：输入框默认显示内容
    scoreTips：分数提示
    isSymbol：是否需要+/-
    symbol: +/-
    callBack：回调
]]
function UIBigLeagueScoreSetting:onShow(title, tips, scoreTips, isSymbol, symbol, callBack)
    self._callBack = callBack
    self._title = title
    self._tips = tips
    self._textTitle:setString(title)
    self._textScore:setString(tips)
    self._textScoreTips:setString(scoreTips)
    self._isSymbol = isSymbol
    self._symbol = symbol or ""

    self:playAnimation_Scale()
end

function UIBigLeagueScoreSetting:onHide()

end

function UIBigLeagueScoreSetting:needBlackMask()
    return true
end

function UIBigLeagueScoreSetting:closeWhenClickMask()
    return false
end

function UIBigLeagueScoreSetting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueScoreSetting