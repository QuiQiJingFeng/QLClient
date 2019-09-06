
--[[/**
    * 两丁一房玩法
*/]]
local room = require("app.game.ui.RoomSettingDefine")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local LiangDing = {}

local _roomSetting = room.GameTypeSetting.new("GAME_TYPE_R_LIANGDING",
{
    --/**局数圈数*/
    room.RuleSetting.new("ROOM_ROUND_COUNT_8",
    {
        room.RuleOption.new("ROOM_ROUND_COUNT_8", "", ""),
        room.RuleOption.new("ROOM_ROUND_COUNT_16", "", ""),
    }, true),
    --/**鸡牌翻法 */
    room.RuleSetting.new("GAME_PLAY_CHICKEN_FLOP",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_FLOP", "", ""),
        room.RuleOption.new("GAME_PLAY_CHICKEN_SWING", "", ""),
    }, true),
    --/**本鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_BENJI", "", ""),
    }, false),
    --/**吹风鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_CHUIFENG", "", ""),
    }, false),
    --/**星期鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_XINQQI", "", ""),
    }, false),
    --/**首圈鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHOUQUANJI_CHUIFENG", "", ""),
    }, false),
    --/**银鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_YINJI_CHUIFENG", "", ""),
    }, false),

    --/**实时语音 */
    room.RuleSetting.new("GAME_PLAY_COMMON_VOICE_CLOSE",
    {
        room.RuleOption.new("GAME_PLAY_COMMON_VOICE_OPEN", "", ""),
        room.RuleOption.new("GAME_PLAY_COMMON_VOICE_CLOSE", "", ""),
    }, true),

    --/**听牌提示 */
    room.RuleSetting.new("GAME_PLAY_COMMON_TING_TIPS_OPEN",
    {
        room.RuleOption.new("GAME_PLAY_COMMON_TING_TIPS_OPEN", "", ""),
        room.RuleOption.new("GAME_PLAY_COMMON_TING_TIPS_CLOSE", "", ""),
    }, true),

    -- 极速模式
    room.RuleSetting.new("TRUSTEESHIP_NO",
    {
        room.RuleOption.new("GAME_PLAY_JI_SU", "", ""),
        room.RuleOption.new("TRUSTEESHIP_NO", "", ""),
        room.RuleOption.new("TRUSTEESHIP_60", "", ""),
        room.RuleOption.new("TRUSTEESHIP_180", "", ""),
        room.RuleOption.new("TRUSTEESHIP_300", "", ""),
    }, true)
})
LiangDing.roomSetting = _roomSetting

