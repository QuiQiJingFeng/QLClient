local csbPath = "ui/csb/Club/UIClubLeaderboardTime.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardTime = class("UIClubLeaderboardTime", super, function () return kod.LoadCSBNode(csbPath) end)

local SelectDays 	= {}
local SelectEndDays	= {}
local TurnSelects = {SelectDays, SelectEndDays}
local DAY_TIME_IN_MSECONDS = 24 * 60 * 60 * 1000

---------------
-- UIElemListItem
local UIElemListItem = class("UIElemListItem")

function UIElemListItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemListItem)
    self:_initialize()
    return self
end

function UIElemListItem:_initialize()
    self._text = seekNodeByName(self, "BitmapFontLabel_cell_item", "ccui.TextBMFont")     -- 
end

function UIElemListItem:getData()
    return self._data
end

-- 整体设置数据
function UIElemListItem:setData(info)
    self._data = info

    if info ~= "--" then
		if info >= 24 then
			local formatTime = kod.util.Time.time2Date(info/1000);
			info = formatTime.month .. "月" .. formatTime.day .. "日"
		else
			info = info .. "时"
		end
    end

    self._text:setString(info)
end

-----------------------------
-- UIClubLeaderboardTime
function UIClubLeaderboardTime:ctor()
	self._nodesObj 		= {};		-- 存放所有节点
	self._listViews 	= {};		-- 滚轮控件
	self._callback 		= nil		-- 设置数据的回调
end


function UIClubLeaderboardTime:needBlackMask()
	return true;
end

function UIClubLeaderboardTime:init()
	local root 	  = seekNodeByName(self,	"Panel_bg_SearchTime2", "ccui.Layout");
	self._nodesObj = bindNodeToTarget(root);
	
	-- 初始化List
	self._listViews = {};
	local item = self._nodesObj.Panel_item_1;
	item:retain();
	for i = 1, 4 do
		-- UIItemReusedListView 需要在listview里有一个item，所以添加一个
		local l = self._nodesObj["ListView_"..i];
		local newItem = item:clone();
		l:addChild(newItem);
		-- 创建UIItemReusedListView
		local list = UIItemReusedListView.extend(seekNodeByName(self, "ListView_"..i, "ccui.ListView"), UIElemListItem)
    	list:setScrollBarEnabled(false)
		table.insert( self._listViews, list);
	end
	self._nodesObj.Panel_item_1:setVisible(false);
	item:release()

	self:_registerCallBack()
end

-- 刷新列表
function UIClubLeaderboardTime:_refresh(listId, startTime, endTime)
    local list = self._listViews[listId]
    list:deleteAllItems()

    TurnSelects[listId] = {}
    table.insert(TurnSelects[listId], "--")
	list:pushBackItem("--")
	if listId == 2 or listId == 4 then
		while startTime <= endTime do
			table.insert(TurnSelects[listId], startTime)
			list:pushBackItem(startTime)
			startTime = startTime + 1
		end
	else
		while endTime >= startTime do
			table.insert(TurnSelects[listId], endTime)
			list:pushBackItem(endTime)
			endTime = endTime - DAY_TIME_IN_MSECONDS
		end
	end
    
    table.insert(TurnSelects[listId], "--")
    list:pushBackItem("--")
end

-- 点击事件注册
function UIClubLeaderboardTime:_registerCallBack()
	bindEventCallBack(self._nodesObj.Button_Cancel, 	handler(self, self._onClickCancel),	ccui.TouchEventType.ended);
	bindEventCallBack(self._nodesObj.Button_ok, 		handler(self, self._onClickOk),		ccui.TouchEventType.ended);
	for i,v in ipairs(self._listViews) do
		-- listview绑定弹回回调
		v:addScrollViewEventListener(handler(self,self._onScrollEnd));
	end
end

function UIClubLeaderboardTime:onShow(startTime, endTime, callback)
    self:_refresh(1, startTime, endTime)
    self:_refresh(3, startTime, endTime)
	self:_refresh(2, 0, 23)
	self:_refresh(4, 0, 23)
	self._callback = callback -- 点击查询时的回调
	self:_fixInitPos(self._listViews[1])
	self:_fixInitPos(self._listViews[2])
	self:_fixInitPos(self._listViews[3])
	self:_fixInitPos(self._listViews[4])

	self:_initTime()
end

