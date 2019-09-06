
local room = require("app.game.ui.RoomSettingDefine")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local Constants = require "app.gameMode.zhengshangyou.core.Constants_ZhengShangYou"

local GamePlay_ZhengShangYou = {}

GamePlay_ZhengShangYou.roomSetting = room.GameTypeSetting.new("GAME_TYPE_ZHENGSHANGYOU",
{
    --/**局数*/
    room.RuleSetting.new("ROOM_ROUND_COUNT_8",
    {
        room.RuleOption.new("ROOM_ROUND_COUNT_8", "", ""),
        room.RuleOption.new("ROOM_ROUND_COUNT_16", "", ""),
    }, true),

    --人数
    room.RuleSetting.new("PLAYER_NUM_4",
    {
        room.RuleOption.new("PLAYER_NUM_4", "", ""),
        room.RuleOption.new("PLAYER_NUM_3", "", "")
    }, true),

    --底分
    room.RuleSetting.new("BOTTOM_SCORE_ONE",
    {
        room.RuleOption.new("BOTTOM_SCORE_ONE", "", ""),
        room.RuleOption.new("BOTTOM_SCORE_TWO", "", ""),
        room.RuleOption.new("BOTTOM_SCORE_THREE", "", ""),
        room.RuleOption.new("BOTTOM_SCORE_FIVE", "", ""),
        room.RuleOption.new("BOTTOM_SCORE_TEN", "", ""),
    }, true),

    --上限
    room.RuleSetting.new("UP_LIMIT_NO_CAPPING",
    {
        room.RuleOption.new("UP_LIMIT_NO_CAPPING", "", ""),
        room.RuleOption.new("UP_LIMIT_THREE_BOMB", "", ""),
        room.RuleOption.new("UP_LIMIT_FOUE_BOMB", "", ""),
        room.RuleOption.new("UP_LIMIT_FIVE_BOMB", "", ""),
    }, true),
})


GamePlay_ZhengShangYou.registRuleType = {
    --争上游规则
    GAME_TYPE_ZHENGSHANGYOU = {RoomSetting.GamePlay.POKER_GAME_TYPE_ZHENGSHANGYOU,"争上游","type","zhengshangyou"},
    ROOM_ROUND_COUNT_8 = {RoomSetting.GamePlay.ROOM_ROUND_COUNT_8, "8局", "roundCount", "8j"},
    ROOM_ROUND_COUNT_16 = {RoomSetting.GamePlay.ROOM_ROUND_COUNT_16, "16局", "roundCount", "16j"},
    PLAYER_NUM_4 = {RoomSetting.GamePlay.PLAYER_NUM_4, "四人局", "rule", "4r"},
    PLAYER_NUM_3 = {RoomSetting.GamePlay.PLAYER_NUM_3, "三人局", "rule", "3r"},
    BOTTOM_SCORE_ONE = {RoomSetting.GamePlay.BOTTOM_SCORE_ONE, "1底分", "rule", "1score"},
    BOTTOM_SCORE_TWO = {RoomSetting.GamePlay.BOTTOM_SCORE_TWO, "2底分", "rule", "2score"},
    BOTTOM_SCORE_THREE = {RoomSetting.GamePlay.BOTTOM_SCORE_THREE, "3底分", "rule", "3score"},
    BOTTOM_SCORE_FIVE = {RoomSetting.GamePlay.BOTTOM_SCORE_FIVE, "5底分", "rule", "5score"},
    BOTTOM_SCORE_TEN = {RoomSetting.GamePlay.BOTTOM_SCORE_TEN, "10底分", "rule", "10score"},
    UP_LIMIT_NO_CAPPING = {RoomSetting.GamePlay.UP_LIMIT_NO_CAPPING, "无上限", "rule", "noLimit"},
    UP_LIMIT_THREE_BOMB = {RoomSetting.GamePlay.UP_LIMIT_THREE_BOMB, "3炸", "rule", "3Bomb"},
    UP_LIMIT_FOUE_BOMB = {RoomSetting.GamePlay.UP_LIMIT_FOUE_BOMB, "4炸", "rule", "4Bomb"},
    UP_LIMIT_FIVE_BOMB = {RoomSetting.GamePlay.UP_LIMIT_FIVE_BOMB, "5炸", "rule", "5Bomb"},
}

GamePlay_ZhengShangYou.commonEvent = {
    [Constants.PlayType.POKER_DISPLAY_ZHADAN_SCORE] = {name = "炸弹", be = "炸弹", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_HAND_SCORE] = {name = "牌数", be = "牌数", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_QUAN_GUAN_JIA_BEI_SCORE] = {name = "关门", be = "关门", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_WIN] = {name = "赢家", be = "赢家", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.HU_POKER_GUAN_MEN] = {name = "关门", be = "关门", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.HU_POKER_WIN] = {name = "取胜", be = "取胜", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_SPRING] = {name = "春天", be = "春天", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_BOTTOM_SCORE] = {name = "底分", be = "底分", skin = "", beskin = "", weight = -1},
}

local commandsBasePath = "app.gameMode.zhengshangyou.region.commands."
GamePlay_ZhengShangYou.commands = {
    [Constants.PlayType.POKER_OPERATE_CAN_PASS] = require(commandsBasePath .. "Command_CanOptions"),
    [Constants.PlayType.POKER_OPERATE_CAN_PLAY_A_CARD] = require(commandsBasePath .. "Command_CanOptions"),
    [Constants.PlayType.POKER_OPERATE_LAST_PLAY_A_CARD] = require(commandsBasePath .. "Command_OperationSYN"),
    [Constants.PlayType.POKER_OPERATE_PASS] = require(commandsBasePath .. "Command_OperationSYN"),
    [Constants.PlayType.DISPLAY_FINISH_ALL] = require(commandsBasePath .. "Command_Display_RoundFinish"),
    [Constants.PlayType.POKER_DISPLAY_HAND_CARD_SIZE] = require(commandsBasePath .. "Command_DisPlay_RemainCard"),
    [Constants.PlayType.POKER_DISPLAY_SPRING] = require(commandsBasePath .. "Command_DisPlay_Spring"),
    [Constants.PlayType.POKER_OPERATE_AUTO_PASS] = require(commandsBasePath .. "Command_AutoPass")
}
GamePlay_ZhengShangYou.UIConfig = {
    UI_GAME_TYPE_ZHENGSHANGYOU = "app.gameMode.zhengshangyou.region.gamePlays.zhengshangyou.UI_GAME_TYPE_ZHENGSHANGYOU",
    UIGameScene_ZhengShangYou = "app.gameMode.zhengshangyou.ui.UIGameScene_ZhengShangYou",
    UICardsInfo_ZhengShangYou = "app.gameMode.zhengshangyou.ui.UICardsInfo_ZhengShangYou"
}

GamePlay_ZhengShangYou.replayCommands = {}

GamePlay_ZhengShangYou.registGameUI = {
	[Constants.GameUIType['UI_GAME_SCENE']] = "GameState_ZhengShangYou"
}


return GamePlay_ZhengShangYou