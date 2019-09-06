--[[
    大联盟公告编辑界面
]]
local csbPath = "ui/csb/BigLeague/UIBigLeagueEditNotice.csb"
local super = require("app.game.ui.UIBase")
local LIMIT_COUNT = 120           -- 限定120个字符

local UIBigleagueEditNotice = class("UIBigleagueEditNotice", super, function() 
    return kod.LoadCSBNode(csbPath) 
end)

function UIBigleagueEditNotice:ctor()
    self._panel = nil                       -- 
    self._btnOk = nil                       -- 确定
    self._textInput = nil                   -- 输入框
    self._clubId = nil                      -- 亲友圈Id
    self._btnQuit = nil                     -- 退出
end

function UIBigleagueEditNotice:init()
    self._panel = seekNodeByName(self, "Panel_Node", "ccui.Layout")
    self._textInput = seekNodeByName(self, "TextField_input", "ccui.TextField")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")
     self._btnQuit = seekNodeByName(self, "Button_Close", "ccui.Button")

    bindEventCallBack(self._btnOk, handler(self, self._onBtnOKClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
    self._textInput:addEventListener(handler(self, self._onTextFieldChanged))
end 

function UIBigleagueEditNotice:onShow(clubId, clubNotice)
    self._clubId = clubId
    self._clubNotice = clubNotice

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)

    if club.data == nil then
        return
    end

    -- 设置输入框的颜色
    self._textInput:setTextColor(cc.c4b(164, 137, 69, 255))
    self._textInput:setString(club.data.clubNotice)
end

function UIBigleagueEditNotice:_onTextFieldChanged(sender, eventType)
    -- 当是插入文字的时候
	if eventType == ccui.TextFiledEventType.attach_with_ime  then
		if device.platform == "ios" then
			self._panel:setPositionPercent(cc.p(0.5,0.7))
		end
		if sender:getString() == "" then
			sender:setString(" ")
		end
	end
	if eventType == ccui.TextFiledEventType.detach_with_ime then
		if device.platform == "ios" then 
			self._panel:setPositionPercent(cc.p(0.5,0.5))
		end
		if sender:getString() == " " then	
			sender:setString("")
        end
    elseif eventType == ccui.TextFiledEventType.insert_text then
        local content = kod.util.String.getMaxLenString(sender:getString(), LIMIT_COUNT)
        self._textInput:setString(content)
	end
end

function UIBigleagueEditNotice:_onBtnOKClick()
    local content = self._textInput:getString()
    local len = kod.util.String.getUTFLen(content)
    if len > LIMIT_COUNT then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("最多输入120个字符")
        return 
    end 

    if self._clubNotice == content then
        self:_onBtnQuitClick()
        return
    end

    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)

    local clubservice = game.service.club.ClubService.getInstance()
    clubservice:getClubManagerService():sendCCLModifyClubNoticeREQ(self._clubId, content)
end

function UIBigleagueEditNotice:_onBtnQuitClick()
    UIManager:getInstance():hide("UIBigleagueEditNotice")
end

function UIBigleagueEditNotice:onHide()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)
end

function UIBigleagueEditNotice:needBlackMask()
	return true
end

function UIBigleagueEditNotice:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIBigleagueEditNotice:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

return UIBigleagueEditNotice
