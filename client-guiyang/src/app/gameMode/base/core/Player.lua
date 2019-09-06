local bit = require("bit")
local Constants = require("app.gameMode.mahjong.core.Constants");

local BasePlayer = class("BasePlayer")

-- @param id: number
-- @param name: string
-- @param headIconUrl: string
-- @param position: number
-- @param ip: string
-- @param sex: number
-- @param seat: CardDefines.Chair
function BasePlayer:ctor(playerInfo)
    self.id = playerInfo.roleId;
    self.name = playerInfo.nickname;
    self.headIconUrl = playerInfo.headImageUrl;
    self.position = playerInfo.position;
    self.ip = playerInfo.ip;
    self.sex = playerInfo.sex;
    self.status = playerInfo.status;
    self.totalPoint = playerInfo.totalPoint; -- 房间内累计得分
    self.pointInGame = playerInfo.pointInGame; -- 当前局得分
    self.rank = playerInfo.rank
    self.nickname = playerInfo.nickname
    self.roleId = playerInfo.roleId
    self.headImageUrl = playerInfo.headImageUrl
    self.isIdeneity = playerInfo.isIdentity
    self.headFrame = playerInfo.headFrame
    self.specialEffect = playerInfo.specialEffect or {}   -- 玩家所使用的牌局内特效
    self.seat = 0;			-- 玩家的座位位置，这个用起来比较方便
    self.cPosition = -1 -- 客户端用来表示的位置, 和 seat

    -- 追加这些是因为能够使协议与服务器对上 我去， 命名规范啊老铁们 同样的意思重复的字段， 脚本语言写的话很蛋疼的
    -- 玩家ID
    self.roleId = rawget(playerInfo, "roleId") or rawget(playerInfo, "id")
    self.id = self.roleId

    -- 玩家昵称
    self.roleName = rawget(playerInfo, "roleName") or rawget(playerInfo, "name") or rawget(playerInfo, "nickname")
    self.name = self.roleName
    self.nickname = self.roleName

    -- 玩家头像
    self.headImageUrl = rawget(playerInfo, "headImageUrl") or rawget(playerInfo, "iconUrl")
    self.headIconUrl = self.headImageUrl
    self.iconUrl = self.headImageUrl
end

function BasePlayer:getId()
    return self.id
end

function BasePlayer:getName()
    return self.name
end

function BasePlayer:getHeadIconUrl()
    return self.headIconUrl
end

function BasePlayer:isHost()
    return bit.band(self.status, Constants.PlayerStatus.HOST) ~= 0
end

function BasePlayer:isBanker()
    return bit.band(self.status, Constants.PlayerStatus.ZHUANGJIA) ~= 0
end

function BasePlayer:isReady()
    return bit.band(self.status, Constants.PlayerStatus.READY) ~= 0
end

function BasePlayer:isOnline()
    return bit.band(self.status, Constants.PlayerStatus.ONLINE) ~= 0
end

function BasePlayer:hasIgnoreSameIp()
    return bit.band(self.status, Constants.PlayerStatus.IGNORE_SAME_IP) ~= 0
end

function BasePlayer:isLocal()
    if self.cPosition ~= -1 then
        return self._cPosition == 1
    end
    local localId = game.service.LocalPlayerService:getInstance():getRoleId()
    return self.id == localId
end

function BasePlayer:isWaiTing()
	return bit.band(self.status, Constants.PlayerStatus.WAITING) ~= 0
end

function BasePlayer:getSpecialEffect()
    return self.specialEffect or {}
end

-- 已经截取过了的名字
function BasePlayer:getShortName(bytecount)
    bytecount = bytecount or 8
    self.shortNames = self.shortNames or {}
    local ret = self.shortNames[bytecount]
    if ret == nil then
        local name = kod.util.String.getMaxLenString(self.nickname or self.name, bytecount)
        self.shortNames[bytecount] = name
    end
    return self.shortNames[bytecount]
end

-- 头像框
function BasePlayer:getHeadFrame()
    return self.headFrame
end

function BasePlayer:getIconURL()
    return self.headIconUrl or self.headImageUrl or self.iconUrl
end

return BasePlayer;
