local base = require("app.gameMode.base.core.Constants_Base")
local mahjhongConstant = require("app.gameMode.mahjong.core.Constants")
local Constants = class("Constants_Paodekuai", base)
local POKER_PAO_DE_KUAI_START=1048786
Constants.PlayType = {
    DISTORY_FINISH_ROOM = -3,  --FYD 中途解散房间
    -- /** 过(不出、要不起) */
    POKER_OPERATE_CAN_PASS=1048787,
    POKER_OPERATE_PASS=1048788,
    -- /** 可以出牌 */
    POKER_OPERATE_CAN_PLAY_A_CARD=1048789,
    POKER_OPERATE_PLAY_A_CARD=1048790,
    -- /** 上次出牌类型 */
    POKER_OPERATE_LAST_PLAY_A_CARD=1048791,
    -- /** 上次出牌人 */
    POKER_OPERATE_LAST_PLAYER=1048792,
    -- 自动过牌
    POKER_OPERATE_AUTO_PASS=1048793,

    POKER_DISPLAY_PAI_DAN_ZHANG=1049886,
    POKER_DISPLAY_PAI_DUI_PAI=1049887,
    POKER_DISPLAY_PAI_SAN_PAI=1049888,
    POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG=1049889,
    POKER_DISPLAY_PAI_SAN_DAI_1_DUI=1049890,
    POKER_DISPLAY_PAI_SHUNZI=1049891,
    POKER_DISPLAY_PAI_SHUANG_SHUNZI=1049892,
    POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG=1049894,
    POKER_DISPLAY_PAI_ZHADAN=1049896,
    -- /** Poker 开启托管 */
    POKER_DISPLAY_HOSTING_OPEN=1049898,
    -- /** Poker 取消托管 */
    POKER_DISPLAY_HOSTING_CANCEL=1049899,
    POKER_DISPLAY_PLAY_ANIM=1049900,
    POKER_DISPLAY_WIN=1049908,
    POKER_DISPLAY_FAIL=1049909,
    -- /** Poker 剩余牌警告 */
    POKER_DISPLAY_HANDCARD_WARN=1049912,

    POKER_DISPLAY_ZHADAN_SCORE=1049936,
    POKER_DISPLAY_HAND_SCORE=1049937,
    POKER_DISPLAY_QUAN_GUAN_JIA_BEI_SCORE=1049938,
    POKER_DISPLAY_HAND_CARD_SIZE=1049913,
    HU_POKER_WIN  = 1617,
    HU_POKER_GUAN_MEN = 1618,
}

Constants.SFX_OpKey = 
{
    
}

-- 没想到牌类的分开来了。。。基于目前结构，它和麻将用同一个动销map
Constants.EffectMap = mahjhongConstant.EffectMap

Constants.SFXCONFIG =
{
    [3] = "one_3.mp3", -- 3
    [4] = "one_4.mp3", -- 4
    [5] = "one_5.mp3", -- 5
    [6] = "one_6.mp3", -- 6
    [7] = "one_7.mp3", -- 7
    [8] = "one_8.mp3", -- 8
    [9] = "one_9.mp3", -- 9
    [10] = "one_10.mp3", -- 10
    [11] = "one_11.mp3", -- J
    [12] = "one_12.mp3", -- Q
    [13] = "one_13.mp3", -- K
    [14] = "one_14.mp3", -- A
    [16] = "one_15.mp3", -- 2

    -- 对牌
    [3 * 14] = "double_3.mp3", -- 3
    [4 * 14] = "double_4.mp3", -- 4
    [5 * 14] = "double_5.mp3", -- 5
    [6 * 14] = "double_6.mp3", -- 6
    [7 * 14] = "double_7.mp3", -- 7
    [8 * 14] = "double_8.mp3", -- 8
    [9 * 14] = "double_9.mp3", -- 9
    [10 * 14] = "double_10.mp3", -- 10
    [11 * 14] = "double_11.mp3", -- J
    [12 * 14] = "double_12.mp3", -- Q
    [13 * 14] = "double_13.mp3", -- K
    [14 * 14] = "double_14.mp3", -- A
    [16 * 14] = "double_15.mp3", -- 2

    -- -- 三张
    -- [Constants.PlayType.POKER_DISPLAY_PAI_SAN_PAI] = {},
    -- -- 三带一
    -- [Constants.PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG] = {},
    -- -- 三带一对
    -- [Constants.PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_DUI] = {},
    -- -- 顺子
    -- [Constants.PlayType.POKER_DISPLAY_PAI_SHUNZI] = {},
    -- [Constants.PlayType.POKER_DISPLAY_PAI_SHUANG_SHUNZI] = {}
    -- -- 飞机
    -- [Constants.PlayType.POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG] = {},
    -- -- 炸弹
    -- [Constants.PlayType.POKER_DISPLAY_PAI_ZHADAN] = {}
    -- -- 剩一张
    -- [Constants.PlayType.POKER_DISPLAY_HANDCARD_WARN] = {}
    -- -- 不要
    -- [Constants.PlayType.POKER_OPERATE_PASS] = {}
    -- -- 过
    -- -- [Constants.PlayType.POKER_OPERATE_PASS]
}

-- POKER_DISPLAY_PAI_DAN_ZHANG
-- POKER_DISPLAY_PAI_DUI_PAI
-- POKER_DISPLAY_PAI_SAN_PAI
-- POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG
-- POKER_DISPLAY_PAI_SAN_DAI_1_DUI
-- POKER_DISPLAY_PAI_SHUNZI
-- POKER_DISPLAY_PAI_SHUANG_SHUNZI
-- POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG
-- POKER_DISPLAY_PAI_ZHADAN
-- POKER_DISPLAY_HANDCARD_WARN
setmetatable(Constants.PlayType, {__index = base.PlayType})
return Constants