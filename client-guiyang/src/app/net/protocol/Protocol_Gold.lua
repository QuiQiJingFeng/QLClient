local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

local CGOQueryGoldInfoREQ = class("CGOQueryGoldInfoREQ", ProtocolBase)
ns.CGOQueryGoldInfoREQ = CGOQueryGoldInfoREQ
CGOQueryGoldInfoREQ.OP_CODE = net.ProtocolCode.P_C_GO_QUERY_GOLD_INFO_REQ
CGOQueryGoldInfoREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOQueryGoldInfoREQ'
function CGOQueryGoldInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOQueryGoldInfoREQ.OP_CODE, serverId, callback)
end

local GOCQueryGoldInfoRES = class("GOCQueryGoldInfoRES", ProtocolBase)
ns.GOCQueryGoldInfoRES = GOCQueryGoldInfoRES
GOCQueryGoldInfoRES.OP_CODE = net.ProtocolCode.P_GO_C_QUERY_GOLD_INFO_RES
GOCQueryGoldInfoRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCQueryGoldInfoRES'
GOCQueryGoldInfoRES.SUCCESS_CODE = net.ProtocolCode.GO_C_QUERY_GOLD_INFO_SUCCESS
function GOCQueryGoldInfoRES:ctor(serverId, callback)
    self.super.ctor(self, GOCQueryGoldInfoRES.OP_CODE, serverId, callback)
end

-- 领取破产补助（救助金）
local CGoldBrokeHelpREQ = class("CGoldBrokeHelpREQ", ProtocolBase)
ns.CGoldBrokeHelpREQ = CGoldBrokeHelpREQ
CGoldBrokeHelpREQ.OP_CODE = net.ProtocolCode.P_C_GOLD_BROKE_HELP_REQ
CGoldBrokeHelpREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGoldBrokeHelpREQ'
function CGoldBrokeHelpREQ:ctor(serverId, callback)
    self.super.ctor(self, CGoldBrokeHelpREQ.OP_CODE, serverId, callback)
end

-- 领取破产补助（救助金）
local GoldCBrokeHelpRES = class("GoldCBrokeHelpRES", ProtocolBase)
ns.GoldCBrokeHelpRES = GoldCBrokeHelpRES
GoldCBrokeHelpRES.OP_CODE = net.ProtocolCode.P_GOLD_C_BROKE_HELP_RES
GoldCBrokeHelpRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCBrokeHelpRES'
function GoldCBrokeHelpRES:ctor(serverId, callback)
    self.super.ctor(self, GoldCBrokeHelpRES.OP_CODE, serverId, callback)
end

local CGoldMatchREQ = class("CGoldMatchREQ", ProtocolBase)
ns.CGoldMatchREQ = CGoldMatchREQ
CGoldMatchREQ.OP_CODE = net.ProtocolCode.P_C_GOLD_MATCH_REQ
CGoldMatchREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGoldMatchREQ'
function CGoldMatchREQ:ctor(serverId, callback)
    self.super.ctor(self, CGoldMatchREQ.OP_CODE, serverId, callback)
end

function CGoldMatchREQ:setData(roomGrade)
    local protocolBuf = self:getProtocolBuf()
    protocolBuf.roomGrade = roomGrade
end

CGoldMatchREQ.Enum_RoomGrade = {
    FIRST = 1;  --初级场
    SECOND = 2; --中级场
    THIRD = 3;  --高级场
    FOUR = 4;   --雀神场
    QUICK = 14;  --快速匹配
}

local GoldCMatchRES = class("GoldCMatchRES", ProtocolBase)
ns.GoldCMatchRES = GoldCMatchRES
GoldCMatchRES.OP_CODE = net.ProtocolCode.P_GOLD_C_MATCH_RES
GoldCMatchRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCMatchRES'
function GoldCMatchRES:ctor(serverId, callback)
    self.super.ctor(self, GoldCMatchRES.OP_CODE, serverId, callback)
end


-- 牌局开始的时候就需要扣除玩家的服务费，所以让battle发一个牌局开始的消息过来，让gold扣除玩家的金币
local GoldCMatchResultSYN = class("GoldCMatchResultSYN", ProtocolBase)
ns.GoldCMatchResultSYN = GoldCMatchResultSYN
GoldCMatchResultSYN.OP_CODE = net.ProtocolCode.P_GOLD_C_MATCH_RESULT_SYN
GoldCMatchResultSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCMatchResultSYN'
function GoldCMatchResultSYN:ctor(serverId, callback)
    self.super.ctor(self, GoldCMatchResultSYN.OP_CODE, serverId, callback)
end



