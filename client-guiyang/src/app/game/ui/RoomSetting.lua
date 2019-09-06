local room = require( "app.game.ui.RoomSettingDefine" )
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
    room.RoomRoundSetting.new("ROOM_ROUND_COUNT_8", false, 1, 8),
    room.RoomRoundSetting.new("ROOM_ROUND_COUNT_16", false, 2, 16),
}

RoomSetting.GamePlay = {
    -- /** 规则掩码 */
    RULE_MASK = 0xFFFF0000,
    -- /** 参数掩码 */
    ARGS_MASK = 0x0000FFFF,

    -- /** 子地区：贵阳 */
    REGION_GUIYANG = bit.bxor(CONST_LSHIFT_1, 1),
    -- /** 子地区：遵义 */
    REGION_ZUNYI = bit.bxor(CONST_LSHIFT_1, 2),
    -- /** 子地区：贵阳安顺 */
    REGION_ANSHUN_GUIYANG = bit.bxor(CONST_LSHIFT_1, 3),
     -- /** 子地区：安顺 */
    REGION_ANSHUN = bit.bxor(CONST_LSHIFT_1, 8),
    -- /** 子地区：安龙 */
    REGION_ANLONG = bit.bxor(CONST_LSHIFT_1, 6),
    -- /** 子地区：贞丰 */
    REGION_ZHENFENG = bit.bxor(CONST_LSHIFT_1, 7),
     -- /** 子地区：兴义 */
    REGION_XINGYI = bit.bxor(CONST_LSHIFT_1, 5),
    -- /** 子地区：毕节 */
    REGION_BIJIE = bit.bxor(CONST_LSHIFT_1, 4),
    -- 铜仁
    REGION_TONGREN = bit.bxor(CONST_LSHIFT_1, 10),
     -- 两房
    REGION_LIANGFANG = bit.bxor(CONST_LSHIFT_1, 11),
    -- 两丁一房
    REGION_LIANGDING = bit.bxor(CONST_LSHIFT_1, 12),
    -- 四人房
    PLAYER_FOUR = bit.bxor(CONST_LSHIFT_2, 1),
    -- 三人房
    PLAYER_THREE = bit.bxor(CONST_LSHIFT_2, 2),
    -- 二人房
    PLAYER_TWO = bit.bxor(CONST_LSHIFT_2, 3),

    -- 翻牌鸡
    CHICKEN_FLOP = bit.bxor(CONST_LSHIFT_3, 1),
    -- 摇摆鸡
    CHICKEN_SWING = bit.bxor(CONST_LSHIFT_3, 2),

    -- 本鸡
    CHICKEN_BENJI = bit.bxor(CONST_LSHIFT_4, 1),
    -- 乌骨鸡
    CHICKEN_WUGU = bit.bxor(CONST_LSHIFT_4, 2),
    -- 吹风鸡
    CHICKEN_CHUIFENG = bit.bxor(CONST_LSHIFT_4, 3),
    -- 星期鸡
    CHICKEN_XINQQI = bit.bxor(CONST_LSHIFT_4, 4),
    -- 满堂鸡
    CHECKEN_MANTANG = bit.bxor(CONST_LSHIFT_4, 7),
    -- 首圈鸡
    CHICKEN_SHOUQUAN = bit.bxor(CONST_LSHIFT_4, 8),
    -- 银鸡
    CHECKEN_YIN = bit.bxor(CONST_LSHIFT_4, 9),
    -- 两房
    LIANGFANG = bit.bxor(CONST_LSHIFT_4, 5),
    -- 地龙
    DILONG = bit.bxor(CONST_LSHIFT_4, 6),
    -- 红中玩法
    CHICKEN_HONGZHONG = bit.bxor(CONST_LSHIFT_7, 1),

    -- 一扣二
    BANKER_ONE = bit.bxor(CONST_LSHIFT_5, 1),
    -- 连庄
    BANKER_SERIES = bit.bxor(CONST_LSHIFT_5, 2),
    -- 通三
    BANKER_TONGSAN = bit.bxor(CONST_LSHIFT_5, 3),
    -- 定缺
    DINGQUE = bit.bxor(CONST_LSHIFT_6, 1),
    -- 癞子鸡
    LAIZIJI = bit.bxor(CONST_LSHIFT_4, 10),

    -- 红中做鸡
    CHICKEN_HONGZHONG = bit.bxor(CONST_LSHIFT_7, 1),
    -- 开局翻鸡(星期鸡)
    CHICKEN_OPENING = bit.bxor(CONST_LSHIFT_7, 2),
    -- 估卖
    GAMEPLAY_GUMAI = CONST_LSHIFT_8,
    -- 顺5清10(一扣二)
    COUNTPOINTS_SHUNWUQINGSHI = bit.bxor(CONST_LSHIFT_8, 5),
    -- 顺3清6(通三)
    COUNTPOINTS_SHUNSANQINGLIU = bit.bxor(CONST_LSHIFT_8, 6),

    -- 闷胡
    GAMEPLAY_MENHU = bit.bxor(bit.lshift(9, 16), 1),
    -- 打一张可报听
    GAMEPLAY_TINGCARD = bit.bxor(CONST_LSHIFT_9, 2),
    --小胡必闷
    GAME_PLAY_XIAO_HU_BI_MEN = bit.bxor(CONST_LSHIFT_9, 5),
    -- 连胡
    GAME_PLAY_LIAN_HU =  bit.bxor(CONST_LSHIFT_9, 6),
    --打两张可报听
    GAME_PLAY_TING_SECOND_CARD=589827,
    --默认（闷胡血流玩法）
    GAME_PLAY_NO_TING_CARD=589828,
    -- 抢杠烧鸡
    CHICKEN_QGSJ  = bit.bxor(CONST_LSHIFT_10, 1),
    -- 抢杠烧豆
    QIANGGANGSHAODOU = bit.bxor(CONST_LSHIFT_10, 2),

    -- 实时语音开
    COMMON_VOICE_OPEN = CONST_LSHIFT_1 - 1,
    -- 实时语音关
    COMMON_VOICE_CLOSE = CONST_LSHIFT_1 - 2,

    -- 听牌提示开
    COMMON_TING_TIPS_OPEN = CONST_LSHIFT_1 - 3,
    -- 听牌提示关
    COMMON_TING_TIPS_CLOSE = CONST_LSHIFT_1 - 4,

    -- 极速模式开
    COMMON_FAST_MODE_OPEN = CONST_LSHIFT_1 - 5,
    -- 极速模式关
    COMMON_FAST_MODE_CLOSE = CONST_LSHIFT_1 - 6,

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
    -- 烧鸡烧豆
    GAME_PLAY_SHAO_JI_SHAO_DOU = bit.bxor(CONST_LSHIFT_10, 3),
    -- 包鸡
    GAME_PLAY_BAO_JI = bit.bxor(CONST_LSHIFT_10, 4),
    -- 包豆
    GAME_PLAY_BAO_DOU = bit.bxor(CONST_LSHIFT_10, 5),

    --一扣三
    GAME_PLAY_YIKOUSAN = bit.bxor(CONST_LSHIFT_5, 4),

     -- 热炮必胡
    GAME_PLAY_HOT_PAO_MUST_HU =  458755,

    -- 60秒托管
    COMMON_TRUSTEESHIP_60 = CONST_LSHIFT_1 - 7, 
    -- 180秒托管
    COMMON_TRUSTEESHIP_180 = CONST_LSHIFT_1 - 8,
    -- 300秒托管
    COMMON_TRUSTEESHIP_300 = CONST_LSHIFT_1 - 9,
    -- 托管模式关
    COMMON_TRUSTEESHIP_CLOSE = CONST_LSHIFT_1 - 10,
}

