local ns = namespace("game.service")

--------------------------------------------------------------------------------------------
-- 本地的保存结构，公告的
local NoticeDataSave = class("NoticeDataSave")
function NoticeDataSave:ctor()
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- 本地的保存结构，邮件的
local MailDataSave = class("MailDataSave")
function MailDataSave:ctor()
end
--------------------------------------------------------------------------------------------
--[[    定义当前用到的事件
    -- 邮件数据到达
    EVENT_MAIL_ARRIVE
    -- 邮件状态改变
    EVENT_MAIL_DELETE
    -- 红点状态改变
    EVENT_REDDOT_CHANGED
]]
--------------------------------------------------------------------------------------------
-- 对外的service，公告，邮件的拆开来写，现在还在同一个文件，方便以后的拆分
local NoticeMailService = class("NoticeMailService")
ns.NoticeMailService = NoticeMailService


-- 单例
function NoticeMailService.getInstance()
	if game.service.LocalPlayerService.getInstance() == nil then
		return nil
	end
	return game.service.LocalPlayerService.getInstance():getNoticeMailService();
end

function NoticeMailService:ctor()
	cc.bind(self, "event")
	
	self._mailData = nil
	self._noticeData = nil
	
	self._activities = {}
	--活动自动的弹出次数
	self._activityShowTime = 0
	
end

function NoticeMailService:clear()
	cc.unbind(self, "event");
end

function NoticeMailService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCNotifyRedDotSYNC.OP_CODE, self, self._onGCNotifyRedDotSYNC);
	requestManager:registerResponseHandler(net.protocol.GCQueryMailRES.OP_CODE, self, self._onGCQueryMailRES);
	requestManager:registerResponseHandler(net.protocol.GCChangeMailRES.OP_CODE, self, self._onGCChangeMailRES);
	requestManager:registerResponseHandler(net.protocol.GCQueryAnnouncementRES.OP_CODE, self, self._onGCQueryAnnouncementRES);
	-- 活动列表
	requestManager:registerResponseHandler(net.protocol.GCQueryActivityRES.OP_CODE, self, self._onGCQueryActivityRES);
	-- 领取附件回复
	requestManager:registerResponseHandler(net.protocol.GCReceiveItemRES.OP_CODE, self, self.onGCReceiveItemRES);
	
	-- 举报回复
	requestManager:registerResponseHandler(net.protocol.GCAccusePlayerRES.OP_CODE, self, self._onGCAccusePlayerRES)
	
	-- 删除所有邮件返回
	requestManager:registerResponseHandler(net.protocol.GCDeleteReadMailsRES.OP_CODE, self, self._onGCDeleteReadMailsRES)
end

function NoticeMailService:dispose()
end

function NoticeMailService:findMailIndexById(id)
	for i = 1, #self._mailData do
		local mail = self._mailData[i]
		if mail.id == id then
			return i
		end
	end
end

-- 服务器主动推送
function NoticeMailService:_onGCNotifyRedDotSYNC(response)
	local protocol = response:getProtocol():getProtocolBuf()
	 self:onRedDotChanged(protocol.type, true)
end

function NoticeMailService:onRedDotChanged(dotType, add)
	add = add or false
	local dotArray = game.service.LocalPlayerService:getInstance():getDotArray()
	local index = table.indexof(dotArray, dotType)
	if add and index == false then
		table.insert(dotArray, dotType)
	elseif add == false and index ~= false then
		table.remove(dotArray, index)
	end
	self:dispatchEvent({name = "EVENT_REDDOT_CHANGED", dotType = dotType, add = add})
end

