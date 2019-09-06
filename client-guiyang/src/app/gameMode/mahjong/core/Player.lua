local bit = require("bit")
local Constants = require("app.gameMode.mahjong.core.Constants");

local MahjongPlayer = class("MahjongPlayer")

-- @param id: number
-- @param name: string
-- @param headIconUrl: string
-- @param position: number
-- @param ip: string
-- @param sex: number
-- @param seat: CardDefines.Chair
function MahjongPlayer:ctor()
	self.id = 0;
	self.name = "";
	self.headIconUrl = "";
	self.position = 0;
	self.ip = "";
	self.sex = 0;
	self.status = 0;
	self.totalPoint = 0;	-- 房间内累计得分
	self.pointInGame = 0;	-- 当前局得分
	self.seat = 0;			-- 玩家的座位位置，这个用起来比较方便
end

function MahjongPlayer:isHost()
	return bit.band(self.status, Constants.PlayerStatus.HOST) ~= 0
end

function MahjongPlayer:isBanker()
	return bit.band(self.status, Constants.PlayerStatus.ZHUANGJIA) ~= 0
end

function MahjongPlayer:isReady()
	return bit.band(self.status, Constants.PlayerStatus.READY) ~= 0
end

function MahjongPlayer:isOnline()
	return bit.band(self.status, Constants.PlayerStatus.ONLINE) ~= 0
end

function MahjongPlayer:hasIgnoreSameIp()
	return bit.band(self.status, Constants.PlayerStatus.IGNORE_SAME_IP) ~= 0
end

function MahjongPlayer:isWaiTing()
	return bit.band(self.status, Constants.PlayerStatus.WAITING) ~= 0
end

return MahjongPlayer;
