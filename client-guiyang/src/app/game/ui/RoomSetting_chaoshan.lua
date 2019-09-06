local room = require("app.game.ui.RoomSettingDefine")
local CONST_LSHIFT_1 = bit.lshift(1, 16)
local CONST_LSHIFT_2 = bit.lshift(2, 16)
local CONST_LSHIFT_3 = bit.lshift(3, 16)
local CONST_LSHIFT_4 = bit.lshift(4, 16)
local CONST_LSHIFT_5 = bit.lshift(5, 16)
local CONST_LSHIFT_6 = bit.lshift(6, 16)
local CONST_LSHIFT_7 = bit.lshift(7, 16)
local CONST_LSHIFT_8 = bit.lshift(8, 16)
local CONST_LSHIFT_9 = bit.lshift(9, 16)
local CONST_LSHIFT_10 = bit.lshift(10, 16)
local CONST_LSHIFT_11 = bit.lshift(11, 16)
local CONST_LSHIFT_12 = bit.lshift(12, 16)
local CONST_LSHIFT_13 = bit.lshift(13, 16)
local CONST_LSHIFT_14 = bit.lshift(14, 16)
local CONST_LSHIFT_15 = bit.lshift(15, 16)
local CONST_LSHIFT_16 = bit.lshift(16, 16)
local CONST_LSHIFT_17 = bit.lshift(17, 16)

local CreateRoomSettings = class("CreateRoomSettings")
function CreateRoomSettings:ctor()
    self._gameType = ""
    self._ruleMap = {}
end

local RoomSetting = {
}
RoomSetting.CreateRoomSettingsClass = CreateRoomSettings

RoomSetting.ROOM_ROUND_SETTING = {
    --/** true为局数， false为圈数 */
	room.RoomRoundSetting.new("ROOM_ROUND_COUNT_4", false, 1, 4),
	room.RoomRoundSetting.new("ROOM_ROUND_COUNT_8", false, 2, 8),
	room.RoomRoundSetting.new("ROOM_ROUND_COUNT_16", false, 3, 16),
}

RoomSetting.GamePlay = {
    -- /** 规则掩码 */
    RULE_MASK = 4294901760,
    -- /** 参数掩码 */
    ARGS_MASK = 65535,

    -- 实时语音开
    -- COMMON_VOICE_OPEN = CONST_LSHIFT_1 - 1,
    -- -- 实时语音关
    -- COMMON_VOICE_CLOSE = CONST_LSHIFT_1 - 2,

    -- 听牌提示开
    COMMON_TING_TIPS_OPEN = CONST_LSHIFT_1 - 3,
    -- 听牌提示关
    COMMON_TING_TIPS_CLOSE = CONST_LSHIFT_1 - 4,
    
    -- 跑得快规则
    POKER_GAME_TYPE_PAO_DE_KUAI = 65545,
    PLAYER_NUM_2 = 720897,
    PLAYER_NUM_3 = 720898,
    -- 黑桃3先出
    FIRST_DEAL_CARD_HEI_TAO_3 = 786433,
    -- 胜者先出
    FIRST_DEAL_CARD_WINNER = 786434,
    -- 随机先出
    FIRST_DEAL_CARD_RANDOM = 786435,
    -- 全关加倍
    GAME_PLAY_QUAN_GUAN_JIA_BEI = 851969,
    -- 有牌比压
    GAME_PLAY_YOU_PAI_BI_YA = 851970,
    -- 报单必定
    GAME_PLAY_BAO_DAN_BI_DING = 851971,
    --争上游规则
    POKER_GAME_TYPE_ZHENGSHANGYOU = 65547,
    --三人或四人 三人和跑得快一样
    PLAYER_NUM_2 = 917505,
    PLAYER_NUM_3 = 917506,
    PLAYER_NUM_4 = 917507,

    --一分，二分，三分，五分，十分
    BOTTOM_SCORE_ONE = 1245185,
    BOTTOM_SCORE_TWO = 1245186,
    BOTTOM_SCORE_THREE = 1245187,
    BOTTOM_SCORE_FIVE = 1245188,
    BOTTOM_SCORE_TEN = 1245189,

    --上限无封顶，3炸，4炸，5炸
    UP_LIMIT_NO_CAPPING = 1179649,
    UP_LIMIT_THREE_BOMB = 1179650,
    UP_LIMIT_FOUE_BOMB = 1179651,
    UP_LIMIT_FIVE_BOMB = 1179652,
}

RoomSetting.GAME_TYPE_SETTING = {}

--潮汕好友圈貌似没有规则限制这一说
RoomSetting.RULES_NOT_TO_SHOW = {
-- "GAME_PLAY_COMMON_VOICE_OPEN",
-- "GAME_PLAY_COMMON_VOICE_CLOSE",
}

-- 这里不用了，后期会删掉
-- RoomSetting.RECORD_GAMETYPE = {
--     [bit.bxor(CONST_LSHIFT_1, 1)] = "GAME_TYPE_CHAO_SHAN",
--     [bit.bxor(CONST_LSHIFT_1, 3)] = "GAME_TYPE_GUI_CHAO_SHAN",
--     [bit.bxor(CONST_LSHIFT_1, 4)] = "GAME_TYPE_CHAO_ZHOU",
--     [bit.bxor(CONST_LSHIFT_1, 6)] = "GAME_TYPE_SHAN_TOU",
--     [bit.bxor(CONST_LSHIFT_1, 7)] = "GAME_TYPE_PU_NING",
--     [bit.bxor(CONST_LSHIFT_1, 8)] = "GAME_TYPE_HUI_LAI",
--     [65547] = "GAME_TYPE_ZHENGSHANGYOU",
-- }

-- 映射规则与人数关系（用于好友圈私密房间）
-- RoomSetting.MAP_PLAYER_COUNT = 
-- {
--     [RoomSetting.GamePlay.PLAYER_NUM_2] = 2,
--     [RoomSetting.GamePlay.PLAYER_NUM_3] = 3,
--     [RoomSetting.GamePlay.PLAYER_FOUR] = 4,
--     [RoomSetting.GamePlay.PLAYER_THREE] = 3,
--     [RoomSetting.GamePlay.PLAYER_TWO] = 2,
-- }

RoomSetting.CLUB_ROOM_INFO_SHOW_START_INDEX = 1

return RoomSetting