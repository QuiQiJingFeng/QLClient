--[[
成功解散页面Tip,需要满足条件:
1. 俱乐部第一局未完成即解散房间
2. 玩家ID尾号为0,1的用户可见
]]
local super = require("app.game.ui.UIBase")
local UIDissmissAdvert = class("UIDissmissTip", super, function()
	return kod.LoadCSBNode("ui/csb/UIDissmissAdvert.csb")
end)

function UIDissmissAdvert:ctor()
    self._TextState = nil       -- 文本介绍
    self._chuanqiBtn = nil      -- 传奇按钮
    self._moyuBtn = nil         -- 魔域按钮
    self._sureBtn = nil         -- 确认按钮
    self._closeBtn = nil        -- 关闭按钮
    self._callBack = nil        -- 
end

function UIDissmissAdvert:init()
    self._TextState = seekNodeByName(self, "Text_State", "ccui.Text")
    self._chuanqiBtn = seekNodeByName(self, "Btn_ChuanQi", "ccui.Button")
    self._moyuBtn = seekNodeByName(self, "Btn_MoYu", "ccui.Button")
    self._sureBtn = seekNodeByName(self, "Button_Sure", "ccui.Button")
    self._closeBtn = seekNodeByName(self, "Button_Close", "ccui.Button")
    
    self:_registerEvent()
end

function UIDissmissAdvert:_registerEvent()
    bindEventCallBack(self._chuanqiBtn, handler(self, self._onChuanQiEvent), ccui.TouchEventType.ended)
    bindEventCallBack(self._moyuBtn, handler(self, self._onMoYuEvent), ccui.TouchEventType.ended)
    bindEventCallBack(self._sureBtn, handler(self, self._onCloseEvent), ccui.TouchEventType.ended)
    bindEventCallBack(self._closeBtn, handler(self, self._onCloseEvent), ccui.TouchEventType.ended)
end 

function UIDissmissAdvert:onShow(...)
    local args = {...}
    self._callBack = args[1]
    self._TextState:setString("房间已解散，更多好玩游戏福利送不停！")

    -- 统计
    local eventKey = game.globalConst.StatisticNames.Show_DissmissAdvert
    game.service.DataEyeService.getInstance():onEvent(eventKey)
end

-- 传奇按钮事件
function UIDissmissAdvert:_onChuanQiEvent(sender)
    uiSkip.UISkipTool.skipTo("chuanqi", {eventKey = game.globalConst.StatisticNames.Button_Legend_DissWinTip}) 
end

-- 魔域按钮事件
function UIDissmissAdvert:_onMoYuEvent(sender)
    uiSkip.UISkipTool.skipTo("moyu", {eventKey = game.globalConst.StatisticNames.Button_Moyu_DissWinTip}) 
end

function UIDissmissAdvert:_onCloseEvent(sender)
    UIManager:getInstance():hide("UIDissmissAdvert")
    if self._callBack ~= nil and type(self._callBack) == "function" then 
        self._callBack()
    end 
end

function UIDissmissAdvert:needBlackMask()
    return true
end

return UIDissmissAdvert
