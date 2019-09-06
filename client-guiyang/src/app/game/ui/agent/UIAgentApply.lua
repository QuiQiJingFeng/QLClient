local csbPath = "ui/csb/Agent/UIDlsq2.csb"
local super = require("app.game.ui.UIBase")
local UIRichTextEx = require("app.game.util.UIRichTextEx")

local UIAgentApply = class("UIAgentApply", super, function () return kod.LoadCSBNode(csbPath) end)

function UIAgentApply:ctor()
    self._textId = nil
    self._wechat = nil
    self._phoneNum = nil

    self._btnSubmit = nil
    self._richText = nil
    self._innerText = nil
end

function UIAgentApply:init()
    self._textId = seekNodeByName(self, "Text_Id", "ccui.Text")
    self._wechat = seekNodeByName(self, "TextField_Wechat", "ccui.TextField")
    self._phoneNum = seekNodeByName(self, "TextField_PhoneNum", "ccui.TextField")
    self._btnSubmit = seekNodeByName(self, "Button_Submit", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_x_user", "ccui.Button")
    self._innerText = seekNodeByName(self, "Panel_2", "ccui.Layout")
    self._richText = UIRichTextEx:create{size = 20}    

    self._richText:setAnchorPoint(cc.p(0,0));
    self._richText:setName("richText")
    self._richText:setPosition(cc.p(0,0))

    bindEventCallBack(self._btnSubmit, handler(self, self._onBtnSubmit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIAgentApply:onShow( ... )
    local args = { ... }
    local wechat = args[1]
    self._textId:setString(game.service.LocalPlayerService.getInstance():getRoleId())

    self._innerText:addChild(self._richText)
    local text = "<#8A380C>聚友贵州麻将代理商：是指在当地有相对人脉圈子，并且能邀请身边\n会打麻将的朋友一起来欢乐打麻将<font> <#E43333>详情请咨询客服号:" .. wechat .. "<font>"
    self._richText:setText(text)

    self._wechat:setTextColor(cc.c4b(151, 86, 31, 255))
    self._phoneNum:setTextColor(cc.c4b(151, 86, 31, 255))
end

function UIAgentApply:onHide()
end

function UIAgentApply:_onBtnSubmit()
    local wechat = ""
    local phoneNum = ""

    wechat = self._wechat:getString()
    phoneNum = self._phoneNum:getString()

    if wechat == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入微信号")
        return
    elseif phoneNum == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入手机号")
        return
    end

    if string.match(phoneNum,"[1][3,4,5,6,7,8,9]%d%d%d%d%d%d%d%d%d") ~= phoneNum then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的手机号")
        return
    end

    for word in string.gmatch(wechat, "[^%w_]") do
        if self:judgeHasWord(word) == false then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的微信号")
            return
        end     
    end

    if #wechat > 30 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的微信号")
        return
    end

    game.ui.UIMessageBoxMgr.getInstance():show("确定微信号是:" .. wechat .. "\n" .. "手机号是:" .. phoneNum, {"确定","取消"}, function()
        game.service.AgentService.getInstance():queryCGApplyToAgt(phoneNum, wechat)
    end)
end

function UIAgentApply:judgeHasWord(string)
    local hasWord = false
    local lenInByte = #string
    
    
    for i=1, lenInByte do
        local curByte = string.byte(string, i)
        if curByte<=0 or curByte>127 then
            hasWord = true
        end
    end 
    
    return hasWord
end

function UIAgentApply:_onBtnClose()
    UIManager:getInstance():destroy("UIAgentApply")
end

function UIAgentApply:needBlackMask()
	return true;
end

function UIAgentApply:closeWhenClickMask()
	return false
end

return UIAgentApply