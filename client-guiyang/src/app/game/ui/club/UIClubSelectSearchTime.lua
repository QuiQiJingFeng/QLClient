----------------------
-- 亲友圈设置查询账单的起止时间
----------------------
local csbPath = "ui/csb/Club/UIClubSelectSearchTime.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local super = require("app.game.ui.UIBase")
local UIClubSelectSearchTime = class("UIClubSelectSearchTime", super, function () return kod.LoadCSBNode(csbPath) end)

---------------
-- 构造时间数据

-- 天
local SelectDays 	= {"--", "前天", "昨天", "今天", "--"}
local SelectEndDays	= {"--", "前天", "昨天", "今天", "当前","--"}

-- 小时
local SelectHours 	= {"--"};
for i = 0, 23 do
	local s = "0"..i;
	s = string.sub(s,string.len(s) - 1,-1);
	table.insert(SelectHours,s)
end
table.insert(SelectHours,"--")

-- 分钟
local SelectMinutes = {"--"};
for i = 0, 59 do
	local s = "0"..i;
	s = string.sub(s,string.len(s) - 1, -1);
	table.insert(SelectMinutes,s)
end
table.insert( SelectMinutes,"--")

local TurnSelects = {SelectDays,SelectHours,SelectMinutes,SelectEndDays,SelectHours,SelectMinutes};

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

	-- 设置时间
    self._text:setString(self._data)
end

-- 时间滚动list，每一列的元素数
local ScrolViewsNum = {3,24,60,4,24,60};

-----------------------------
-- UIClubSelectSearchTime
function UIClubSelectSearchTime:ctor()
	self._clubId		= nil;		-- 亲友圈id
	self._nodesObj 		= {};		-- 存放所有节点
	self._oldStartTime 	= 0;		-- 上次查询开始时间
	self._oldEndTime   	= 0;		-- 上次查询结束时间
	self._newStartTime  = 0;		-- 当前设定的开始时间
	self._newEndTime   	= 0;		-- 当前设定的结束时间

	self._listViews 	= {};		-- 6个滚轮控件

	self._callback 		= nil		-- 设置数据的回调
end


function UIClubSelectSearchTime:needBlackMask()
	return true;
end

function UIClubSelectSearchTime:init()
	local root 	  = seekNodeByName(self,	"Panel_bg_DZDZX", "ccui.Layout");
	self._nodesObj = bindNodeToTarget(root);
	
	-- 初始化List
	self._listViews = {};
	local item = self._nodesObj.Panel_item_1;
	item:retain();
	for i = 1,6 do
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
	item:release();

	for i,v in ipairs(TurnSelects) do
		local list = self._listViews[i]
		list:deleteAllItems()
		-- 把items添加到UIItemReusedListView
		for j, v2 in ipairs(v) do
			list:pushBackItem(v2)
		end
	end	

	self:_registerCallBack()
end


-- 点击事件注册
function UIClubSelectSearchTime:_registerCallBack()
	bindEventCallBack(self._nodesObj.Button_Cancel, 	handler(self, self._onClickCancel),	ccui.TouchEventType.ended);
	bindEventCallBack(self._nodesObj.Button_ok, 		handler(self, self._onClickOk),		ccui.TouchEventType.ended);
	for i,v in ipairs(self._listViews) do
		-- listview绑定弹回回调
		v:addScrollViewEventListener(handler(self,self._onScrollEnd));
	end
end

function UIClubSelectSearchTime:onShow(clubId, callback)
	self._clubId = clubId;
	self._callback = callback -- 点击查询时的回调
end

function UIClubSelectSearchTime:destroy()
	for i, v in ipairs(self._listViews) do
		-- destroy的时候销毁所有的items
		v:deleteAllItems();
	end
end

-- 位置校准功能实现
function UIClubSelectSearchTime:_onScrollEnd(list,eventType)
	if eventType == 10 then --"AUTOSCROLL_ENDED"
		local items  = list:getItems();
		local item = list:getCenterItemInCurrentView();
		local idx  = table.indexof(items,item);
		local pos  = cc.p(item:getPosition());
		local layout = list:getInnerContainer();
		local p = cc.p(layout:getPosition());
		local dy = p.y%75;
		if dy > 75/2 then
			dy = dy - 75;
		end
		layout:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0, -dy))));
	elseif eventType == 9 or eventType == 4 then	-- CONTAINER_MOVED
    end
end

