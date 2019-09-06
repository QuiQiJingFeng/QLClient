--[[    邮件系统
    1.这里还有一个要处理的情况，如果界面在打开的时候下，如果收到邮件列表，应该再刷新一下
      以上现在不需要处理，收到邮件才处理的显示邮件，所以这种情况下，应该是自动刷新了
    2.在删除邮件报错的情况下，或打开报错的情况下，也应该再请求一下全部列表，重新刷新一下
]]
local csbPath = "ui/csb/Mail/UIMailMain.csb"
local UIMailMain = class("UIMailMain", function() return cc.CSLoader:createNode(csbPath) end)


local ListFactory = require("app.game.util.ReusedListViewFactory")

local mailIcon = {
	normalType = {unused = "art/club/img_mail.png", used = "art/club/img_mail1.png"},
	rewardType = {unused = "art/club/img_mail2.png", used = "art/club/img_mail3.png"},
}

local function getMailIcon(mailStatus, isRewardType)
	local type = ""
	if isRewardType then
		type = mailIcon["rewardType"] [mailStatus == net.protocol.MailStatus.RECEIVED and "used" or "unused"]
	else
		type = mailIcon["normalType"] [mailStatus == net.protocol.MailStatus.UNREAD and "unused" or "used"]
	end
	
	return type
end

local function getMailIsNeedRed(mailStatus, isRewardType)
	return(mailStatus == net.protocol.MailStatus.UNREAD) or(mailStatus ~= net.protocol.MailStatus.RECEIVED and isRewardType)
end

local bgType = {
	[true] = 'art/img/img_dbt.png',
	[false] = 'art/img/img_dbtx.png',
}

--初始化list控件中的每个单元
local function initDetailList(listItem)
	listItem.title = seekNodeByName(listItem, "textMailTitle", "ccui.Text")
	listItem.mailIcon = seekNodeByName(listItem, "mailIcon", "ccui.ImageView")
	listItem.txtSummary = seekNodeByName(listItem, "textSummary", "ccui.Text") -- 邮件摘要
	listItem.txtDate = seekNodeByName(listItem, "textDate", "ccui.Text")
	listItem.imgRed = seekNodeByName(listItem, "imgRed", "ccui.ImageView")
	
end

--给list中的控件赋值
local function setListData(listItem, value)
	
	local shortTitle = kod.util.String.getMaxLenString(value.title, 8)
	local shortContent = kod.util.String.getMaxLenString(value.content, 16) .. '...'
	shortContent = string.split(shortContent, '\n\r') [1] -- 去除换行
	listItem.title:setString(shortTitle)
	listItem.txtSummary:setString(shortContent)
	local date = os.date("%Y/%m/%d", value.sendTime / 1000)
	listItem.txtDate:setString(date)
	
	--设置显示
	local setStatus = function()
		local iconType = getMailIcon(value.status, #value.item > 0)
		local isNeedRed = getMailIsNeedRed(value.status, #value.item > 0)
		listItem.mailIcon:loadTexture(iconType)
		listItem.imgRed:setVisible(isNeedRed)
		listItem:setBackGroundImage(bgType[isNeedRed])
		listItem:setBackGroundImageCapInsets(cc.rect(10, 10, 10, 10))
	end
	
	setStatus()
	
	--点击邮件的回调
	bindEventCallBack(listItem, function()
		-- 如果本地是未读状态则发送协议直接改变对应状态
		if value.status == net.protocol.MailStatus.UNREAD then
			game.service.NoticeMailService:getInstance():onCGChangeMailREQ(value.id, net.protocol.MailStatus.READ)
			value.status = net.protocol.MailStatus.READ
			setStatus()
		end
		UIManager.getInstance():show("UIMail", value)
	end, ccui.TouchEventType.ended)
end

function UIMailMain:ctor(parent)
    self._parent = parent

    self._listItems = ListFactory.get(
	    seekNodeByName(self, "ListView_Mail_Type_Btn", "ccui.ListView"),
	    initDetailList,
	    setListData
    )

    self._mailNone = seekNodeByName(self, "Image_Node", "ccui.ImageView")
	self._btnDeleteAllRead = seekNodeByName(self, "Button_Delete_All_Read", "ccui.Button")
	bindEventCallBack(self._btnDeleteAllRead, handler(self, self._onBtnDeleteAllReadClick), ccui.TouchEventType.ended)
	
	self._listItems:setScrollBarEnabled(false)
	self._initilized = false
	--是否需要重新请求数据
	self.isOld = false
end

function UIMailMain:_onBtnDeleteAllReadClick(sender)
	game.ui.UIMessageBoxMgr.getInstance():show("确定要删除邮件吗", {"确定", "取消"}, function(...)
		game.service.NoticeMailService:getInstance():CGDeleteReadMailsREQ()
	end)
end

function UIMailMain:show()
    self:setVisible(true)

    local noticeMailService = game.service.NoticeMailService:getInstance()
	if not self._initilized then
		self._listItems:deleteAllItems()
		self._mailNone:setVisible(true)
		noticeMailService:onCGQueryMailREQ()
	elseif self.isOld then
		noticeMailService:onCGQueryMailREQ()
	end
	
	noticeMailService:addEventListener("EVENT_MAIL_DELETE", handler(self, self._onMailDelete), self)
	noticeMailService:addEventListener("EVENT_MAIL_REWARD_RECEIVED", handler(self, self.onMailRewardReceive), self)
	noticeMailService:addEventListener("EVENT_MAIL_ARRIVE", handler(self, self._onMailArrive), self)
end

function UIMailMain:hide()
    game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)
	self:setVisible(false)
end

function UIMailMain:_onMailArrive(event)
	self._initilized = true
	self._listItems:deleteAllItems()
	for k, v in ipairs(event.mails) do
		self._listItems:pushBackItem(v)
	end
	
	self._mailNone:setVisible(#event.mails == 0)
end

--邮件被删除
function UIMailMain:_onMailDelete(event)
	self._listItems:deleteItem(event.index)
	self._mailNone:setVisible(event.count == 0)
end

--邮件奖励被领取
function UIMailMain:onMailRewardReceive(event)
	self._listItems:updateItem(event.index, event.data)
end

return UIMailMain