-- 玩家请求取消匹配
local CGoldCancelMatchREQ = class("CGoldCancelMatchREQ", ProtocolBase)
ns.CGoldCancelMatchREQ = CGoldCancelMatchREQ
CGoldCancelMatchREQ.OP_CODE = net.ProtocolCode.P_C_GOLD_CANCEL_MATCH_REQ
CGoldCancelMatchREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGoldCancelMatchREQ'
function CGoldCancelMatchREQ:ctor(serverId, callback)
    self.super.ctor(self, CGoldCancelMatchREQ.OP_CODE, serverId, callback)
end

-- 取消匹配回复
local GoldCCancelMatchRES = class("GoldCCancelMatchRES", ProtocolBase)
ns.GoldCCancelMatchRES = GoldCCancelMatchRES
GoldCCancelMatchRES.OP_CODE = net.ProtocolCode.P_GOLD_C_CANCEL_MATCH_RES
GoldCCancelMatchRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCCancelMatchRES'
function GoldCCancelMatchRES:ctor(serverId, callback)
    self.super.ctor(self, GoldCCancelMatchRES.OP_CODE, serverId, callback)
end


-- 打牌送礼券信息
local CGoldBattleForMallPointInfoREQ = class("CGoldBattleForMallPointInfoREQ", ProtocolBase)
ns.CGoldBattleForMallPointInfoREQ = CGoldBattleForMallPointInfoREQ
CGoldBattleForMallPointInfoREQ.OP_CODE = net.ProtocolCode.P_C_GOLD_BATTLE_FOR_MALL_POINT_INFO_REQ
CGoldBattleForMallPointInfoREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGoldBattleForMallPointInfoREQ'
function CGoldBattleForMallPointInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CGoldBattleForMallPointInfoREQ.OP_CODE, serverId, callback)
end

-- 打牌送礼券信息
local GoldCBattleForMallPointInfoRES = class("GoldCBattleForMallPointInfoRES", ProtocolBase)
ns.GoldCBattleForMallPointInfoRES = GoldCBattleForMallPointInfoRES
GoldCBattleForMallPointInfoRES.OP_CODE = net.ProtocolCode.P_GOLD_C_BATTLE_FOR_MALL_POINT_INFO_RES
GoldCBattleForMallPointInfoRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCBattleForMallPointInfoRES'
function GoldCBattleForMallPointInfoRES:ctor(serverId, callback)
    self.super.ctor(self, GoldCBattleForMallPointInfoRES.OP_CODE, serverId, callback)
end

-- 客户端领取礼券消息
local GoldCRewardMallPointSYN = class("GoldCRewardMallPointSYN", ProtocolBase)
ns.GoldCRewardMallPointSYN = GoldCRewardMallPointSYN
GoldCRewardMallPointSYN.OP_CODE = net.ProtocolCode.P_GOLD_C_REWARD_MALL_POINT_SYN
GoldCRewardMallPointSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GoldCRewardMallPointSYN'
function GoldCRewardMallPointSYN:ctor(serverId, callback)
    self.super.ctor(self, GoldCRewardMallPointSYN.OP_CODE, serverId, callback)
end

-- 胡大牌分享有礼请求
local CGOPickWXShareRewardREQ = class("CGOPickWXShareRewardREQ", ProtocolBase)
ns.CGOPickWXShareRewardREQ = CGOPickWXShareRewardREQ
CGOPickWXShareRewardREQ.OP_CODE = net.ProtocolCode.P_C_GO_PICK_WX_SHARE_REWARD_REQ
CGOPickWXShareRewardREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOPickWXShareRewardREQ'
function CGOPickWXShareRewardREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOPickWXShareRewardREQ.OP_CODE, serverId, callback)
end

-- 胡大牌分享有礼响应
local GOCPickWXShareRewardRES = class("GOCPickWXShareRewardRES", ProtocolBase)
ns.GOCPickWXShareRewardRES = GOCPickWXShareRewardRES
GOCPickWXShareRewardRES.OP_CODE = net.ProtocolCode.P_GO_C_PICK_WX_SHARE_REWARD_RES
GOCPickWXShareRewardRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCPickWXShareRewardRES'
function GOCPickWXShareRewardRES:ctor(serverId, callback)
    self.super.ctor(self, GOCPickWXShareRewardRES.OP_CODE, serverId, callback)
end

-- 破产补助同步
local GOCBrokenHelpSYN = class("GOCBrokenHelpSYN", ProtocolBase)
ns.GOCBrokenHelpSYN = GOCBrokenHelpSYN
GOCBrokenHelpSYN.OP_CODE = net.ProtocolCode.P_GO_C_BROKEN_HELP_SYN
GOCBrokenHelpSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCBrokenHelpSYN'
function GOCBrokenHelpSYN:ctor(serverId, callback)
    self.super.ctor(self, GOCBrokenHelpSYN.OP_CODE, serverId, callback)
end