local _commonEvent = {
    [PlayType.UNKNOW]      = {name = "未知", be = "未知"  , skin = ""              , beskin = ""               , weight = -1},
    [PlayType.HU_ZI_MO]    = {name = "自摸", be = "被自摸", skin = "Icon/Icon_jszm", beskin = "Icon/Icon_jsbzm", weight = -1},
    [PlayType.HU_DIAN_PAO] = {name = "接炮", be = "点炮"  , skin = "Icon/icon_jshp", beskin = "Icon/icon_jsdp" , weight = -1},

    -- 贵阳胡牌类型
    [PlayType.HU_WEI_JIAO_PAI]  = {name = "未叫牌", be = "", skin = ""                    , beskin = ""               , weight = -1},
    [PlayType.HU_JIAO_PAI]      = {name = "叫牌"  , be = "", skin = "Icon/Icon_jscdj"     , beskin = "Icon/Icon_jscdj", weight = -1},
    [PlayType.HU_PING_HU]       = {name = "平胡"  , be = "", skin = "mahjong_tile/icon_37", beskin = ""               , weight = -1},
    [PlayType.HU_PENG_PENG_HU]  = {name = "大对子", be = "", skin = "mahjong_tile/"       , beskin = ""               , weight = -1},
   
    [PlayType.HU_RUAN_BAO]                           = {name = "软报"        , be = "软报"        , skin = "mahjong_tile/img_55"  , beskin = "mahjong_tile/img_55"  , weight = -1},
    [PlayType.DISPLAY_JI_KILLREADYHAND]              = {name = "杀报"        , be = "被杀报"      , skin = "mahjong_tile/img_55"  , beskin = "mahjong_tile/img_55"  , weight = -1},
    [PlayType.HU_YING_BAO]                           = {name = "硬报"        , be = "硬报"        , skin = "mahjong_tile/img_55"  , beskin = "mahjong_tile/img_55"  , weight = -1},
    [PlayType.HU_DI_HU]                              = {name = "地胡"        , be = "地胡"        , skin = "mahjong_tile/icon_83" , beskin = "mahjong_tile/icon_83" , weight = -1},
    [PlayType.DISPLAY_JI_CHONGFENG]                  = {name = "冲锋鸡"      , be = "冲锋鸡"      , skin = "mahjong_tile/icon_65" , beskin = "mahjong_tile/icon_65" , weight = -1},
    [PlayType.DISPLAY_JI_CHONGFENG_GOLD]             = {name = "冲锋金鸡"    , be = "冲锋金鸡"    , skin = "mahjong_tile/icon_131", beskin = "mahjong_tile/icon_131", weight = -1},
    [PlayType.DISPLAY_JI_ZEREN]                      = {name = "责任鸡"      , be = "责任鸡"      , skin = "mahjong_tile/icon_42" , beskin = "mahjong_tile/icon_42" , weight = -1},
    [PlayType.DISPLAY_JI_ZEREN_GOLD]                 = {name = "责任金鸡"    , be = "责任金鸡"    , skin = "mahjong_tile/icon_54" , beskin = "mahjong_tile/icon_54" , weight = -1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG]             = {name = "冲锋乌骨"    , be = "冲锋乌骨"    , skin = "mahjong_tile/icon_65" , beskin = "mahjong_tile/icon_65" , weight = -1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_GOLD]        = {name = "冲锋金乌骨"  , be = "冲锋金乌骨"  , skin = "mahjong_tile/icon_96" , beskin = "mahjong_tile/icon_96" , weight = -1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN]                 = {name = "责任乌骨"    , be = "责任乌骨"    , skin = "mahjong_tile/icon_66" , beskin = "mahjong_tile/icon_66" , weight = -1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_GOLD]            = {name = "责任乌骨"    , be = "责任乌骨"    , skin = "mahjong_tile/icon_95" , beskin = "mahjong_tile/icon_95" , weight = -1},
    [PlayType.DISPLAY_JI_NORMAL]                     = {name = "普通鸡"      , be = "普通鸡"      , skin = "mahjong_tile/icon_41" , beskin = "mahjong_tile/icon_41" , weight = -1},
    [PlayType.DISPLAY_JI_NORMAL_GOLD]                = {name = "金鸡"        , be = "金鸡"        , skin = "mahjong_tile/icon_132", beskin = "mahjong_tile/icon_132", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_GOLD]                  = {name = "金乌骨"      , be = "金乌骨"      , skin = "mahjong_tile/icon_94" , beskin = "mahjong_tile/icon_94" , weight = -1},
    [PlayType.DISPLAY_JI_SELF]                       = {name = "本鸡"        , be = "本鸡"        , skin = "mahjong_tile/icon_63" , beskin = "mahjong_tile/icon_63" , weight = -1},
    [PlayType.DISPLAY_JI_SELF_GOLD]                  = {name = "金本鸡"      , be = "金本鸡"      , skin = "mahjong_tile/icon_153", beskin = "mahjong_tile/icon_153", weight = -1},
    [PlayType.DISPLAY_JI_FANPAI]                     = {name = "翻牌鸡"      , be = "翻牌鸡"      , skin = "mahjong_tile/icon_154", beskin = "mahjong_tile/icon_154", weight = -1},
    [PlayType.DISPLAY_JI_FANPAI_GOLD]                = {name = "翻牌金鸡"    , be = "翻牌金鸡"    , skin = "mahjong_tile/icon_155", beskin = "mahjong_tile/icon_155", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_XINGQI]                = {name = "星期鸡"      , be = "星期鸡"      , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_COUNT]                      = {name = "鸡牌"        , be = "鸡牌"        , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_NORMAL_FANPEI]              = {name = "普通鸡(赔)"  , be = "普通鸡(赔)"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_FANPEI]                = {name = "乌骨鸡(赔)"  , be = "乌骨鸡(赔)"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_NORMAL_GOLD_FANPEI]         = {name = "金鸡(赔)"    , be = "金鸡(赔)"    , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_GOLD_FANPEI]           = {name = "金乌骨(赔)"  , be = "金乌骨(赔)"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_CHONGFENG_FANPEI]           = {name = "冲锋鸡"      , be = "冲锋鸡"      , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_FANPEI]      = {name = "冲锋乌骨"    , be = "冲锋乌骨"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_ZEREN_FANPEI]               = {name = "责任鸡"      , be = "责任鸡"      , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_FANPEI]          = {name = "责任乌骨"    , be = "责任乌骨"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_CHONGFENG_GOLD_FANPEI]      = {name = "冲锋金鸡"    , be = "冲锋金鸡"    , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_GOLD_FANPEI] = {name = "冲锋金乌骨"  , be = "冲锋金乌骨", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_ZEREN_GOLD_FANPEI]          = {name = "责任金鸡"    , be = "责任金鸡"    , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_GOLD_FANPEI]     = {name = "乌骨责任金鸡" , be = "乌骨责任金鸡", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_SHOUQUAN]                   = {name = "首圈鸡"        , be = "首圈鸡"    , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_SHOUQUAN_FANPEI]            = {name = "首圈鸡(赔)"  , be = "首圈鸡(赔)"  , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_SHOUQUAN_GOLD]              = {name = "首圈金鸡"    , be = "首圈金鸡"    , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_SHOUQUAN_GOLD_FANPEI]       = {name = "首圈金鸡(赔)", be = "首圈金鸡(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.DISPLAY_JI_SILVER]                     = {name = "银鸡"         , be = "银鸡"         , skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = -1},
    [PlayType.HU_DAN_DIAO]                           = {name = "单吊"        , be = "单吊"      , skin = "mahjong_tile/"         , beskin = ""                      , weight = -1},
    [PlayType.HU_DI_LONG]                            = {name = "地龙"         , be = "地龙"      , skin = "mahjong_tile/"         , beskin = ""                      , weight = -1},
    [PlayType.HU_QING_DI_LONG]                       = {name = "清地龙"         , be = "清地龙"      , skin = "mahjong_tile/"         , beskin = ""                      , weight = -1},

    [PlayType.HU_GANG_SHANG_HUA] = {name = "杠上花", be = "杠上花", skin = "mahjong_tile/img_56"  , beskin = "mahjong_tile/img_56"  , weight = -1},
    [PlayType.HU_QIANG_GANG_HU]  = {name = "抢杠胡", be = "抢杠胡", skin = "mahjong_tile/icon_45" , beskin = "mahjong_tile/icon_45" , weight = -1},
    [PlayType.HU_GANG_SHANG_PAO] = {name = "热炮"  , be = "热炮"  , skin = "mahjong_tile/Icon_157", beskin = "mahjong_tile/Icon_157", weight = -1},

    [PlayType.OPERATE_GANG_A_CARD]    = {name = "明豆"  , be = "点明豆", skin = "mahjong_tile/img_62", beskin = "mahjong_tile/img_61", weight = -1},
    [PlayType.OPERATE_AN_GANG]        = {name = "闷豆"  , be = "闷豆"  , skin = "mahjong_tile/img_59", beskin = "mahjong_tile/img_59", weight = -1},
    [PlayType.OPERATE_BU_GANG_A_CARD] = {name = "转弯豆", be = "转弯豆", skin = "mahjong_tile/img_60", beskin = "mahjong_tile/img_60", weight = -1},

    [PlayType.DISPLAY_LIANZHUANG] = {name = "连庄", be = "连庄", skin = "mahjong_tile/icon_zhuang2", beskin = "mahjong_tile/icon_zhuang2", weight = -1},
    [PlayType.DISPLAY_MULTIPLE ] =  {name = "翻倍", be = "被翻倍", skin = "mahjong_tile/icon_zhuang2", beskin = "mahjong_tile/icon_zhuang2", weight = -1},
}

LiangDing.commonEvent = _commonEvent

local _commands = {
	[PlayType.DISPLAY_JI_SHOUQUAN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_TING] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.OPERATE_LACK_START] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Start"),
	[PlayType.OPERATE_LACK] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack"),
	[PlayType.OPERATE_LACK_FINISH] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Finish"),
    [PlayType.OPERATE_LACK_SELECT] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Select"),
    
    -- gold field hzs gameplay
    [PlayType.OPERATE_CHANGECARD_START] = require("app.gameMode.mahjong.region.commands.huansanzhang.Command_HSZ_Start"),
    [PlayType.OPERATE_CHANGECARD_SELECT] = require("app.gameMode.mahjong.region.commands.huansanzhang.Command_HSZ_Select"),
    [PlayType.OPERATE_CHANGECARD_FINISH] = require("app.gameMode.mahjong.region.commands.huansanzhang.Command_HSZ_Finish"),
}

local _replayCommands = {
	[PlayType.DISPLAY_JI_SHOUQUAN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_TING] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.OPERATE_LACK_START] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Start"),
	[PlayType.OPERATE_LACK] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack"),
	[PlayType.OPERATE_LACK_FINISH] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Finish"),
	[PlayType.OPERATE_LACK_SELECT] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Select"),
}

LiangDing.commands = _commands
LiangDing.replayCommands = _replayCommands

local _uiConifg = {
    UILack = "app.gameMode.mahjong.region.commands.lack.UILack",
    UI_GAME_TYPE_R_LIANGDING = "app.gameMode.mahjong.region.gamePlays.guizhou.UI_GAME_TYPE_R_LIANGDING",
    UIHuanSanZhang = "app.gameMode.mahjong.region.commands.huansanzhang.UIHuanSanZhang"
}

LiangDing.UIConfig = _uiConifg

return LiangDing