RoomSetting.GAME_TYPE_SETTING = {}

RoomSetting.RULES_NOT_TO_SHOW = {
    "GAME_PLAY_COMMON_VOICE_OPEN",
    "GAME_PLAY_COMMON_VOICE_CLOSE",
}

-- -- 这里不用了，后期会删掉
-- RoomSetting.RECORD_GAMETYPE = {
--     [bit.bxor(CONST_LSHIFT_1, 1)] = "GAME_TYPE_R_GUIYANG",
--     [bit.bxor(CONST_LSHIFT_1, 2)] = "GAME_TYPE_R_ZUNYI",
--     [bit.bxor(CONST_LSHIFT_1, 3)] = "GAME_TYPE_R_ANSHUN_GUIYANG",
--     [bit.bxor(CONST_LSHIFT_1, 4)] = "GAME_TYPE_R_BIJIE",
--     [bit.bxor(CONST_LSHIFT_1, 5)] = "GAME_TYPE_R_XINGYI",
--     [bit.bxor(CONST_LSHIFT_1, 6)] = "GAME_TYPE_R_ANLONG",
--     [bit.bxor(CONST_LSHIFT_1, 7)] = "GAME_TYPE_R_ZHENFENG",
--     [bit.bxor(CONST_LSHIFT_1, 8)] = "GAME_TYPE_R_ANSHUN",
--     [bit.bxor(CONST_LSHIFT_1, 10)] = "GAME_TYPE_R_TONGREN",
--     [bit.bxor(CONST_LSHIFT_1, 11)] = "GAME_TYPE_R_LIANG_FANG",
--     [65545] = "GAME_TYPE_PAODEKUAI",
-- }

-- 映射规则与人数关系（用于亲友圈私密房间）
RoomSetting.MAP_PLAYER_COUNT = 
{
    [RoomSetting.GamePlay.PLAYER_NUM_2] = 2,
    [RoomSetting.GamePlay.PLAYER_NUM_3] = 3,
    [RoomSetting.GamePlay.PLAYER_FOUR] = 4,
    [RoomSetting.GamePlay.PLAYER_THREE] = 3,
    [RoomSetting.GamePlay.PLAYER_TWO] = 2,
}

RoomSetting.CLUB_ROOM_INFO_SHOW_START_INDEX = 4

return RoomSetting