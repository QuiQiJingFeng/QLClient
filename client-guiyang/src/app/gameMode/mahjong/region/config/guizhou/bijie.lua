local CommandCenter = require("app.manager.CommandCenter")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local room = require("app.game.ui.RoomSettingDefine")
local RoomSetting = config.GlobalConfig.getRoomSetting()

local utils = require("app.gameMode.mahjong.region.config.AreaCfgUtils")

-- 子玩法
local GamePlay_BiJie = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_BiJie")

local BIJIE = {}

local _gameType = {
	name = "毕节麻将",
    gameTypes = {
        {
            id = "GAME_TYPE_R_BIJIE",
            name = "毕节麻将",
            destopSkin = "gaming/z_bjmj.png",
			isNew = false,
        },
    },
    -- 微信号
    weChat = "xymjkf666",
	-- 能否分享战绩
    shareRecord = false,
	clubHelpTxt = [[1、玩家可联系麻友圈代理为自己创建亲友圈与充值亲友圈卡，成为亲友圈群主。
2、其他玩家加入亲友圈后，打牌自动扣除群主身上的亲友圈卡，无需再为玩家充值。
3、在亲友圈内玩家创建房间，只有同一亲友圈内的玩家才可加入。
4、玩家可以快捷加入同一亲友圈玩家创建的房间。
5、玩家可自由查询在亲友圈中的战绩，包括赢家信息和最终成绩。
如需创建亲友圈及购买亲友圈房卡，请联系“麻友圈”代理。如有疑问，请联系客服微信mayouquan009，及微信公众号myqhd2017。]]
}

BIJIE.gameType = _gameType

-- 亲友圈禁用玩法
local _registForbidPlay = {
   	{name = "本鸡",       gamePlayId = RoomSetting.GamePlay.CHICKEN_BENJI,     ruleSetName = "GAME_PLAY_CHICKEN_BENJI"},
    {name = "乌骨鸡",     gamePlayId = RoomSetting.GamePlay.CHICKEN_WUGU,      ruleSetName = "GAME_PLAY_CHICKEN_WUGU" },
    {name = "摇摆鸡",     gamePlayId = RoomSetting.GamePlay.CHICKEN_SWING,  ruleSetName = "GAME_PLAY_CHICKEN_SWING"},
}

BIJIE.registForbidPlay = _registForbidPlay

-- 地区玩法
local _registRuleType = {
     --/** 毕节玩法 */
    GAME_TYPE_R_BIJIE = {RoomSetting.GamePlay.REGION_BIJIE, "毕节麻将", "type", "bijie"},

    --/** 房间8局 */
    ROOM_ROUND_COUNT_8 = {1, "8局", "roundCount", "8j"},
    --/** 房间16局 */
    ROOM_ROUND_COUNT_16 = {2, "16局", "roundCount", "16j"},

    --/*四人局*/
    GAME_PLAY_PLAYER_FOUR = {RoomSetting.GamePlay.PLAYER_FOUR, "四人局", "rule", "sirj"},
    --/**三人局*/
    GAME_PLAY_PLAYER_THREE = {RoomSetting.GamePlay.PLAYER_THREE, "三丁拐", "rule", "sanrj"},
    --/*二人局*/
    GAME_PLAY_PLAYER_TWO = {RoomSetting.GamePlay.PLAYER_TWO, "二丁拐", "rule", "errj"},

    --/*摇摆鸡*/
    GAME_PLAY_CHICKEN_SWING = {RoomSetting.GamePlay.CHICKEN_SWING, "摇摆鸡", "rule", "ybj"},
    --/**本鸡*/
    GAME_PLAY_CHICKEN_BENJI = {RoomSetting.GamePlay.CHICKEN_BENJI, "本鸡", "rule", "benj"},
    --/**乌骨鸡*/
    GAME_PLAY_CHICKEN_WUGU = {RoomSetting.GamePlay.CHICKEN_WUGU, "乌骨鸡", "rule", "wugj"},
    --/**红中*/
    GAME_PLAY_CHICKEN_HONGZHONG = {RoomSetting.GamePlay.CHICKEN_HONGZHONG, "红中", "rule", "dil"},

    --/**连庄*/
    GAME_PLAY_BANKER_SERIES = {RoomSetting.GamePlay.BANKER_SERIES, "连庄", "rule", "lianzh"},
  
    -- 实时语音开
    GAME_PLAY_COMMON_VOICE_OPEN = {RoomSetting.GamePlay.COMMON_VOICE_OPEN, "实时语音", "rule", "yuyk"},
    -- 实时语音关
    GAME_PLAY_COMMON_VOICE_CLOSE = {RoomSetting.GamePlay.COMMON_VOICE_CLOSE, "", "rule", "yuyg"},

    -- 听牌提示开
    GAME_PLAY_COMMON_TING_TIPS_OPEN = {RoomSetting.GamePlay.COMMON_TING_TIPS_OPEN, "听牌提示", "rule", "yuyk"},
    -- 听牌提示关
    GAME_PLAY_COMMON_TING_TIPS_CLOSE = {RoomSetting.GamePlay.COMMON_TING_TIPS_CLOSE, "", "rule", "yuyg"},

    -- 极速模式
    GAME_PLAY_JI_SU = {RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN, "极速模式", "rule", "jsms"},
}


BIJIE.registRuleType = _registRuleType

local gameplays = {
    ["GAME_TYPE_R_BIJIE"] = GamePlay_BiJie,
}
-- setfenv(utils.addGamePlays, {_G = GUIYANG, _g = _G})
utils.addGamePlays(BIJIE, gameplays)

return BIJIE