local csbPath = "ui/csb/CKTRHF.csb"
local super = require("app.game.ui.UIBase")
local UIReplay= class("UIReplay", super, function()
    return kod.LoadCSBNode(csbPath)
end)

function UIReplay:ctor()
    self._panel = seekNodeByName(self , "Panel_Node", "ccui.Layout")
    self._btnClose = seekNodeByName(self , "Button_1", "ccui.Button")
    self._textField = seekNodeByName(self , "TextField_1", "ccui.TextField")
    
    self._btnCommit = seekNodeByName(self , "Button_qd_messagebox", "ccui.Button")
    self._btnCancel = seekNodeByName(self , "Button_qx_messagebox", "ccui.Button")

    self._textField:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self._textField:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self._textField:addEventListener(handler(self,self._onTextChange))
    self._textField:setMaxLengthEnabled(true)
    self._maxLength = 11
    self._textField:setMaxLength(self._maxLength)
    self._textField:setTextColor(cc.c4b(151, 86, 31, 255))

    bindEventCallBack(self._btnClose, handler(self, self._onHide), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCommit, handler(self, self._onCommit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onHide), ccui.TouchEventType.ended)

end

function UIReplay:onShow()
    self._textField:setString("")
end

function UIReplay:_onHide()
    UIManager:getInstance():hide("UIReplay")
end

function UIReplay:needBlackMask()
    return true 
end

function UIReplay:_onCommit() 
    --输入回放码并点击确定的次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.LookReplayRound);
    local replayCode = self._textField:getString()
    game.service.HistoryRecordService.getInstance():queryHistoryRoomByCode(replayCode)
    UIManager:getInstance():hide("UIReplay")
end

--保证输入框只输入正整数
function UIReplay:_onTextChange(textField,eventType)
    if eventType == ccui.TextFiledEventType.attach_with_ime  then
		if device.platform == "ios" then
			self._panel:setPositionPercent(cc.p(0.5,0.6))
		end
		if textField:getString() == "" then
			textField:setString(" ")
		end
	end
	if eventType == ccui.TextFiledEventType.detach_with_ime then
		if device.platform == "ios" then 
			self._panel:setPositionPercent(cc.p(0.5,0.5))
		end
		if textField:getString() == " " then		
			textField:setString("")
		end
    end
    
    if eventType == ccui.TextFiledEventType.insert_text then
        local str = textField:getString()
        if string.len(str) > self._maxLength then
            str = string.sub(str, 1, self._maxLength)
        end
        local v = 0        
        for i = 1,string.len(str) do
            if string.byte(str,i) < string.byte('0') or string.byte(str,i) > string.byte('9') then
                break
            end
            v = i
        end
        if v == 0 then
            str = '0'
        else
            str = string.sub(str, 1, v)
        end
        if str == '0' then
            str = '0'
        end
    
        textField:setString(str)
    end
end

return UIReplay
