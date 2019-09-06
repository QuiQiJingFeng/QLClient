local BigLeagueRoomData = class("BigLeagueRoomData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


function BigLeagueRoomData:ctor()
    self:init()
end

function BigLeagueRoomData:init() 
    self._roomList = {}     --全部房间列表
    self._showroomList = {}  --显示房间列表
    self._roomDetail = {}   --房间具体信息
end
--[[房间相关
message LeagueRoomIndexProto					// 团队房间索引数据
{
	optional int32 roomId = 1;					// 房间id
	optional int64 createTime = 2;				// 房间创建时间
	optional int32 maxPlayer = 3;				// 房间内最大玩家数
	optional int32 playerCount = 4;				// 房间内玩家个数
	optional bool hasStartBattle = 5;			// 房间是否已开局
	optional int64 gamePlayId = 6;              // 房间玩法id
	optional int64 modifyTime = 7;              // 房间玩法最后修改时间
}
message LeagueTableInfoPROTO					    // 俱乐部牌桌信息
{
	required int32 roomId = 1;						// 房间ID
	required int32 playerMax = 2;					// 所需多少玩家
	required int32 roundType = 3;					// 房间圈/局规则
	required int64 createTimestamp = 4;			    // 创建的时间戳
	required bool isRemoved = 5;					// 是否是要移除的房间
	required bool hasStartBattle = 6;				// 是否已经开局
	required int32 finishRoundCount = 7;			// 房间已完成的局数
	repeated int32 gameplays = 8;					// 玩法
	repeated ClubTablePlayerInfoPROTO players = 9;	// 玩家列表
}
]]--

function BigLeagueRoomData:setRoomList(proto)

    self._roomList = clone(proto.roomIndexs)

    for _,room in ipairs(self._roomList) do
        room.isSimple = true
    end

    if self._roomList == nil then
        return
    end
    

    self:filterRoomList()  --筛选所选玩法的房间
       -- 列表排序
    table.sort(self._showroomList, function(a, b)
        -- 1 未开局  2 提前开局 3 已满
        local advance_a =  a.hasStartBattle and 3 or 1
        if a.hasStartBattle and a.maxPlayer ~= a.playerCount then
            advance_a = 2
        end

        local advance_b =  b.hasStartBattle and 3 or 1
        if b.hasStartBattle and b.maxPlayer ~= b.playerCount then
            advance_b = 2
        end
        if advance_a == advance_b then -- 当开局情况一样时
            local _a = a.maxPlayer - a.playerCount -- a差几个人开局
            _a = _a == 0 and 10000 or _a -- 把0个人的牌桌认为差10000个人，这样就会排到最后去，当一个桌子能做10000个人的时候，再来改这里
            local _b = b.maxPlayer - b.playerCount -- b差几个人开局
            _b = _b == 0 and 10000 or _b -- 同理

            if _a == _b then -- 当差的人一样时，比较时间先后
                return a.createTime < b.createTime
            end
            -- 差的不一样时，比较谁差的少，谁靠前
            return _a < _b
        end

        return advance_a < advance_b
    end)
end

function BigLeagueRoomData:filterRoomList()
    self._showroomList = {}
    local BigLeagueService =  game.service.bigLeague.BigLeagueService:getInstance()
    if BigLeagueService:getIsSuperLeague() or (not next(self._roomList)) then --切换联盟，取消关注联盟房间通知也会过来
        self._showroomList = clone(self._roomList)
        return 
    end
    local localGamePlay = BigLeagueService:getLeagueData():getGamePlay(BigLeagueService:getLeagueData():getLeagueId())

    --没有玩法，默认选中所有玩法
    if not localGamePlay or not next(localGamePlay) or BigLeagueService:getIsSuperLeague() then  --是A或者沒有本地玩法筛选数据的话，就显示全部房间数据
        self._showroomList = clone(self._roomList)
        return 
    end

    for _,room in ipairs(self._roomList) do 
        if localGamePlay[tostring(room.gamePlayId)] and localGamePlay[tostring(room.gamePlayId)].showRoomTime == room.modifyTime then 
            table.insert(self._showroomList, room)
        end
    end
end

function BigLeagueRoomData:getNoDetailRooms()
    local arr = {}
    for _, room in pairs(self._roomList) do
        if room and self._roomDetail[room.roomId] == nil then
            table.insert(arr, room.roomId)
            if #arr >= 21 then
                return arr
            end
        end
    end
    return arr
end

function BigLeagueRoomData:removeOneRoom(roomId)
    for k,room in ipairs(self._roomList) do
        if room and room.roomId == roomId then
            -- self._roomList[k] = {}
            table.remove(self._roomList, k)
            return
        end
    end
end

function BigLeagueRoomData:addOneRoom(pRoom)
    -- local idx = 0
    for k, room in ipairs(self._roomList) do
        -- if room.roomId == nil and idx == 0 then
        --     idx = k
        if room.roomId == pRoom.roomId then
            pRoom.idx = k
            return
        end
    end
    -- idx = idx == 0 and #self._roomList+1 or idx
    local obj = {}
    obj.roomId = pRoom.roomId
    obj.createTime = pRoom.createTimestamp
    obj.maxPlayer = pRoom.playerMax
    obj.playerCount = #pRoom.players
    obj.hasStartBattle = pRoom.hasStartBattle
    obj.isSimple = true
    obj.gamePlayId = pRoom.gameplay.id
    obj.modifyTime = pRoom.gameplay.modifyTime
    if pRoom.hasStartBattle then
        -- pRoom.idx = #self._roomList+1
        self._roomList[#self._roomList+1] = obj
    else
        -- pRoom.idx = 1
        table.insert(self._roomList, 1, obj )
    end
end

function BigLeagueRoomData:getRoomList()
    return self._roomList
end

function BigLeagueRoomData:getShowRoomList()
    return self._showroomList
end

function BigLeagueRoomData:setRoomDetails(proto)
    -- self._roomDetail = proto.tableInfos
    -- dump(proto.tableInfos)
    -- dump(proto.tableInfos[1].gameplay.gameplays)
    -- dump(proto.tableInfos[1].players)
    for _, room in ipairs(proto.tableInfos) do        
        if not room.isRemoved then   
            self._roomDetail[room.roomId] = room         
            self._testRoomId = room.roomId
            room.isSimple = false
            -- print("addOneRoom..", room.roomId)
            self:addOneRoom(room)
        else
            self:removeOneRoom(room.roomId)
        end
    end
    self:filterRoomList()  --筛选所选玩法的房间
    -- dump(self._roomList, "roomList~~~~~~~~~~~~")
end

function BigLeagueRoomData:getRoomDetailById(roomId)
    return self._roomDetail[roomId] or self:getSimpleRoomByid(roomId)
end

function BigLeagueRoomData:getSimpleRoomByid(roomId)
    for _,info in ipairs(self._roomList) do
        if info.roomId == roomId then
            return info
        end
    end
    return nil
end

function BigLeagueRoomData:getRoomDetail()
    return self._roomDetail
end

--获取当前桌和当前桌子所在行的信息
function BigLeagueRoomData:getRoomPositionAndLine(roomId)
    
    local room = self._roomDetail[roomId]
    if room == nil then
        return 0, nil
    end
    local idx = 0
    for index, room in ipairs(self._showroomList) do
        if room.roomId == roomId then
            idx = index
        end
    end
    local line = {}
    local n = math.floor((idx-1) / 3)       --第n+1行
    for i = 1,3 do
        local room = self._showroomList[3 * n + i]
        if room and room.roomId then
            table.insert(line, self._roomDetail[room.roomId])
        else
            table.insert(line, 1)
        end
    end
    return n+1, line
end

function BigLeagueRoomData:clearRoomData()
    self._roomDetail = {}
    self._showroomList = {}
    self._roomList = {}
end

function BigLeagueRoomData:createTestRoomData()
    for i = 1, 6 do
        local obj = {
            roomId = i;					
            createTime = kod.util.Time.now();				
            maxPlayer = 3;				
            playerCount = 2;				
            hasStartBattle = i%2 == 0;			
        }
        table.insert(self._roomList, obj)
    end
    
end

local headIdx = 1
function BigLeagueRoomData:createTestDetailRoom()
    local proto = {}
    proto.tableInfos = {}
    for i = 1, 10 do
        local obj = clone(self:getRoomDetailById(self._testRoomId))
        obj.players[1].head = string.format( "http://server-image.qcloud.cdn.majiang01.com/gold/virtual_image/FINAL_VIRTUAL_%d.jpg", headIdx)
        obj.roomId = obj.roomId + headIdx
        headIdx = headIdx + 1       
        table.insert(proto.tableInfos, obj)
    end
    -- dump(proto, "createTestDetailRoom~~~")
    self:setRoomDetails(proto)

    game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_ROOMS_DETAIL", rooms = proto.tableInfos})
end
return BigLeagueRoomData