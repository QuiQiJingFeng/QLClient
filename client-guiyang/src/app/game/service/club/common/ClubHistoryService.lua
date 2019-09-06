local ClubHistoryService = class("ClubHistoryService")

function ClubHistoryService:ctor(cs)
    -- 绑定事件系统
	cc.bind(self, "event");

    self._clubService = cs
end

function ClubHistoryService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CLCClubHistoryRES.OP_CODE, self, self._onCLCClubHistoryRES)
    requestManager:registerResponseHandler(net.protocol.RCProcessHistoryRES.OP_CODE, self, self._onRCProcessHistoryRES)
    requestManager:registerResponseHandler(net.protocol.RCQueryRoomDestroyInfoRES.OP_CODE, self, self._onRCQueryRoomDestroyInfoRES)
end

function ClubHistoryService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);

    -- 解绑事件系统
	cc.unbind(self, "event");
end

-- 请求战绩信息
function ClubHistoryService:sendClubHistoryREQ(clubId, start, num, queryRoleId, minScore, queryTime, onlyAbnormalRoom)
    local club = self._clubService:getClub(clubId)
    if Macro.assertTrue(club == nil) then
        return false
    end

    -- 还未想好，请求的变动条件
    -- if #club.histories == 0 then
        local request = net.NetworkRequest.new(net.protocol.CCLClubHistoryREQ, game.service.LocalPlayerService.getInstance():getClubService():getClubServiceId())
        request:getProtocol():setData(clubId, start, num, queryRoleId, queryTime, minScore, onlyAbnormalRoom)
        game.util.RequestHelper.request(request)
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Req_Club_History);
    -- end
end

-- 返回战绩信息
function ClubHistoryService:_onCLCClubHistoryRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLC_CLUB_HISTORY_SUCCESS then
        local club = self._clubService:getClub(protocol.clubId)
        if Macro.assertFalse(club ~= nil) then
            -- TODO :
            club.histories = clone(protocol.roomRecords)
            for key,val in ipairs(club.histories) do
                -- 为分享填充亲友圈ID
                val.clubId = protocol.clubId
            end
            self:dispatchEvent({ name = "EVENT_CLUB_HISTORY_DATA_RETRIVED", clubId = protocol.clubId});            
        end
    end
end

-- 请求处理战绩
function ClubHistoryService:sendCRProcessHistoryREQ(roomId, createTime, isProcessed)
    local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
    local request = net.NetworkRequest.new(net.protocol.CRProcessHistoryREQ, serverId)
    local areaId = game.service.LocalPlayerService.getInstance():getArea()
	request:getProtocol():setData(roomId, createTime, isProcessed, areaId)
    request.roomId = roomId
    request.createTime = createTime
    request.isProcessed = isProcessed
	game.util.RequestHelper.request(request)
end

function ClubHistoryService:_onRCProcessHistoryRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.RC_PROCESS_HISTORY_SUCCESS then
        self:dispatchEvent({ name = "EVENT_CLUB_HISTORY_PROCESS", roomId = request.roomId, createTime = request.createTime, isProcessed = request.isProcessed})          
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 请求战绩解散原因
function ClubHistoryService:sendCRQueryRoomDestroyInfoREQ(roomId, createTime)
    local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
    local request = net.NetworkRequest.new(net.protocol.CRQueryRoomDestroyInfoREQ, serverId)
    local areaId = game.service.LocalPlayerService.getInstance():getArea()
    request:getProtocol():setData(roomId, createTime, areaId)
    game.util.RequestHelper.request(request)
end

function ClubHistoryService:_onRCQueryRoomDestroyInfoRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.RC_QUERY_ROOM_DESTROY_INFO_SUCCESS then
        local description = protocol.destroyDescription
        if string.len(description) <= 0 then 
            description = nil 
        else 
            description = json.decode(description)
        end 

        local destroyInfo =
        {
            destroyReason = protocol.destroyReason, -- 房间解散原因
	        destroyerId = protocol.destroyerId, -- 解散人id
	        destroyerName = protocol.destroyerName, -- 解散人昵称
            destroyDescription = description,
        }
        if destroyInfo.destroyReason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.LEAGUE_SCORE_LESS_DESTROY then
            local infos = destroyInfo.destroyDescription.player_scores
            UIManager.getInstance():show("UIBigLeagueScoreAbnormal",infos)
        else
            UIManager:getInstance():show("UIClubDissmisRoomReasonResult", destroyInfo)       
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

return ClubHistoryService