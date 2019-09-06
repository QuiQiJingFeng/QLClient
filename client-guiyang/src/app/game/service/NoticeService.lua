local ns = namespace("game.service")
local UIElemNotice = import("..ui.element.UIElemNotice")
local FILE_TYPE = "playericon"

local NoticeData = class("NoticeData")
function NoticeData:ctor()
	self.id = 0;
	self.imgUrl = ""; 			-- 图片地址
	self.noticeName = "";		-- 公告标题
	self.content = ""; 			-- 文字说明
	self.startTime = 0;			-- 公告开始时间
	self.endTime = 0;			-- 公告结束时间
	self.showTimes = 0; 		-- 每天弹出次数
	self.displayedTimes = { date = "", count = 0 }; 	-- 当天已经显示的次数
	self._showData = nil
	self._elemData =  nil
	self.title = nil
	self.pageImg = ""
	self.pagestartTime = 0;
	self.pageendTime = 0;
	self.loadFlag = false
end

local NoticeDatas = class("NoticeDatas")
function NoticeDatas:ctor()
	self.version = 0; 	-- 公告消息版本号
	self._datas = {}	-- 公告数据
	self._pagedatas = {}   --大厅公告栏数据
end

local NoticeService = class("NoticeService")
ns.NoticeService = NoticeService

-- 单例
function NoticeService.getInstance()
	if game.service.LocalPlayerService.getInstance() == nil then
		return nil
	end
	return game.service.LocalPlayerService.getInstance():getNoticeService();
end

function NoticeService:ctor()
	self:clear()
end

function NoticeService:clear()
	self._noticeDatas = {} 			-- NoticeDatas[]
	-- 缓存常驻公告
	self._mainNoticeResident = { content = "", title = "" }
	self._limitTime = { startTime = 0, endTime = 0 }
	self._mainNoticeHealth = { content = "", title = "" }
end

function NoticeService:initialize()
	-- 监听网络
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCNoticeVersionSYN.OP_CODE, self, self._onGCNoticeVersionSYN)
	requestManager:registerResponseHandler(net.protocol.GCNoticeRES.OP_CODE, self, self._onGCNoticeRES);
	requestManager:registerResponseHandler(net.protocol.GCMainNoticeRES.OP_CODE, self, self._onGCMainNoticeRES)
	--大厅常驻公告栏回复
    requestManager:registerResponseHandler(net.protocol.GCQueryHomePageNoticeRES.OP_CODE, self, self._onGCQueryHomePageNoticeRES);
end

function NoticeService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	self._noticeDatas = nil
end

-- 加载本地存储
function NoticeService:loadLocalStorage()
	self._noticeDatas = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "Notice", NoticeDatas);
end

-- 存储到本地缓存
function NoticeService:saveLocalStorage()
	manager.LocalStorage.setUserData(game.service.LocalPlayerService:getInstance():getRoleId(),"Notice", self._noticeDatas);
end

