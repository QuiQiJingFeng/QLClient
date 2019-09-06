local csbPath = "ui/csb/UIActivity.csb"
local super = require("app.game.ui.UIBase")
local FILE_TYPE = "playericon"
local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst

local UIActivityList = class("UIActivityList", super, function() return kod.LoadCSBNode(csbPath) end)

function UIActivityList:ctor()
	self._listActivity = nil -- 活动公告列表
	self._btnClose = nil -- 返回
	self._imgActivity = nil -- 活动图片
	
	self.loadFlag = false
	self._data = nil
end

function UIActivityList:init()
	self._btnClose = seekNodeByName(self, "Button_x_Activity", "ccui.Button")
	self._imgActivity = seekNodeByName(self, "Panel_4", "ccui.Layout")
	self._textActivity = seekNodeByName(self, "Text_content_Activity", "ccui.Text")
	self._imgNone = seekNodeByName(self, "Text_No", "ccui.Text")
	
	self._listActivity = seekNodeByName(self, "ListView_Activity_Type_Btn", "ccui.ListView")
	-- 不显示滚动条
	self._listActivity:setScrollBarEnabled(false)
	
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listActivity, "GAME_TYPE_BUTTON")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)
	
	bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIActivityList:onShow(...)
	local data = game.service.NoticeMailService.getInstance():getActivities()
	self._data = data
	self:_initActivityList(data)
	-- 默认显示第一活动
	if data[1] ~= nil then
		self:_onItemTypeClicked(data[1])
		data[1].status = net.protocol.MailStatus.READ
		local redPoint = ccui.Helper:seekNodeByName(self._btnCheckList[data[1].id], "Image_red_Setting")
		redPoint:setVisible(false)
	end
	self._imgNone:setVisible(data[1] == nil)

	self:playAnimation_Scale()
end

function UIActivityList:_onBtnClose()
	UIManager:getInstance():destroy("UIActivityList")
end

function UIActivityList:onHide()
	self._listActivity:removeAllChildren()
	self._btnCheckList = {}
end

-- 活动列表初始化
function UIActivityList:_initActivityList(param)
	-- 清空一下列表
	self._btnCheckList = {}
	self._listActivity:removeAllChildren()
	
	-- 根据活动配置初始化活动公告列表
	for k, v in pairs(param) do
		local node = self._listviewItemBig:clone()
		self._listActivity:addChild(node)
		node:setVisible(true)
		
		-- 设置item文字显示
		local textType = ccui.Helper:seekNodeByName(node, "Text_tital_Mail_0")
		local redPoint = ccui.Helper:seekNodeByName(node, "Image_red_Setting")
		textType:setString(kod.util.String.getMaxLenString(v.title, 10))
		redPoint:setVisible(v.status == net.protocol.MailStatus.UNREAD)
		
		-- 设置item的状态 
		local isSelected = false
		node:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.began then
				isSelected = node:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
			elseif eventType == ccui.TouchEventType.ended then	
				self:_onItemTypeClicked(v)
				redPoint:setVisible(false)
				node:setSelected(true)
			elseif eventType == ccui.TouchEventType.canceled then
				node:setSelected(isSelected)
			end
		end)
		self._btnCheckList[v.id] = node
	end
	
end

function UIActivityList:_onItemTypeClicked(item)
	-- 按钮的显示与隐藏
	for k, v in pairs(self._btnCheckList) do
		if k == item.id then
			v:setSelected(true)
		else
			v:setSelected(false)
		end
	end
	
	if item.status == net.protocol.MailStatus.UNREAD then
		game.service.NoticeMailService:getInstance():queryReadActivity(item.id)
	end
	
	-- 控制大厅红点显示
	local lobbyRedPoint = false
	for k, v in pairs(self._data) do
		if v.id == item.id then
			v.status = net.protocol.MailStatus.READ
		end
		if v.status == net.protocol.MailStatus.UNREAD then
			lobbyRedPoint = true
		end
	end
	
	if lobbyRedPoint == false then
		game.service.NoticeMailService:getInstance():onRedDotChanged(net.protocol.NMDotType.ACTIVITY)
	end

	bindEventCallBack(self._imgActivity, function()
		local ok = config.H5GameConfig:openH5GameByName(item.title, "Activity")
		if ok then
			-- 额外的去做数据打点
			if item.title == "传奇来了" then
				self:_setDataEye("chuanqi")
			elseif item.title == "大圣觉醒" then
			elseif item.title == "魔域来了" then
			end
		else
			self:defaultFunction(item)
		end
	end, ccui.TouchEventType.ended)

	self.loadFlag = false
	
	self._imgActivity:setBackGroundImage("art/function/img_none.png")
	-- 替换对应的图片
	manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, item.pictureUrl, function(tf, fileType, fileName)
		-- 获取成功之后设置图片	
		if self._imgActivity == nil then
			return
		end
		if tf then			
			local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
			self._imgActivity:setBackGroundImage(filePath)
			self.loadFlag = true
		else
			if self.loadFlag == false then
				self._imgActivity:setBackGroundImage("art/function/z_tpjzsb.png")
			end
		end
	end);	
end


-- 图片默认点击调用函数
function UIActivityList:defaultFunction(item)
	self:_setDataEye(item)
	uiSkip.UISkipTool.skipTo(item.skipTarget)
end

function UIActivityList:needBlackMask()
	return true
end

function UIActivityList:closeWhenClickMask()
	return false
end

function UIActivityList:_setDataEye(item)
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	-- 判断ID尾数奇偶
	if roleId % 2 == 0 then
		game.service.DataEyeService.getInstance():onEvent(string.format("Button_LegendActivityPage_double_%s", item.skipTarget))
	else
		game.service.DataEyeService.getInstance():onEvent(string.format("Button_LegendActivityPage_single_%s", item.skipTarget))
    end
    if item.title then
        game.service.DataEyeService.getInstance():onEvent("Activity_Click_" .. item.title)
    end
end

return UIActivityList 