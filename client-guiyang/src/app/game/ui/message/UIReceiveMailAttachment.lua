local csbPath = 'ui/csb/Mail/UIReceiveMailAttachment.csb'
local super = require("app.game.ui.UIBase")
local ElemAttachment = require("app.game.ui.message.ElemAttachment")

local UIReceiveMailAttachment = class("UIReceiveMailAttachment", super, function() return kod.LoadCSBNode(csbPath) end)

function UIReceiveMailAttachment:needBlackMask() return true end
function UIReceiveMailAttachment:closeWhenClickMask() return true end

function UIReceiveMailAttachment:ctor()
	self._data = nil --缓存邮件信息
end

function UIReceiveMailAttachment:init()
	self._listAttachment = ElemAttachment.extend(seekNodeByName(self, "listAttachment", "ccui.ListView"))
	self._textTitle = seekNodeByName(self, "textTitle", "ccui.Text")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	
	bindEventCallBack(self._btnClose, function(...)
		UIManager.getInstance():hide("UIReceiveMailAttachment")
	end, ccui.TouchEventType.ended)
	
end

function UIReceiveMailAttachment:onShow(data)
	self._data = data
	self._listAttachment:setAttachment(data.item)
	if data.title then
		self._textTitle:setString(data.title)
	end
	local noticeMailService = game.service.NoticeMailService:getInstance()
end

function UIReceiveMailAttachment:onHide()
end

return UIReceiveMailAttachment 