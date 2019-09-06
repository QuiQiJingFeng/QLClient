--[[	邮件item
]]
local csbPath = 'ui/csb/Mail/UIMail.csb'
local super = require("app.game.ui.UIBase")
local ElemAttachment = require("app.game.ui.message.ElemAttachment")
local UIMail = class("UIMail", super, function() return kod.LoadCSBNode(csbPath) end)


function UIMail:needBlackMask() return true end

function UIMail:ctor(root)
	self._data = nil --缓存邮件信息
end

function UIMail:init()
	self._txtTitle = seekNodeByName(self, "Text_tital_Mail", "ccui.Text")
	self._txtContent = seekNodeByName(self, "Text_content_Mail", "ccui.Text")
	self._btnDelete = seekNodeByName(self, "btnDelete", "ccui.Button")
	self._btnDraw = seekNodeByName(self, "btnDraw", "ccui.Button")
	self._btnReceived = seekNodeByName(self, "btnReceived", "ccui.Button")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	
	
	self._scrollView = seekNodeByName(self, "ScrollView_Mail", "ccui.ScrollView")
	self._scrollView:setScrollBarEnabled(false)
	
	self._time = seekNodeByName(self, "Text_tital_Mail_Time", "ccui.Text")
	
	self._listAttachment = ElemAttachment.extend(seekNodeByName(self, "listAttachment", "ccui.ListView"))
	
	bindEventCallBack(self._btnDelete, handler(self, self._onBtnDelete), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDraw, handler(self, self._onBtnDraw), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	-- self._btnReceived:setEnabled(true)
	-- bindEventCallBack(self._btnReceived, function ( ... )
	--     UIManager.getInstance():show("UIReceiveMailAttachment", self._data)
	-- end, ccui.TouchEventType.ended)
end

--[[    显示
    @param data 要显示的内容
]]
function UIMail:onShow(data)
	self:setVisible(true)
	self._data = data
	self._time:setString(os.date("%Y/%m/%d", data.sendTime / 1000))
	self._txtContent:setString(data.content)
	self._txtContent:ignoreContentAdaptWithSize(false)
	self._txtTitle:setString(data.title)
	
	local size = self._scrollView:getContentSize()			
	
	local height = 240
	if #data.item > 0 then
		height = 110
	end
	self._scrollView:stopAutoScroll()
	self._scrollView:setContentSize(cc.size(size.width, height))
	self._txtContent:setTextAreaSize(cc.size(size.width, 0))
	
	local realSize = self._txtContent:getVirtualRendererSize()
	self._txtContent:setContentSize(cc.size(size.width, realSize.height))
	self._scrollView:setInnerContainerSize(cc.size(size.width, realSize.height))
	if height < realSize.height then
		self._txtContent:setPositionY(realSize.height)
	else
		self._txtContent:setPositionY(height)
	end
	
	local setStatus = function()
		self._btnDelete:setVisible(#self._data.item == 0)
		self._btnDraw:setVisible(self._data.status ~= net.protocol.MailStatus.RECEIVED and #self._data.item > 0)
		self._btnReceived:setVisible(self._data.status == net.protocol.MailStatus.RECEIVED)
		self._listAttachment:setVisible(#self._data.item > 0)
	end
	
	setStatus()
	
	self._listAttachment:setAttachment(self._data.item)
	
	local noticeMailService = game.service.NoticeMailService:getInstance()
	
	--删除一个邮件必须打开这个界面所以不做判断直接关闭界面
	noticeMailService:addEventListener("EVENT_MAIL_DELETE", handler(self, self._close), self)
	--领取附件也需要打开界面,所以也不判断了直接当做领取成功
	noticeMailService:addEventListener("EVENT_MAIL_REWARD_RECEIVED", function(event)
		--数据引用的都是一个,所以这边应该不需要重新复制self._data
		setStatus()
		
		UIManager.getInstance():show("UIReceiveMailAttachment", self._data)
	end, self)
	
end

--关闭界面
function UIMail:_close()
	UIManager.getInstance():hide("UIMail")
end

--[[    隐藏
]]
function UIMail:onHide()
	game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)	
end
--[[   
    领取附加
]]
function UIMail:_onBtnDraw()
	game.service.NoticeMailService:getInstance():queryReceiveItem(self._data.id)
end

-- 删除邮件
function UIMail:_onBtnDelete()
	game.ui.UIMessageBoxMgr.getInstance():show("确定要删除邮件吗", {"确定", "取消"}, function(...)
		game.service.NoticeMailService:getInstance():onCGChangeMailREQ(self._data.id, net.protocol.MailStatus.DELETE)
	end)
end

return UIMail 