-- 获取当前list滚动到的位置item下标
function UIClubSelectSearchTime:_getListCurItemStr(list)
	local items  = list:getItems();
	local item = list:getCenterItemInCurrentView();
	local str  = item:getChildByName("BitmapFontLabel_cell_item"):getString();
	local listIdx = table.indexof(self._listViews,list);
	local selects = TurnSelects[listIdx];
	for i,v in ipairs(selects) do
		if str == v then
			return str;
		end
	end
	return "";
end

function UIClubSelectSearchTime:_onClickCancel(sender)
	UIManager:getInstance():hide("UIClubSelectSearchTime");
end

-- 确认
function UIClubSelectSearchTime:_onClickOk()
	-- 统计点击查询按钮的人次
	game.service.DataEyeService.getInstance():onEvent("Tquery")

	local startTime = self:_getStartQuarryTimeStamp();
	local endTime   = self:_getEndQuarryTimeStamp();
	if self:_isSelectNow() then	-- 如果选的是当前，则截止时间变成当前，不取滚轮的值
		endTime = kod.util.Time.now();
	end

	local searchData = {clubId = self._clubId, startTimeStamp = startTime, endTimeStamp = endTime};
	if self._callback ~= nil then
		self._callback(searchData)
	end

	UIManager:getInstance():hide("UIClubSelectSearchTime");
end

-- 把前天，昨天，今天转换成具体的日期
function UIClubSelectSearchTime:_castDayByDayDescribe(dayDes)
	local days = {"前天", "昨天", "今天", "当前"}
	local idx  = table.indexof(days,dayDes);
	local nowTime = kod.util.Time.now();
	local formatT = kod.util.Time.time2Date(nowTime);
	idx = idx > 3 and 3 or idx;		-- 当前也是今天
	local day = formatT.day - (3 - idx);
	return day;
end

-- 把具体的日期转换成前天，昨天，今天
function UIClubSelectSearchTime:_castDayDescribeByDay(day)
	local days = {"前天", "昨天", "今天"}
	local nowTime = kod.util.Time.now();
	local formatT = kod.util.Time.time2Date(nowTime);
	local idx = 3 - (formatT.day - day);
	return days[idx];
end

-- 获取当前选择的开始时间戳，变换成day，hour，minute
function UIClubSelectSearchTime:_getStartQuarryTimeStamp()
	local nowTime = kod.util.Time.now()
	local formatT = kod.util.Time.time2Date(nowTime);
	local today   = formatT.day;
	local startDay 	= self:_getListCurItemStr(self._listViews[1]);
	local startHour	= self:_getListCurItemStr(self._listViews[2]);
	local startMin	= self:_getListCurItemStr(self._listViews[3]);
	startDay = self:_castDayByDayDescribe(startDay);
	local startStamp = self:_castTimeToStamp(startDay,startHour,startMin);
	return startStamp;
end

-- 获取当前选择的截止时间戳，变换成day，hour，minute
function UIClubSelectSearchTime:_getEndQuarryTimeStamp()
	local nowTime = kod.util.Time.now()
	local formatT = kod.util.Time.time2Date(nowTime);
	local today   = formatT.day;
	local startDay 	= self:_getListCurItemStr(self._listViews[4]);
	local startHour	= self:_getListCurItemStr(self._listViews[5]);
	local startMin	= self:_getListCurItemStr(self._listViews[6]);
	startDay = self:_castDayByDayDescribe(startDay);
	local startStamp = self:_castTimeToStamp(startDay,startHour,startMin);
	return startStamp;
end

-- 把分散的时间转换成时间戳
function UIClubSelectSearchTime:_castTimeToStamp(day,hour,minutes)
	day 	= tonumber(day);
	hour 	= tonumber(hour);
	minutes = tonumber(minutes);
	local nowTime = kod.util.Time.now();
	local formatT = kod.util.Time.time2Date(nowTime);
	local stamp = nowTime + (day - formatT.day)*24*60*60 + (hour - formatT.hour)*60*60 + (minutes - formatT.min)*60;
	-- 下面的方法不好使
	-- local sf2    = kod.util.Time.time2Date(stamp2);
	-- local stamp2 = os.time({day = day, month = formatT.month, year = formatT.year, hour = hour, minute = minutes, second=0}) -- 指定时间的时间戳
	return stamp;
end

-- 是不是选的是当前
function UIClubSelectSearchTime:_isSelectNow()
	return self:_getListCurItemStr(self._listViews[4]) == "当前";
end

function UIClubSelectSearchTime:needBlackMask()
	return true
end

function UIClubSelectSearchTime:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubSelectSearchTime:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubSelectSearchTime;