local csbPath = "ui/csb/GamePlays/guizhoudiy/UIGuMai.csb"
local super   = require("app.game.ui.UIBase")

local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local UIGuMai = class("UIGuMai", super, function ()return kod.LoadCSBNode(csbPath) end)

function UIGuMai:cotr()
    self._btnDefine         = nil
    self._checkBox_BGM      = nil
    self._checkBox_GM2F     = nil
    self._checkBox_GM3F     = nil
    self._checkBox_GM4F     = nil
    self._selectScores      = nil
end

function UIGuMai:_sendPlayStep(playType, cards)
	gameMode.mahjong.Context.getInstance():getGameService():sendPlayStep(playType, cards);
end

function UIGuMai:init()
    self._btnDefine     = seekNodeByName(self, "Button_queding", "ccui.Button");
    self._checkBox_BGM  = seekNodeByName(self, "CheckBox_BUGUMAI", "ccui.CheckBox");
    self._checkBox_GM2F = seekNodeByName(self, "CheckBox_GM2F", "ccui.CheckBox");
    self._checkBox_GM3F = seekNodeByName(self, "CheckBox_GM3F", "ccui.CheckBox");
    self._checkBox_GM4F = seekNodeByName(self, "CheckBox_GM4F", "ccui.CheckBox");

    self:_registerCallBack()
end

function UIGuMai:_registerCallBack()
    bindEventCallBack(self._btnDefine, handler(self, self._onBtnDefine), ccui.TouchEventType.ended);
    bindEventCallBack(self._checkBox_BGM, handler(self, self._onCheckBox_BGM), ccui.TouchEventType.ended);
    bindEventCallBack(self._checkBox_GM2F, handler(self, self._onCheckBox_GM2F), ccui.TouchEventType.ended);
    bindEventCallBack(self._checkBox_GM3F, handler(self, self._onCheckBox_GM3F), ccui.TouchEventType.ended);
    bindEventCallBack(self._checkBox_GM4F, handler(self, self._onCheckBox_GM4F), ccui.TouchEventType.ended);
end

function UIGuMai:onShow(...)
    self:_onCheckBox_BGM()
end

function UIGuMai:_onBtnDefine()
    self:_sendPlayStep(PlayType.OPERATE_GU_MAI, {self._selectScores})
    self:_onHide()
end

function UIGuMai:_onCheckBox_BGM()
    self._checkBox_BGM:setSelected(true)
    self._checkBox_GM2F:setSelected(false)
    self._checkBox_GM3F:setSelected(false)
    self._checkBox_GM4F:setSelected(false)
    self._selectScores = 0
end

function UIGuMai:_onCheckBox_GM2F()
    self._checkBox_BGM:setSelected(false)
    self._checkBox_GM2F:setSelected(true)
    self._checkBox_GM3F:setSelected(false)
    self._checkBox_GM4F:setSelected(false)
    self._selectScores = 2
end

function UIGuMai:_onCheckBox_GM3F()
    self._checkBox_BGM:setSelected(false)
    self._checkBox_GM2F:setSelected(false)
    self._checkBox_GM3F:setSelected(true)
    self._checkBox_GM4F:setSelected(false)
    self._selectScores = 3
end

function UIGuMai:_onCheckBox_GM4F()
    self._checkBox_BGM:setSelected(false)
    self._checkBox_GM2F:setSelected(false)
    self._checkBox_GM3F:setSelected(false)
    self._checkBox_GM4F:setSelected(true)
    self._selectScores = 4
end

function UIGuMai:_onHide()
    UIManager:getInstance():hide("UIGuMai");
end

function UIGuMai:needBlackMask()
	return true;
end

function UIGuMai:closeWhenClickMask()
	return false
end

return UIGuMai