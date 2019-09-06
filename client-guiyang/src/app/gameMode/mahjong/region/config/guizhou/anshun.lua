local CommandCenter = require("app.manager.CommandCenter")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local room = require("app.game.ui.RoomSettingDefine")
local RoomSetting = config.GlobalConfig.getRoomSetting()

local utils = require("app.gameMode.mahjong.region.config.AreaCfgUtils")

-- 子玩法
local GamePlay_AnShun = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_AnShun")
local GamePlay_GuiYang = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_GuiYang")

local ANSHUN = {}

local _gameType = {
	name = "贵阳麻将",
	gameTypes = {
		{
			id = "GAME_TYPE_R_GUIYANG",
			name = "贵阳麻将",
            destopSkin = "gaming/z_gyzj.png",
			isNew = false,
		},
		{
			id = "GAME_TYPE_R_ANSHUN",
			name = "安顺麻将",
            destopSkin = "gaming/z_asmj.png",
			isNew = false,
		},
	},
	-- 微信号
    weChat = "szkf1000",
	-- 能否分享战绩
    shareRecord = false,
	clubHelpTxt = [[1、玩家可联系麻友圈代理为自己创建亲友圈与充值亲友圈卡，成为亲友圈群主。
2、其他玩家加入亲友圈后，打牌自动扣除群主身上的亲友圈卡，无需再为玩家充值。
3、在亲友圈内玩家创建房间，只有同一亲友圈内的玩家才可加入。
4、玩家可以快捷加入同一亲友圈玩家创建的房间。
5、玩家可自由查询在亲友圈中的战绩，包括赢家信息和最终成绩。
如需创建亲友圈及购买亲友圈房卡，请联系“麻友圈”代理。如有疑问，请联系客服微信szkf1000。]]
}

ANSHUN.gameType = _gameType

-- 亲友圈禁用玩法
local _registForbidPlay = {
   	{name = "吹风鸡",         gamePlayId = RoomSetting.GamePlay.CHICKEN_CHUIFENG,     ruleSetName = "GAME_PLAY_CHICKEN_CHUIFENG"},
    {name = "连庄",           gamePlayId = RoomSetting.GamePlay.BANKER_SERIES,      ruleSetName = "GAME_PLAY_BANKER_SERIES" },
    {name = "定缺",           gamePlayId = RoomSetting.GamePlay.DINGQUE,  ruleSetName = "GAME_PLAY_LACK"},
    {name = "抢杠烧鸡",       gamePlayId = RoomSetting.GamePlay.CHICKEN_QGSJ,  ruleSetName = "GAME_PLAY_QGSJ"},
    {name = "抢杠烧豆",       gamePlayId = RoomSetting.GamePlay.QIANGGANGSHAODOU,  ruleSetName = "GAME_PLAY_QGSD"},
}

ANSHUN.registForbidPlay = _registForbidPlay

-- 地区玩法
local _registRuleType = {
    -- /** 贵阳玩法 */
    GAME_TYPE_R_GUIYANG= {RoomSetting.GamePlay.REGION_GUIYANG, "贵阳麻将", "type", "guiyang"},
    --/** 安顺玩法 */
    GAME_TYPE_R_ANSHUN = {RoomSetting.GamePlay.REGION_ANSHUN, "安顺麻将", "type", "anshun"},

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

    --/**翻牌鸡*/
    GAME_PLAY_CHICKEN_FLOP = {RoomSetting.GamePlay.CHICKEN_FLOP, "翻牌鸡", "rule", "fpj"},
    --/*摇摆鸡*/
    GAME_PLAY_CHICKEN_SWING = {RoomSetting.GamePlay.CHICKEN_SWING, "摇摆鸡", "rule", "ybj"},

    --/**本鸡*/
    GAME_PLAY_CHICKEN_BENJI = {RoomSetting.GamePlay.CHICKEN_BENJI, "本鸡", "rule", "benj"},
    --/**乌骨鸡*/
    GAME_PLAY_CHICKEN_WUGU = {RoomSetting.GamePlay.CHICKEN_WUGU, "乌骨鸡", "rule", "wugj"},
    --/**吹风鸡 */
    GAME_PLAY_CHICKEN_CHUIFENG = {RoomSetting.GamePlay.CHICKEN_CHUIFENG, "吹风鸡", "rule", "chufj"},
    --/**两房*/
    GAME_PLAY_CHICKEN_LIANGFANG = {RoomSetting.GamePlay.LIANGFANG, "两房", "rule", "liangf"},
    --/**星期鸡*/
    GAME_PLAY_CHICKEN_XINQQI = {RoomSetting.GamePlay.CHICKEN_XINQQI, "星期鸡", "rule", "xingqj"},
    --/**地龙*/
     GAME_PLAY_CHICKEN_DILONG = {RoomSetting.GamePlay.DILONG, "地龙", "rule", "dil"},

   --/**一扣二 */
    GAME_PLAY_BANKER_ONE = {RoomSetting.GamePlay.BANKER_ONE, "一扣二", "rule", "yike"},
    --/**连庄*/
    GAME_PLAY_BANKER_SERIES = {RoomSetting.GamePlay.BANKER_SERIES, "连庄", "rule", "lianzh"},
    --/**通三*/
    GAME_PLAY_BANKER_TONGSAN = {RoomSetting.GamePlay.BANKER_TONGSAN, "通三", "rule", "tongs"},

    -- 实时语音开
    GAME_PLAY_COMMON_VOICE_OPEN = {RoomSetting.GamePlay.COMMON_VOICE_OPEN, "实时语音", "rule", "yuyk"},
    -- 实时语音关
    GAME_PLAY_COMMON_VOICE_CLOSE = {RoomSetting.GamePlay.COMMON_VOICE_CLOSE, "", "rule", "yuyg"},

    -- 听牌提示开
    GAME_PLAY_COMMON_TING_TIPS_OPEN = {RoomSetting.GamePlay.COMMON_TING_TIPS_OPEN, "听牌提示", "rule", "yuyk"},
    -- 听牌提示关
    GAME_PLAY_COMMON_TING_TIPS_CLOSE = {RoomSetting.GamePlay.COMMON_TING_TIPS_CLOSE, "", "rule", "yuyg"},

    --/**满堂鸡*/
    GAME_PLAY_CHICKEN_MANTANGJI = {RoomSetting.GamePlay.CHECKEN_MANTANG,   "满堂鸡", "rule", "mtj"},
    --/**抢杠烧鸡*/
    GAME_PLAY_QGSJ = {RoomSetting.GamePlay.CHICKEN_QGSJ, "抢杠烧鸡", "rule", "qgsj"},
    --/**定缺*/
    GAME_PLAY_LACK = {RoomSetting.GamePlay.DINGQUE,     "定缺", "rule", "dingque"},
    --/**抢杠烧豆*/
    GAME_PLAY_QGSD = {RoomSetting.GamePlay.QIANGGANGSHAODOU, "抢杠烧豆", "rule", "qgsd"},

    -- 极速模式
    GAME_PLAY_JI_SU = {RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN, "极速模式", "rule", "jsms"},
}


ANSHUN.registRuleType = _registRuleType

local gameplays = {
	["GAME_TYPE_R_GUIYANG"] = GamePlay_GuiYang,
	["GAME_TYPE_R_ANSHUN"] = GamePlay_AnShun,
}
-- setfenv(utils.addGamePlays, {_G = GUIYANG, _g = _G})
utils.addGamePlays(ANSHUN, gameplays)

return ANSHUN 