local room = require("app.game.ui.RoomSettingDefine")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"

local GamePlay_Paodekuai = {}
local package_path = ...
GamePlay_Paodekuai.roomSetting = room.GameTypeSetting.new("GAME_TYPE_PAODEKUAI",
{
    --/**局数*/
    room.RuleSetting.new("ROOM_ROUND_COUNT_8",
    {
        room.RuleOption.new("ROOM_ROUND_COUNT_8", "", ""),
        room.RuleOption.new("ROOM_ROUND_COUNT_16", "", ""),
    }, true),

    room.RuleSetting.new("PLAYER_NUM_3",
    {
        room.RuleOption.new("PLAYER_NUM_2", "", ""),
        room.RuleOption.new("PLAYER_NUM_3", "", "")
    }, true),

    room.RuleSetting.new("FIRST_DEAL_CARD_WINNER",{
        room.RuleOption.new("FIRST_DEAL_CARD_HEI_TAO_3", "PLAYER_NUM_3", ""),
        room.RuleOption.new("FIRST_DEAL_CARD_WINNER", "", ""),
        room.RuleOption.new("FIRST_DEAL_CARD_RANDOM", "", ""),
    }, true),

    room.RuleSetting.new("",{
        room.RuleOption.new("GAME_PLAY_QUAN_GUAN_JIA_BEI", "", ""),
    }, false),

    room.RuleSetting.new("",{
        room.RuleOption.new("GAME_PLAY_YOU_PAI_BI_YA", "", ""),
    }, false),

    room.RuleSetting.new("",{
        room.RuleOption.new("GAME_PLAY_BAO_DAN_BI_DING", "", ""),
    }, false),
    
    --/**实时语音 */
    room.RuleSetting.new("GAME_PLAY_COMMON_VOICE_CLOSE",
    {
        room.RuleOption.new("GAME_PLAY_COMMON_VOICE_OPEN", "", ""),
        room.RuleOption.new("GAME_PLAY_COMMON_VOICE_CLOSE", "", ""),
    }, true),
})

local _t = RoomSetting.GamePlay
GamePlay_Paodekuai.registRuleType = {
    GAME_TYPE_PAODEKUAI = {_t.POKER_GAME_TYPE_PAO_DE_KUAI, "跑得快", "type", "paodekuai"},
    ROOM_ROUND_COUNT_8 = {_t.ROOM_ROUND_COUNT_8, "8局", "roundCount", "8j"},
    ROOM_ROUND_COUNT_16 = {_t.ROOM_ROUND_COUNT_16, "16局", "roundCount", "16j"},
    PLAYER_NUM_2 = {_t.PLAYER_NUM_2, "两人局", "rule", "2r"},
    PLAYER_NUM_3 = {_t.PLAYER_NUM_3, "三人局", "rule", "3r"},
    FIRST_DEAL_CARD_HEI_TAO_3 = {_t.FIRST_DEAL_CARD_HEI_TAO_3, "黑桃3先", "rule", "ht3x"},
    FIRST_DEAL_CARD_WINNER = {_t.FIRST_DEAL_CARD_WINNER, "赢家先", "rule", "yjx"},
    FIRST_DEAL_CARD_RANDOM = {_t.FIRST_DEAL_CARD_RANDOM, "随机先", "rule", "sjx"},
    GAME_PLAY_QUAN_GUAN_JIA_BEI = {_t.GAME_PLAY_QUAN_GUAN_JIA_BEI, "全关加倍", "rule", "qgjb"},
    GAME_PLAY_YOU_PAI_BI_YA = {_t.GAME_PLAY_YOU_PAI_BI_YA, "有牌必压", "rule", "ypby"},
    GAME_PLAY_BAO_DAN_BI_DING = {_t.GAME_PLAY_BAO_DAN_BI_DING, "报单必顶", "rule", "bdbd"},
}

GamePlay_Paodekuai.commonEvent = {
    [Constants.PlayType.POKER_DISPLAY_ZHADAN_SCORE] = {name = "炸弹", be = "炸弹", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_HAND_SCORE] = {name = "牌数", be = "牌数", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_QUAN_GUAN_JIA_BEI_SCORE] = {name = "关门", be = "关门", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.POKER_DISPLAY_WIN] = {name = "赢家", be = "赢家", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.HU_POKER_GUAN_MEN] = {name = "关门", be = "关门", skin = "", beskin = "", weight = -1},
    [Constants.PlayType.HU_POKER_WIN] = {name = "取胜", be = "取胜", skin = "", beskin = "", weight = -1},
}

local commandsBasePath = "app.gameMode.paodekuai.region.commands."
GamePlay_Paodekuai.commands = {
    [Constants.PlayType.POKER_OPERATE_CAN_PASS] = require(commandsBasePath .. "Command_CanOptions"),
    [Constants.PlayType.POKER_OPERATE_CAN_PLAY_A_CARD] = require(commandsBasePath .. "Command_CanOptions"),
    [Constants.PlayType.POKER_OPERATE_LAST_PLAY_A_CARD] = require(commandsBasePath .. "Command_OperationSYN"),
    [Constants.PlayType.POKER_OPERATE_PASS] = require(commandsBasePath .. "Command_OperationSYN"),
    [Constants.PlayType.DISPLAY_FINISH_ALL] = require(commandsBasePath .. "Command_Display_RoundFinish"),
    [Constants.PlayType.POKER_DISPLAY_HAND_CARD_SIZE] = require(commandsBasePath .. "Command_DisPlay_RemainCard"),
    [Constants.PlayType.POKER_OPERATE_AUTO_PASS] = require(commandsBasePath .. "Command_AutoPass")
}

GamePlay_Paodekuai.UIConfig = {
    UI_GAME_TYPE_PAODEKUAI = "app.gameMode.paodekuai.region.gamePlays.guizhou.UI_GAME_TYPE_PAODEKUAI",
    UIGameScene_Paodekuai = "app.gameMode.paodekuai.ui.UIGameScene_Paodekuai",
    UICardsInfo_Paodekuai = "app.gameMode.paodekuai.ui.UICardsInfo_Paodekuai"
}

GamePlay_Paodekuai.replayCommands = {}
GamePlay_Paodekuai.registGameUI = {
	[Constants.GameUIType['UI_GAME_SCENE']] = "GameState_Paodekuai"
}
return GamePlay_Paodekuai