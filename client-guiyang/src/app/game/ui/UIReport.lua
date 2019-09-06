local csbPath = "ui/csb/UIReport.csb"
local super = require("app.game.ui.UIBase")
local UIReport = class("UIReport", super, function() return cc.CSLoader:createNode(csbPath) end)

--[[
    举报
]]

function UIReport:ctor(parent)
	self._parent = parent

	self._btnReport = seekNodeByName(self, "Button_report", "ccui.Button") -- 举报
	self._textMail = seekNodeByName(self, "TextField_mail", "ccui.TextField") -- 邮箱
	self._textContent = seekNodeByName(self, "TextField_content", "ccui.TextField") -- 举报内容

	bindEventCallBack(self._btnReport, handler(self, self._onBtnReport), ccui.TouchEventType.ended)
end

-- 界面显示
function UIReport:show()
	self:setVisible(true)

end

-- 举报
function UIReport:_onBtnReport()
	local mail = string.trim(self._textMail:getString())
	local content = string.trim(self._textContent:getString())
	if string.len(mail) == 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入邮箱地址")
		return
	end
	if string.len(content) == 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("请输入举报内容")
		return
	end

	game.service.NoticeMailService:getInstance():sendCGAccusePlayerREQ(mail, content)
end

-- 界面隐藏
function UIReport:hide()
	self._textMail:setString("")
	self._textContent:setString("")
end

return UIReport