-- 收到服务器推送公告改变
function NoticeService:_onGCNoticeVersionSYN(response)
	Logger.dump(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- 收到服务器下发的新版本号, 如果与本地缓存的不一致, 重新请求数据
	if protocol.version ~= self._noticeDatas.version then
		self:_queryNotice(true);
	end
end

-- 向服务器请求新的公告信息
function NoticeService:_queryNotice(isChange)
	local request = net.NetworkRequest.new(net.protocol.CGNoticeREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
	request:getProtocol():setData(self._noticeDatas.version)
	request.isChange = isChange
	game.util.RequestHelper.request(request);
end

function NoticeService:queryMainPageNotice()
	local request = net.NetworkRequest.new(net.protocol.CGMainNoticeREQ,
	game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end
function NoticeService:queryPageNotice()

	self:_showPages()	--为了避免切回主界面图片闪的效果，先将缓存图片加载，理论上这一步不需要

	local request = net.NetworkRequest.new(net.protocol.CGQueryHomePageNoticeREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(game.service.LocalPlayerService:getInstance():getArea())
	game.util.RequestHelper.request(request)

end
function NoticeService:_onGCNoticeRES(response)
	local protocolBuf = response:getProtocol():getProtocolBuf()
	local request = response:getRequest()
	if protocolBuf.result == net.ProtocolCode.GC_NOTICE_SUCCESS then
		-- 保存数据
		
		if game.service.LocalPlayerService:getInstance():getArea() == 0 then 
			return
		end

		if protocolBuf.version == self._noticeDatas.version then
		else
			self._noticeDatas.version = protocolBuf.version;	
			self._noticeDatas._datas = {}

			for i = 1,#protocolBuf.notices do
				local element = protocolBuf.notices[i]
                local noticeData = NoticeData.new();
				noticeData.id = element.id;
				noticeData.content = element.content;
				noticeData.imgUrl = element.imgUrl;
				noticeData.startTime = element.startTime;
				noticeData.endTime = element.endTime;
				noticeData.showTimes = element.showTimes;
				noticeData.noticeName = element.noticeName;
				table.insert(self._noticeDatas._datas, noticeData)
			end
		end

		-- 保存本地数据
		self:saveLocalStorage();

		-- 公告版本号变化或者时间超过两个小时就在显示公告
		if request.isChange or self:isNoticePop(false) then
			self:_startToShowNotice()
		end

	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocoprotocolBuf.result));
	end
end

-- 大厅常驻公告栏返回
function  NoticeService:_onGCQueryHomePageNoticeRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result  ==  net.ProtocolCode.GC_QUERY_HOME_PAGE_NOTICE_SUCCESS then
	    if #protocol.notices ~= 0 then
	    	self._noticeDatas._pagedatas = {} 
          	for i = 1,#protocol.notices do
				local element = protocol.notices[i]
                local noticeData = NoticeData.new();
				noticeData.title = element.title;
				noticeData.pageImg = element.content;
				noticeData.pagestartTime = element.startTime;
				noticeData.pageendTime = element.endTime;
				noticeData.priority = element.priority;
				noticeData.jumpType = element.jumpType;
				table.insert(self._noticeDatas._pagedatas, noticeData)
			end
			self:_getPageNoitce()
	    end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end 
end

function NoticeService:_onGCMainNoticeRES(response)
	local protocolBuf = response:getProtocol():getProtocolBuf()
	if protocolBuf.result == net.ProtocolCode.GC_MAIN_NOTICE_SUCCESS then
		local notices = protocolBuf.notices
		for i = 1, #notices do
			if notices[i].type == "health" then
				self._mainNoticeHealth.content = notices[i].content
				self._mainNoticeHealth.title= notices[i].title
			elseif notices[i].type == "resident" then
				self._mainNoticeResident.content = notices[i].content
				self._mainNoticeResident.title= notices[i].title
				self._limitTime.startTime = notices[i].startTime
				self._limitTime.endTime= notices[i].endTime
			end

			if  UIManager:getInstance():getIsShowing("UIMain") then
				UIManager:getInstance():getUI("UIMain"):changeMainNotice()
			end
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocoprotocolBuf.result));
	end
end

-- 启动公告信息显示
function NoticeService:_startToShowNotice()
	-- 如果不是大厅则不显示公告
	if UIManager:getInstance():getIsShowing("UIMain") == false then
		return
	end
	self._showData = self:_getShowNoitce()
	-- id 大的数据先显示
	table.sort(self._showData, function(l, r) return l.id > r.id end)

	-- 如果弹窗公告图片没下载完不显示弹窗
	if  self:_loadImage() == false then
		self:_showNotice()
	end
end

function NoticeService:_showPageNotice()
    local uimain = UIManager:getInstance():getUI("UIMain")
	if uimain then
		local function getHandler(data)
			if data == nil then
				return
			end
			return function ()
				local ok = config.H5GameConfig:openH5GameByName(data.title, "Notice")
				if not ok then
					self:_onJumpClick(data)
				end
			end
		end
		uimain._elemNotice:load(UIElemNotice.NOTICE_CONFS.fromProtocol(self._elemData),{
			getHandler(self._elemData[1]),
			getHandler(self._elemData[2]),
			getHandler(self._elemData[3])
		})
	end
end

function NoticeService:_onJumpClick(showNotice)
	local  functionConfig  = {
		[0] =  function() self:defaultFunction() end,
		[1] =  function() self:gotoClub()        end,
		[2] =  function() self:gotoCampaign(1)    end,
        [3] =  function() self:gotoCreateRoom()  end,
        [4] =  function() self:gotoGold()        end,
        [5] =  function() self:gotoMainNotice()  end,
		[6] =  function() self:gotoCampaign(1)  end,
		[7] =  function() self:gotoCampaign(2)  end,
		[8] =  function() self:gotoCampaign(3)  end,
	}
	functionConfig[showNotice.jumpType]()