-- 兑换金币同步 兑换类型（1：金币不足，2：升级礼包，3：转运礼包）
local GOCConvertGoldCoinSYN = class("GOCConvertGoldCoinSYN", ProtocolBase)
ns.GOCConvertGoldCoinSYN = GOCConvertGoldCoinSYN
GOCConvertGoldCoinSYN.OP_CODE = net.ProtocolCode.P_GO_C_CONVERT_GOLD_COIN_SYN
GOCConvertGoldCoinSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCConvertGoldCoinSYN'
function GOCConvertGoldCoinSYN:ctor(serverId, callback)
    self.super.ctor(self, GOCConvertGoldCoinSYN.OP_CODE, serverId, callback)
end

-- 兑换金币请求（用于快速兑换)
local CGOConvertGoldCoinREQ = class("CGOConvertGoldCoinREQ", ProtocolBase)
ns.CGOConvertGoldCoinREQ = CGOConvertGoldCoinREQ
CGOConvertGoldCoinREQ.OP_CODE = net.ProtocolCode.P_C_GO_CONVERT_GOLD_COIN_REQ
CGOConvertGoldCoinREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOConvertGoldCoinREQ'
function CGOConvertGoldCoinREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOConvertGoldCoinREQ.OP_CODE, serverId, callback)
end

function CGOConvertGoldCoinREQ:setData(goodsId, type)
    local buffer = self:getProtocolBuf()
    buffer.goodsId = goodsId
    buffer.type = type
end

-- 兑换金币响应（用于快速兑换)
local GOCConvertGoldCoinRES = class("GOCConvertGoldCoinRES", ProtocolBase)
ns.GOCConvertGoldCoinRES = GOCConvertGoldCoinRES
GOCConvertGoldCoinRES.OP_CODE = net.ProtocolCode.P_GO_C_CONVERT_GOLD_COIN_RES
GOCConvertGoldCoinRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCConvertGoldCoinRES'
function GOCConvertGoldCoinRES:ctor(serverId, callback)
    self.super.ctor(self, GOCConvertGoldCoinRES.OP_CODE, serverId, callback)
end

-- 快速充值，充值成功后的服务器响应，可能会被客户端忽略掉（因为在后台）
local GOCConvertGoldCoinResultSYN = class("GOCConvertGoldCoinResultSYN", ProtocolBase)
ns.GOCConvertGoldCoinResultSYN = GOCConvertGoldCoinResultSYN
GOCConvertGoldCoinResultSYN.OP_CODE = net.ProtocolCode.P_GO_C_CONVERT_GOLD_COIN_RESULT_SYN
GOCConvertGoldCoinResultSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCConvertGoldCoinResultSYN'
function GOCConvertGoldCoinResultSYN:ctor(serverId, callback)
    self.super.ctor(self, GOCConvertGoldCoinResultSYN.OP_CODE, serverId, callback)
end

-- client 向 gold 请求查询玩家所在的金币场场次
local CGOQueryRoleRoomGradeREQ = class("CGOQueryRoleRoomGradeREQ", ProtocolBase)
ns.CGOQueryRoleRoomGradeREQ = CGOQueryRoleRoomGradeREQ
CGOQueryRoleRoomGradeREQ.OP_CODE = net.ProtocolCode.P_C_GO_QUERY_ROLE_ROOM_GRADE_REQ
CGOQueryRoleRoomGradeREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOQueryRoleRoomGradeREQ'
function CGOQueryRoleRoomGradeREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOQueryRoleRoomGradeREQ.OP_CODE, serverId, callback)
end

-- gold 向 client 返回玩家所在的金币场场次
local GOCQueryRoleRoomGradeRES = class("GOCQueryRoleRoomGradeRES", ProtocolBase)
ns.GOCQueryRoleRoomGradeRES = GOCQueryRoleRoomGradeRES
GOCQueryRoleRoomGradeRES.OP_CODE = net.ProtocolCode.P_GO_C_QUERY_ROLE_ROOM_GRADE_RES
GOCQueryRoleRoomGradeRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCQueryRoleRoomGradeRES'
GOCQueryRoleRoomGradeRES.SUCCESS_CODE = net.ProtocolCode.GO_C_QUERY_ROLE_ROOM_GRADE_SUCCESS
function GOCQueryRoleRoomGradeRES:ctor(serverId, callback)
    self.super.ctor(self, GOCQueryRoleRoomGradeRES.OP_CODE, serverId, callback)
end 

---------------
-- 金币场竞猜 --
---------------

-- gold 向 client 推送猜金币活动状态
local GOCNotifyGoldGambleInfoSYN = class("GOCNotifyGoldGambleInfoSYN", ProtocolBase)
ns.GOCNotifyGoldGambleInfoSYN = GOCNotifyGoldGambleInfoSYN
GOCNotifyGoldGambleInfoSYN.OP_CODE = net.ProtocolCode.P_GO_C_NOTIFY_GOLD_GAMBLE_INFO_SYN
GOCNotifyGoldGambleInfoSYN.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCNotifyGoldGambleInfoSYN'
function GOCNotifyGoldGambleInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, GOCNotifyGoldGambleInfoSYN.OP_CODE, serverId, callback)
end