function NoticeMailService:checkClearMailRed()
	local isNeedRed = false
	for k, v in ipairs(self._mailData) do
		if(v.status == net.protocol.MailStatus.UNREAD) or(v.status ~= net.protocol.MailStatus.RECEIVED and #v.item > 0) then
			isNeedRed = true
			break
		end
	end
	if not isNeedRed then
		self:onRedDotChanged(net.protocol.NMDotType.MAIL)
	end
end

--------------------------------------------------------------------------------------------
-- 公告请求
function NoticeMailService:onCGQueryAnnouncementREQ()
	local request = net.NetworkRequest.new(net.protocol.CGQueryAnnouncementREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	game.util.RequestHelper.request(request)
end

-- 公告返回
function NoticeMailService:_onGCQueryAnnouncementRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_ANNOUNCEMENT_SUCCESS then
		self:dispatchEvent({name = "EVENT_NOTICE", noticeData = protocol.announcement})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

function NoticeMailService:isNoticeDotShow()
	return table.indexof(game.service.LocalPlayerService:getInstance():getDotArray(), net.protocol.NMDotType.ANNOUNCEMENT) ~= false
end
--------------------------------------------------------------------------------------------
-- 简单把两个明显的不同的功能分隔一下，万一那天需要拆开方便一些
--------------------------------------------------------------------------------------------
-- 邮件列表请求
function NoticeMailService:onCGQueryMailREQ()
	Logger.debug("NoticeMailService:onCGQueryMailREQ()")
	local request = net.NetworkRequest.new(net.protocol.CGQueryMailREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	game.util.RequestHelper.request(request)
	
end

-- 邮件列表返回
function NoticeMailService:_onGCQueryMailRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_QUERY_MAIL_SUCCESS then
		-- 成功收到返回后，再发切换页面
		self._mailData = clone(protocol.mails)
		self:dispatchEvent({name = "EVENT_MAIL_ARRIVE", mails = self._mailData})
		self:checkClearMailRed()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 邮件已读回执
function NoticeMailService:onCGChangeMailREQ(id, operate)
	local request = net.NetworkRequest.new(net.protocol.CGChangeMailREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request:getProtocol():setData(id, operate)
	game.util.RequestHelper.request(request);
end

-- 删除所有已读邮件
function NoticeMailService:CGDeleteReadMailsREQ()
	local request = net.NetworkRequest.new(net.protocol.CGDeleteReadMailsREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	game.util.RequestHelper.request(request);
end

-- 删除所有已读邮件返回
function NoticeMailService:_onGCDeleteReadMailsRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_DELETE_READ_MAILS_SUCCESS then
		--为了方便直接请求一次新的数据
		self:onCGQueryMailREQ()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 邮件回执返回，这里可以是，删除，也可以发送已读
function NoticeMailService:_onGCChangeMailRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_CHANGE_MAIL_SUCCESS then
		-- 成功删除相关邮件，然后通知界面删除
		local reqProto = response:getRequest():getProtocol():getProtocolBuf()
		-- 只处理发送删除的邮件时间,因为已读直接本地标记的
		local index = self:findMailIndexById(reqProto.id)
		
		if reqProto.operate == net.protocol.MailStatus.READ then
			self._mailData[index].status = net.protocol.MailStatus.READ
		else
			table.remove(self._mailData, index)
			self:dispatchEvent({name = "EVENT_MAIL_DELETE", index = index, count = #self._mailData})
		end
		
		self:checkClearMailRed()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

function NoticeMailService:isMailDotShow()
	return table.indexof(game.service.LocalPlayerService:getInstance():getDotArray(), net.protocol.NMDotType.MAIL) ~= false
end

function NoticeMailService:isActivityDotShow()
	return table.indexof(game.service.LocalPlayerService:getInstance():getDotArray(), net.protocol.NMDotType.ACTIVITY) ~= false
end

-- 请求接收邮件附件
function NoticeMailService:queryReceiveItem(id)
	local request = net.NetworkRequest.new(net.protocol.CGReceiveItemREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request:getProtocol():setData(id)
	game.util.RequestHelper.request(request);
end

function NoticeMailService:onGCReceiveItemRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local reqProto = response:getRequest():getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_RECEIVE_ITEM_SUCCESS then
		local index = self:findMailIndexById(reqProto.id)
		self._mailData[index].status = net.protocol.MailStatus.RECEIVED
		self:dispatchEvent({name = "EVENT_MAIL_REWARD_RECEIVED", data = self._mailData[index], index = index})
		self:checkClearMailRed()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

--------------------------------------------------------------------------------------------
--设置活动页面的数据
function NoticeMailService:setActivities(activities)
	self._activities = activities
	table.sort(self._activities, function(a, b)
		if a.level == b.level then
			return a.sendTime < b.sendTime
		end
		return a.level > b.level
	end)
end
--获得活动页面的数据
function NoticeMailService:getActivities()

	local time = game.service.TimeService:getInstance():getCurrentTime()
	local activities = clone(self._activities)
	table.arrayFilter(activities, function(v)
		return v.startTime / 1000 < time and v.endTime / 1000 > time
	end)
	return activities
end

function NoticeMailService:CGQueryActivityREQ(type)
	local request = net.NetworkRequest.new(net.protocol.CGQueryActivityREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request.type = type
	game.util.RequestHelper.request(request)
end

-- 活动列表返回
function NoticeMailService:_onGCQueryActivityRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local type = response:getRequest().type
	if protocol.result == net.ProtocolCode.GC_QUERY_ACTIVITY_SUCCESS then
		self:setActivities(protocol.activities)
		self._activityShowTime = protocol.times
		
		if type == "login" then
			self:dispatchEvent({name = "EVENT_ACTIVITY_LIST_FIRST_GET"})
		else
			if #self._activities > 0 then
				UIManager.getInstance():show("UIActivityList")
			else
				game.ui.UIMessageTipsMgr.getInstance():showTips("活动准备中,敬请期待");
			end
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

function NoticeMailService:queryReadActivity(id)
	local request = net.NetworkRequest.new(net.protocol.CGReadActivityREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request:getProtocol():setData(id)
	game.util.RequestHelper.request(request);
end

function NoticeMailService:showActives()
	
	local activities = self:getActivities()
	
	if #activities > 0 and storageTools.AutoShowStorage.isNeedShow("UIActivityList", self._activityShowTime) then
		UIManager:getInstance():show("UIActivityList")
	end
end

-- 举报
function NoticeMailService:sendCGAccusePlayerREQ(mailAddress, content)
	local request = net.NetworkRequest.new(net.protocol.CGAccusePlayerREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request:getProtocol():setData(mailAddress, content)
	game.util.RequestHelper.request(request)
end

function NoticeMailService:_onGCAccusePlayerRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.GC_ACCUSE_PLAYER_SUCCESS then
		game.ui.UIMessageTipsMgr.getInstance():showTips("举报已提交")
		UIManager:getInstance():destroy("UIReportMain")
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end


return NoticeMailService 