end



function NoticeService:gotoClub()
	game.service.club.ClubService.getInstance():enterClub()
end

function NoticeService:gotoCampaign(tabId)
    if GameMain.getInstance():isReviewVersion() or game.service.CampaignService.getInstance():getId() == 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
	else
		-- 统计点击比赛场按钮进入比赛的事件数
    	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Entrance);

		game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST, tabId)
	end
end

-- 图片默认点击调用函数
function NoticeService:defaultFunction()
    -- body
end

function NoticeService:gotoCreateRoom()
    UIManager:getInstance():show("UICreateRoom")
end

function NoticeService:gotoGold()
    GameFSM.getInstance():enterState("GameState_Gold")
end

function NoticeService:gotoMainNotice()
    UIManager:getInstance():show("UIMessageMain", 0)
end


-- 获取需要显示的公告
-- return NoticeData[]
function NoticeService:_getPageNoitce()
	local showDatas = {}
	local count = #self._noticeDatas._pagedatas;
    for  i = 1, #self._noticeDatas._pagedatas  do
           local startTime =  self._noticeDatas._pagedatas[i].pagestartTime
           local endTime   =  self._noticeDatas._pagedatas[i].pageendTime
           local nowTime   = kod.util.Time.now();
           local isAble    = nowTime >=  startTime  and  nowTime <= endTime

           --删除过期的公告
           	if  self._noticeDatas._pagedatas[i].pageendTime  < nowTime  then 
            	self._noticeDatas._pagedatas[i] = nil
		   	end
	  
          	if  isAble then  
              if  #self._noticeDatas._pagedatas == 2 or #self._noticeDatas._pagedatas > 3  then
              table.sort(self._noticeDatas._pagedatas, function(l, r) return l.priority > r.priority end)
                if  #self._noticeDatas._pagedatas > 3  then
                    if self._noticeDatas._pagedatas[i].priority < self._noticeDatas._pagedatas[3].priority  then 
                    	table.remove(self._noticeDatas._pagedatas,self._noticeDatas._pagedatas[i])
                    end
              		if self._noticeDatas._pagedatas[i].priority > self._noticeDatas._pagedatas[3].priority  then 
              		table.remove(self._noticeDatas._pagedatas, self._noticeDatas._pagedatas[3])
              	end

         if  self._noticeDatas._pagedatas[i].priority == self._noticeDatas._pagedatas[3].priority  then 
                if self._noticeDatas._pagedatas[i].startTime < self._noticeDatas._pagedatas[3].startTime  then 
                table.remove(self._noticeDatas._pagedatas,self._noticeDatas._pagedatas[3])
                else
                table.remove(self._noticeDatas._pagedatas,self._noticeDatas._pagedatas[i])
                 end
             end
          end
        end
      end
   end

	showDatas = self._noticeDatas._pagedatas
	table.sort(showDatas, function(l, r) return l.priority > r.priority end)

	self._elemData = clone(showDatas);
         
	self:_showPages()
end

function NoticeService:_showPages()
	if not self._elemData or #self._elemData <= 0 then
		return
	end
	
	local count = #self._elemData
	local index = 0
	
	for   i = 1, #self._elemData  do
     	-- local fileExist = manager.RemoteFileManager.getInstance():doesFileExist(FILE_TYPE, self._elemData[i].pageImg) 
     	local fileExist = cc.FileUtils:getInstance():isFileExist(self._elemData[i].pageImg) 
     	if fileExist == false then
        	manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, self._elemData[i].pageImg, function(tf, fileType, fileName)
		        if tf then
			        local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
				    self._elemData[i].pageImg = filePath
					index = index +1
					if index == count then 
	                   self:_showPageNotice()
	                   self.loadFlag =true
					end
				else
				    self.loadFlag = false
                    local uimain = UIManager:getInstance():getUI("UIMain")
                    if uimain then 
					    --如果GMT配置的图片下载失败，就调用本地公告配置，显示默认图片
                  	    uimain._elemNotice:load(UIElemNotice.NOTICE_CONFS.fromConfig(),{function() 	end,})
			      	end
	            end
	      	end)
	    else	      		
			index = index +1
			if index == count then 
               self:_showPageNotice()
			end
	    end
	end

end

