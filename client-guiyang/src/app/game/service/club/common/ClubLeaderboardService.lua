local ClubLeaderboardService = class("ClubLeaderboardService")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function ClubLeaderboardService:ctor(cs)
	-- 绑定事件系统
	cc.bind(self, "event");
	self._clubService = cs
end

function ClubLeaderboardService:initialize()
	local requestManager = net.RequestManager.getInstance()
	
	requestManager:registerResponseHandler(net.protocol.CLCQueryStatisticsInfoRES.OP_CODE, self, self._onCLCQueryStatisticsInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryMemberRankInfoRES.OP_CODE, self, self._onCLCQueryMemberRankInfoRES)
end

function ClubLeaderboardService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	-- 解绑事件系统
	cc.unbind(self, "event");
end

-- 请求俱乐部数据日报信息
function ClubLeaderboardService:sendCCLQueryStatisticsInfoREQ(clubId)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryStatisticsInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId)
	game.util.RequestHelper.request(request)
end

function ClubLeaderboardService:_onCLCQueryStatisticsInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_STATISTICS_INFO_SUCCESS then
		self:dispatchEvent({name = "EVENT_CLUB_PLAYERDATAINFO_CHANGE", statisticsInfos = protocol.statisticsInfos});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求俱乐部成员排行信息
function ClubLeaderboardService:sendCCLQueryMemberRankInfoREQ(clubId, rankType, startTime, endTime, winnerScore)
	local request = net.NetworkRequest.new(net.protocol.CCLQueryMemberRankInfoREQ, self._clubService:getClubServiceId())
	request:getProtocol():setData(clubId, rankType, startTime, endTime, winnerScore)
	game.util.RequestHelper.request(request)
end

function ClubLeaderboardService:_onCLCQueryMemberRankInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.CLC_QUERY_MEMBER_RANK_INFO_SUCCESS then
		local winnerInfo =
		{
			winnerScore = protocol.winnerScore, -- 查询的大赢家分数
			overWinnerCount = protocol.overWinnerCount, -- 超过设置分数的大赢家次数
			totalWinnerCount = protocol.totalWinnerCount -- 总的大赢家次数
		}
		self:dispatchEvent({name = "EVENT_CLUB_PLAYERINFO_CHANGE", rankType = protocol.rankType, rankInfos = protocol.rankInfos, winnerInfo = winnerInfo});
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

return ClubLeaderboardService 
