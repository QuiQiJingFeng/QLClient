
local ns = namespace("game.service")
-- 查询数据存储
local SearchDataStore = class("SearchDataStore");
function SearchDataStore:ctor()
    self.clubSearchDatas = {};      -- 存放各个club查询的数据
end
-- 存储单元
local SearchDataStoreCell = class("SearchDataStoreCell");
function SearchDataStoreCell:ctor()
    self.clubId           = 0;        -- 亲友圈id
    self.startTimeStamp   = 0;        -- 查询开始时间 时间戳,这里记录的单位是秒，服务器上传和下行都是毫秒，注意一下
    self.endTimeStamp     = 0;        -- 查询结束时间 时间戳
    self.totalCostTickets = 0;        -- 房卡总消耗
    self.totalRoundNum    = 0;        -- 总局数
    self.preCostTickets   = 0;        -- 预扣卡数  
    self.yesterdayRoomNum = 0;        -- 昨天房间数
    self.todayRoomNum     = 0;        -- 今天房间数
    self.todayRoomCost    = 0;        -- 今天消耗房卡数
    self.yesterdayRoomCost = 0;       -- 昨日消耗房卡数
end

-- 处理玩家数据相关逻辑
local RecordService = class("RecordService")
ns.RecordService = RecordService

-- 单例支持
-- @return LoginService
function RecordService.getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getRecordService()
    end

    return nil
end

function RecordService:ctor()
    -- 绑定事件系统
	cc.bind(self, "event");

    self._recordServerId = -1 -- 用于 RecordService通信需要
    self._roleId = nil ;
    self._searchDataStore = {};
end

function RecordService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.CLCCheckClubBillRES.OP_CODE, self, self._onCLCCheckClubBillRES)
    requestManager:registerResponseHandler(net.protocol.CLCCheckClubBillTodayRES.OP_CODE, self, self._onCLCCheckClubBillTodayRES)
end

function RecordService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);

    -- 解绑事件系统
	cc.unbind(self, "event");
end

function RecordService:setId(roleId, _recordServerId)
    self._roleId = roleId
    self._recordServerId = _recordServerId
end

-- 加载本地存储的
function RecordService:loadLocalStorage()
    self._searchDataStore = manager.LocalStorage.getUserData(self._roleId, "SearchDataStore", SearchDataStore);
end

-- 存储查询结果
function RecordService:_saveLocalStorage()
    manager.LocalStorage.setUserData(self._roleId, "SearchDataStore", self._searchDataStore)
end

-- 加入或者更新存储数据
-- function RecordService:addOrUpdateSearchData(searchData)
--     if not searchData or not searchData.clubId then
--         return;
--     end
--     self._searchDataStore = self._searchDataStore or SearchDataStore.new();
--     for i,v in ipairs(self._searchDataStore.clubSearchDatas) do
--         if searchData.clubId == v.clubId then
--             for k,v2 in pairs(SearchDataStoreCell) do
--                 if v[k] then
--                     searchData[k] = v[k];
--                 end
--             end
--             return;
--         end
--     end
--     table.insert( self._searchDataStore.clubSearchDatas, searchData);
-- end

-- 获取指定clubid的数据
function RecordService:getSearchData(clubId)
    self._searchDataStore = self._searchDataStore or SearchDataStore.new();
    for i,v in ipairs(self._searchDataStore.clubSearchDatas) do
        if clubId == v.clubId then
            return v;
        end
    end
    return nil;
end

-- 获取指定clubid的数据 强制返回对象
function RecordService:_getSureSearchData(clubId)
    local searchData = self:getSearchData(clubId);
    if searchData == nil then    -- 不存在的话就新建一个
        self._searchDataStore = self._searchDataStore or SearchDataStore.new();
        searchData = SearchDataStoreCell.new();
        searchData.clubId = clubId;
        table.insert(self._searchDataStore.clubSearchDatas, searchData);
    end
    return searchData;
end

------------------------------
-- 亲友圈对账单查询功能
------------------------------

-- 请求查询亲友圈账单,注意startTime 和 endTime 都是毫秒
function RecordService:sendCCLCheckClubBillREQ(clubId,startTime,endTime)
    local request = net.NetworkRequest.new(net.protocol.CCLCheckClubBillREQ, game.service.LocalPlayerService.getInstance():getClubService():getClubServiceId())
    request:getProtocol():setData(clubId,startTime,endTime)
    game.util.RequestHelper.request(request)
end

-- 请求查询亲友圈账单返回
function RecordService:_onCLCCheckClubBillRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CHECK_CLUB_BILL_SUCCESS then 
        local searchData = self:_getSureSearchData(protocol.clubId);
        searchData.totalCostTickets  = protocol.totalRoomCost;        -- 房卡总消耗
        searchData.totalRoundNum     = protocol.settledRoomNum;       -- 总局数
        searchData.preCostTickets    = protocol.unsettledRoomCost;    -- 预扣卡数 
        searchData.startTimeStamp    = protocol.startTime/1000;       -- 转换成秒
        searchData.endTimeStamp      = protocol.endTime/1000;
        self:_saveLocalStorage();

        self:dispatchEvent({name = "EVENT_CLUB_SEARCH_DATA_CHANGE", searchData = searchData});
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求查询今日亲友圈账单
function RecordService:sendCCLCheckClubBillTodayREQ(clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLCheckClubBillTodayREQ, game.service.LocalPlayerService.getInstance():getClubService():getClubServiceId())
    request:getProtocol():setData(clubId)
    game.util.RequestHelper.request(request)
end

-- 请求查询今日亲友圈账单返回
function RecordService:_onCLCCheckClubBillTodayRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CHECK_CLUB_BILL_TODAY_SUCCESS then 
        local storeData = self:_getSureSearchData(protocol.clubId);
        storeData.yesterdayRoomNum = protocol.yesterdayRoomNum;    
        storeData.todayRoomNum = protocol.todayRoomNum;
        storeData.todayRoomCost = protocol.todayRoomCost;
        storeData.yesterdayRoomCost = protocol.yesterdayRoomCost;

        local billData =
        {
            yesterdayRoomNum = protocol.yesterdayRoomNum,    
            todayRoomNum = protocol.todayRoomNum,
            todayRoomCost = protocol.todayRoomCost,
            yesterdayRoomCost = protocol.yesterdayRoomCost,
        }

        self:dispatchEvent({ name = "EVENT_CLUB_TODAY_BILL_CHANGE",clubId = protocol.clubId, billData = billData});
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end