-- 初始化默认时间
function UIClubLeaderboardTime:_initTime()
	local startTime = math.floor(game.service.TimeService:getInstance():getCurrentTime())
	local minute = tonumber(os.date("%M", startTime))
	startTime = startTime + (minute > 0 and 60 * 60 or 0)
	local hour = tonumber(os.date("%H", startTime))
	local percent = hour / 23 * 100 + 2
	self._listViews[4]:jumpToPercentVertical(percent)
end

function UIClubLeaderboardTime:destroy()
	for i, v in ipairs(self._listViews) do
		-- destroy的时候销毁所有的items
		v:deleteAllItems();
	end
end

-- 位置校准功能实现
function UIClubLeaderboardTime:_onScrollEnd(list,eventType)
	if eventType == 10 then --"AUTOSCROLL_ENDED"
		-- get center item
		local item = self:_getCenterItem(list)

		local pos  = cc.p(item:getPosition());
		-- computer distance between center item and center image
		local centerImg = seekNodeByName(self, "Image_2", "ccui.ImageView")
		local centerImgWorldPos = centerImg:getParent():convertToWorldSpace(cc.p(centerImg:getPosition()))
		local centerImgLocalPosInList = item:getParent():convertToNodeSpace(centerImgWorldPos)
		local diffY = centerImgLocalPosInList.y - pos.y
		-- move back
		local layout = list:getInnerContainer();
		layout:runAction(cc.MoveBy:create(0.2,cc.p(0, diffY)));
    end
end

function UIClubLeaderboardTime:_onClickCancel(sender)
	UIManager:getInstance():hide("UIClubLeaderboardTime");
end

-- 确认
function UIClubLeaderboardTime:_onClickOk()
	-- 统计点击查询按钮的人次
	game.service.DataEyeService.getInstance():onEvent("Tquery")

	local startTime = self:_getSelectedTime(1);
	local endTime = self:_getSelectedTime(3);
	local startTime1 = self:_getSelectedTime(2);
	local endTime2 = self:_getSelectedTime(4);
    
    if startTime > endTime then
        game.ui.UIMessageTipsMgr.getInstance():showTips("起始时间需早于终止时间")
		return
    end
	if startTime == endTime then
		if startTime1 >= endTime2 then
			game.ui.UIMessageTipsMgr.getInstance():showTips("起始时间需早于终止时间")
			return
		end
	end
	
	startTime = self:_castTimeToStamp(startTime / 1000, startTime1) * 1000
	endTime = self:_castTimeToStamp(endTime / 1000, endTime2) * 1000
	if self._callback ~= nil then
		self._callback(startTime, endTime)
	end
    
    UIManager:getInstance():hide("UIClubLeaderboardTime");
end

function UIClubLeaderboardTime:_castTimeToStamp(time, hour)
	local formatT = kod.util.Time.time2Date(time)
	local stamp = time + (hour - formatT.hour) * 60 * 60 - formatT.min * 60;
	return stamp;
end

-- 获取当前选择的时间戳
function UIClubLeaderboardTime:_getSelectedTime(listId)
	local item = self:_getCenterItem(self._listViews[listId])
    return item:getData()
end

function UIClubLeaderboardTime:needBlackMask()
	return true
end

function UIClubLeaderboardTime:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubLeaderboardTime:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

-- 获取当前选择的item
function UIClubLeaderboardTime:_getCenterItem(list)
	-- get center item
	local items  = list:getItems();
	local item = list:getCenterItemInCurrentView();
	local idx  = table.indexof(items,item);
	if idx == 1 and item._data == "--" then
		item = items[idx+1]
	elseif idx == list._spawnCount and item._data == "--" then
		item = items[idx-1]
	end

	return item
end

-- 修正初始位置
function UIClubLeaderboardTime:_fixInitPos(list)
	local item = self:_getCenterItem(list)
	local pos  = cc.p(item:getPosition());
	-- computer distance between center item and center image
	local centerImg = seekNodeByName(self, "Image_2", "ccui.ImageView")
	local centerImgWorldPos = centerImg:getParent():convertToWorldSpace(cc.p(centerImg:getPosition()))
	local centerImgLocalPosInList = item:getParent():convertToNodeSpace(centerImgWorldPos)
	local diffY = centerImgLocalPosInList.y - pos.y
	-- move back
	local layout = list:getInnerContainer();
	local layoutPos = cc.p(layout:getPosition())
	layoutPos.y = layoutPos.y + diffY
	layout:setPosition(layoutPos)
end

return UIClubLeaderboardTime