-- 弹窗公告图片有没下载的，先进行下载，客户端不显示
function NoticeService:_loadImage()
	local isDownload = false
	if #self._showData > 0 then	
		for _, data in ipairs(self._showData) do
			if data.imgUrl ~= nil and data.imgUrl ~= "" then
				-- 获取本地缓存
				local filePath = manager.RemoteFileManager.getInstance():doesFileExist(FILE_TYPE, data.imgUrl)
				if filePath == false then
					isDownload = true
					manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, data.imgUrl, function(tf, fileType, fileName) end);
				end
			end
		end
	end

	return isDownload
end

-- 更新弹窗次数
function NoticeService:_updateDisplayedCount()
	local time = kod.util.Time.now()
	local date = os.date("*t", time)
	local dateKey = date.month .. "," .. date.day;

	for i = 1, #self._showData do
		local data = self._showData[i]
		if data.displayedTimes == nil or data.displayedTimes.date ~= dateKey then
			data.displayedTimes.date = dateKey
			data.displayedTimes.count = 1
		else
			data.displayedTimes.count = data.displayedTimes.count + 1
		end
	end

	self:saveLocalStorage()
end

-- 显示弹窗公告
function NoticeService:_showNotice()
	if #self._showData > 0 then	
		local data = self._showData[1];
		table.remove(self._showData, 1)
		if data.imgUrl ~= nil and data.imgUrl ~= "" then		
			local filePath = manager.RemoteFileManager.getInstance():getFilePath(FILE_TYPE, data.imgUrl)			
			UIManager:getInstance():show("UINotice", true, filePath)
		else
			-- 显示文本公告
			UIManager:getInstance():show("UINotice", false, data)
		end
		-- 更新弹窗次数
		self:_updateDisplayedCount()
		-- 保存当前弹窗的时间
		self:isNoticePop(true)
	end
end

function NoticeService:getMainNotice()
	local time = kod.util.Time.now()
	if self._limitTime ~= nil then
		if time > self._limitTime.startTime and time < self._limitTime.endTime then
			return self._mainNoticeResident
		end
	end

	return self._mainNoticeHealth
end

-- 获取需要显示的公告
-- return NoticeData[]
function NoticeService:_getShowNoitce()
	local time = kod.util.Time.now()
	local date = os.date("*t", time)
	local dateKey = date.month .. "," .. date.day;
	local showDatas = {}
	local count = #self._noticeDatas._datas;
	time = time * 1000
	
	for i=1, count do
		local data = self._noticeDatas._datas[i];
		if data.endTime < time then
			-- 删除过期条目
			self._noticeDatas._datas[i] = nil
		-- 不处理没开始的公告
		elseif data.startTime < time then
			-- 将符合的公告加入列表
			if data.displayedTimes == nil or data.displayedTimes.date ~= dateKey or data.displayedTimes.count < data.showTimes then
				table.insert(showDatas, data)
			end
		end
	end

	local j = 1
	for i = 1, count do
		if self._noticeDatas._datas[i] ~= nil then
			self._noticeDatas._datas[j] = self._noticeDatas._datas[i]
			j = j + 1
		end
	end

	for i = j, count do
		self._noticeDatas._datas[i] = nil
	end

	-- 更新本地存储
	if count ~= #self._noticeDatas._datas then
		self:saveLocalStorage();
	end

	return showDatas;
end

-- 判断是否满足弹窗时间条件
function NoticeService:isNoticePop(isSave)
	local noticeTime = self:_loadLocalNoticeTime()
	local newTime = game.service.TimeService:getInstance():getCurrentTime()
	-- 当超过两个小时在弹窗
	if newTime - noticeTime:getTime() > 7200 then
		if isSave then
			noticeTime:setTime(newTime)
			self:_saveLocalNoticeTime(noticeTime)
		end
		return true
	end

	return false
end

-- 缓存上次弹窗的时间
local LocalNoticeTime = class("LocalNoticeTime")
function LocalNoticeTime:ctor()
	self._time = 0
end

function LocalNoticeTime:getTime()
	return self._time
end

function LocalNoticeTime:setTime(time)
	self._time = time
end

function NoticeService:_loadLocalNoticeTime()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	return manager.LocalStorage.getUserData(roleId, "LocalNoticeTime", LocalNoticeTime)
end

function NoticeService:_saveLocalNoticeTime(localNoticeTime)
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
	manager.LocalStorage.setUserData(roleId, "LocalNoticeTime", localNoticeTime)
end