-- client 向 gold 请求金币场赌注信息
local CGOQueryGoldGambleInfoREQ = class("CGOQueryGoldGambleInfoREQ", ProtocolBase)
ns.CGOQueryGoldGambleInfoREQ = CGOQueryGoldGambleInfoREQ
CGOQueryGoldGambleInfoREQ.OP_CODE = net.ProtocolCode.P_C_GO_QUERY_GOLD_GAMBLE_INFO_REQ
CGOQueryGoldGambleInfoREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOQueryGoldGambleInfoREQ'
function CGOQueryGoldGambleInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOQueryGoldGambleInfoREQ.OP_CODE, serverId, callback)
end

-- gold 向 client 返回金币场赌注信息
local GOCQueryGoldGambleInfoRES = class("GOCQueryGoldGambleInfoRES", ProtocolBase)
ns.GOCQueryGoldGambleInfoRES = GOCQueryGoldGambleInfoRES
GOCQueryGoldGambleInfoRES.OP_CODE = net.ProtocolCode.P_GO_C_QUERY_GOLD_GAMBLE_INFO_RES
GOCQueryGoldGambleInfoRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCQueryGoldGambleInfoRES'
GOCQueryGoldGambleInfoRES.SUCCESS_CODE = net.ProtocolCode.GO_C_QUERY_GOLD_GAMBLE_INFO_SUCCESS
function GOCQueryGoldGambleInfoRES:ctor(serverId, callback)
    self.super.ctor(self, GOCQueryGoldGambleInfoRES.OP_CODE, serverId, callback)
end

-- client 向 gold 请求选择下注
local CGOSelectGoldGambleREQ = class("CGOSelectGoldGambleREQ", ProtocolBase)
ns.CGOSelectGoldGambleREQ = CGOSelectGoldGambleREQ
CGOSelectGoldGambleREQ.OP_CODE = net.ProtocolCode.P_C_GO_SELECT_GOLD_GAMBLE_REQ
CGOSelectGoldGambleREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOSelectGoldGambleREQ'
function CGOSelectGoldGambleREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOSelectGoldGambleREQ.OP_CODE, serverId, callback)
end

-- gold 向 client 应答下注结果
local GOCSelectGoldGambleRES = class("GOCSelectGoldGambleRES", ProtocolBase)
ns.GOCSelectGoldGambleRES = GOCSelectGoldGambleRES
GOCSelectGoldGambleRES.OP_CODE = net.ProtocolCode.P_GO_C_SELECT_GOLD_GAMBLE_RES
GOCSelectGoldGambleRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCSelectGoldGambleRES'
GOCSelectGoldGambleRES.SUCCESS_CODE = net.ProtocolCode.GO_C_SELECT_GOLD_GAMBLE_SUCCESS
function GOCSelectGoldGambleRES:ctor(serverId, callback)
    self.super.ctor(self, GOCSelectGoldGambleRES.OP_CODE, serverId, callback)
end

-- client 向 gold 请求撤销下局赌注
local CGOCancelGoldGambleREQ = class("CGOCancelGoldGambleREQ", ProtocolBase)
ns.CGOCancelGoldGambleREQ = CGOCancelGoldGambleREQ
CGOCancelGoldGambleREQ.OP_CODE = net.ProtocolCode.P_C_GO_CANCEL_GOLD_GAMBLE_REQ
CGOCancelGoldGambleREQ.CLZ_CODE = 'com.kodgames.message.proto.gold.CGOCancelGoldGambleREQ'
function CGOCancelGoldGambleREQ:ctor(serverId, callback)
    self.super.ctor(self, CGOCancelGoldGambleREQ.OP_CODE, serverId, callback)
end

-- gold 向 client 应答撤销赌注的结果
local GOCCancelGoldGambleRES = class("GOCCancelGoldGambleRES", ProtocolBase)
ns.GOCCancelGoldGambleRES = GOCCancelGoldGambleRES
GOCCancelGoldGambleRES.OP_CODE = net.ProtocolCode.P_GO_C_CANCEL_GOLD_GAMBLE_RES
GOCCancelGoldGambleRES.CLZ_CODE = 'com.kodgames.message.proto.gold.GOCCancelGoldGambleRES'
GOCCancelGoldGambleRES.SUCCESS_CODE = net.ProtocolCode.GO_C_CANCEL_GOLD_GAMBLE_SUCCESS
function GOCCancelGoldGambleRES:ctor(serverId, callback)
    self.super.ctor(self, GOCCancelGoldGambleRES.OP_CODE, serverId, callback)
end

