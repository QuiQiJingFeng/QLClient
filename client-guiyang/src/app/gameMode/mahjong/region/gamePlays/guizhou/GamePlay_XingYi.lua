--[[/**
    * 兴义玩法
*/]]
local room = require("app.game.ui.RoomSettingDefine")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local XingYi = {}

local _roomSetting = room.GameTypeSetting.new("GAME_TYPE_R_XINGYI",
{
    --/**局数圈数*/
    room.RuleSetting.new("ROOM_ROUND_COUNT_8",
    {
        room.RuleOption.new("ROOM_ROUND_COUNT_8", "", ""),
        room.RuleOption.new("ROOM_ROUND_COUNT_16", "", ""),
    }, true),
    --/**多人玩法 */
    room.RuleSetting.new("GAME_PLAY_PLAYER_FOUR",
    {
        room.RuleOption.new("GAME_PLAY_PLAYER_FOUR", "", ""),
        room.RuleOption.new("GAME_PLAY_PLAYER_THREE", "", ""),
        room.RuleOption.new("GAME_PLAY_PLAYER_TWO", "", ""),
    }, true),
    --/**鸡牌翻法 */
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_SWING", "", ""),
    }, false),
    --/**本鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_BENJI", "", ""),
    }, false),
    --/**乌骨鸡*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_CHICKEN_WUGU", "", ""),
    }, false),
    --/**估卖*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_GU_MAI", "", ""),
    }, false),
    --/**连庄*/
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_BANKER_SERIES", "", ""),
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
    room.RuleSetting.new("",
    {
        room.RuleOption.new("GAME_PLAY_JI_SU", "", ""),
    }, false)
})

XingYi.roomSetting = _roomSetting


local _commonEvent = {
    [PlayType.UNKNOW]	= {name = "未知", be = "未知", skin = ""			, beskin = ""			, weight = - 1},
    [PlayType.HU_ZI_MO]	= {name = "自摸", be = "被自摸", skin = "Icon/Icon_jszm", beskin = "Icon/Icon_jsbzm", weight = - 1},
    [PlayType.HU_DIAN_PAO] = {name = "接炮", be = "点炮", skin = "Icon/icon_jshp", beskin = "Icon/icon_jsdp", weight = - 1},
    [PlayType.HU_WEI_JIAO_PAI] = {name = "未叫牌", be = "", skin = ""					, beskin = ""			, weight = - 1},
    [PlayType.HU_JIAO_PAI]	= {name = "叫牌", be = "", skin = "Icon/Icon_jscdj"	, beskin = "Icon/Icon_jscdj", weight = - 1},
    [PlayType.HU_PING_HU]	= {name = "平胡", be = "", skin = "mahjong_tile/icon_37", beskin = ""			, weight = - 1},
    [PlayType.HU_PENG_PENG_HU] = {name = "大对子", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_QI_DUI]		= {name = "七对", be = "", skin = "mahjong_tile/icon_46", beskin = ""			, weight = - 1},
    [PlayType.HU_LONG_QI_DUI] = {name = "龙七对", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_QING_YI_SE]	= {name = "清一色", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_QING_DA_DUI] = {name = "清大对", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_QING_QI_DUI] = {name = "清七对", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_QING_LONG_BEI] = {name = "青龙背", be = "", skin = "mahjong_tile/"	, beskin = ""			, weight = - 1},
    [PlayType.HU_RUAN_BAO]						= {name = "软报"		, be = "软报"		, skin = "mahjong_tile/img_55", beskin = "mahjong_tile/img_55", weight = - 1},
    [PlayType.DISPLAY_JI_KILLREADYHAND]			= {name = "杀报"		, be = "被杀报"	, skin = "mahjong_tile/img_55", beskin = "mahjong_tile/img_55", weight = - 1},
    [PlayType.HU_YING_BAO]						= {name = "硬报"		, be = "硬报"		, skin = "mahjong_tile/img_55", beskin = "mahjong_tile/img_55", weight = - 1},
    -- [PlayType.HU_QING_LONG_BEI]          = { name = "被杀报", be = "img_55.png", skin = "mahjong_tile/", beskin = "", weight = -1},
    [PlayType.DISPLAY_JI_CHONGFENG]				= {name = "冲锋鸡"	, be = "冲锋鸡"	, skin = "mahjong_tile/icon_65", beskin = "mahjong_tile/icon_65", weight = - 1},
    [PlayType.DISPLAY_JI_CHONGFENG_GOLD]			= {name = "冲锋金鸡"	, be = "冲锋金鸡"	, skin = "mahjong_tile/icon_131", beskin = "mahjong_tile/icon_131", weight = - 1},
    [PlayType.DISPLAY_JI_ZEREN]					= {name = "责任鸡"	, be = "责任鸡"	, skin = "mahjong_tile/icon_42", beskin = "mahjong_tile/icon_42", weight = - 1},
    [PlayType.DISPLAY_JI_ZEREN_GOLD]				= {name = "责任金鸡"	, be = "责任金鸡"	, skin = "mahjong_tile/icon_54", beskin = "mahjong_tile/icon_54", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG]			= {name = "冲锋乌骨"	, be = "冲锋乌骨"	, skin = "mahjong_tile/icon_65", beskin = "mahjong_tile/icon_65", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_GOLD]		= {name = "冲锋金乌骨", be = "冲锋金乌骨", skin = "mahjong_tile/icon_96", beskin = "mahjong_tile/icon_96", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN]				= {name = "责任乌骨"	, be = "责任乌骨"	, skin = "mahjong_tile/icon_66", beskin = "mahjong_tile/icon_66", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_GOLD]			= {name = "责任乌骨"	, be = "责任乌骨"	, skin = "mahjong_tile/icon_95", beskin = "mahjong_tile/icon_95", weight = - 1},
    [PlayType.DISPLAY_JI_NORMAL]					= {name = "普通鸡"	, be = "普通鸡"	, skin = "mahjong_tile/icon_41", beskin = "mahjong_tile/icon_41", weight = - 1},
    [PlayType.DISPLAY_JI_NORMAL_GOLD]				= {name = "金鸡"		, be = "金鸡"		, skin = "mahjong_tile/icon_132", beskin = "mahjong_tile/icon_132", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU]					= {name = "乌骨鸡"	, be = "乌骨鸡"	, skin = "mahjong_tile/icon_64", beskin = "mahjong_tile/icon_64", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_GOLD]				= {name = "金乌骨"	, be = "金乌骨"	, skin = "mahjong_tile/icon_94", beskin = "mahjong_tile/icon_94", weight = - 1},
    [PlayType.DISPLAY_JI_SELF]					= {name = "本鸡"		, be = "本鸡"		, skin = "mahjong_tile/icon_63", beskin = "mahjong_tile/icon_63", weight = - 1},
    [PlayType.DISPLAY_JI_SELF_GOLD]				= {name = "金本鸡"	, be = "金本鸡"	, skin = "mahjong_tile/icon_153", beskin = "mahjong_tile/icon_153", weight = - 1},
    [PlayType.DISPLAY_JI_FANPAI]					= {name = "翻牌鸡"	, be = "翻牌鸡"	, skin = "mahjong_tile/icon_154", beskin = "mahjong_tile/icon_154", weight = - 1},
    [PlayType.DISPLAY_JI_FANPAI_GOLD]				= {name = "翻牌金鸡"	, be = "翻牌金鸡"	, skin = "mahjong_tile/icon_155", beskin = "mahjong_tile/icon_155", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_XINGQI]				= {name = "星期鸡"	, be = "星期鸡"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_COUNT]					= {name = "鸡牌"		, be = "鸡牌"		, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_NORMAL_FANPEI]			= {name = "普通鸡(赔)", be = "普通鸡(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_FANPEI]				= {name = "乌骨鸡(赔)", be = "乌骨鸡(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_NORMAL_GOLD_FANPEI]		= {name = "金鸡(赔)"	, be = "金鸡(赔)"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_GOLD_FANPEI]		= {name = "金乌骨(赔)", be = "金乌骨(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_CHONGFENG_FANPEI]		= {name = "冲锋鸡"	, be = "冲锋鸡"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_FANPEI]	= {name = "冲锋乌骨"	, be = "冲锋乌骨", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_ZEREN_FANPEI]			= {name = "责任鸡"	, be = "责任鸡"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_FANPEI]		= {name = "责任乌骨"	, be = "责任乌骨", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_CHONGFENG_GOLD_FANPEI]	= {name = "冲锋金鸡"	, be = "冲锋金鸡"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_CHONGFENG_GOLD_FANPEI] = {name = "冲锋金乌骨", be = "冲锋金乌骨", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_ZEREN_GOLD_FANPEI]		= {name = "责任金鸡"	, be = "责任金鸡"	, skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_JI_WUGU_ZEREN_GOLD_FANPEI]	= {name = "乌骨责任金鸡", be = "乌骨责任金鸡", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_2]					= {name = "估卖"		, be = "被估卖", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_3]					= {name = "估卖"		, be = "被估卖", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_4]					= {name = "估卖"		, be = "被估卖", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_2_PEI]				= {name = "估卖(赔)"	, be = "估卖(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_3_PEI]				= {name = "估卖(赔)"	, be = "估卖(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.DISPLAY_GU_MAI_4_PEI]				= {name = "估卖(赔)"	, be = "估卖(赔)", skin = "mahjong_tile/icon_156", beskin = "mahjong_tile/icon_156", weight = - 1},
    [PlayType.HU_GANG_SHANG_HUA] = {name = "杠上花", be = "杠上花", skin = "mahjong_tile/img_56", beskin = "mahjong_tile/img_56", weight = - 1},
    [PlayType.HU_QIANG_GANG_HU] = {name = "抢杠胡", be = "抢杠胡", skin = "mahjong_tile/icon_45", beskin = "mahjong_tile/icon_45", weight = - 1},
    [PlayType.HU_GANG_SHANG_PAO] = {name = "热炮", be = "热炮", skin = "mahjong_tile/Icon_157", beskin = "mahjong_tile/Icon_157", weight = - 1},
    [PlayType.OPERATE_GANG_A_CARD]	= {name = "明豆", be = "点明豆", skin = "mahjong_tile/img_62", beskin = "mahjong_tile/img_59", weight = - 1},
    [PlayType.OPERATE_AN_GANG]		= {name = "闷豆", be = "闷豆", skin = "mahjong_tile/img_61", beskin = "mahjong_tile/img_61", weight = - 1},
    [PlayType.OPERATE_BU_GANG_A_CARD] = {name = "梭杠", be = "被梭杠", skin = "mahjong_tile/img_101", beskin = "mahjong_tile/img_118", weight = - 1},
    [PlayType.DISPLAY_LIANZHUANG] = {name = "连庄", be = "连庄", skin = "mahjong_tile/icon_zhuang2", beskin = "mahjong_tile/icon_zhuang2", weight = - 1},
}

XingYi.commonEvent = _commonEvent

local _commands = {
    [PlayType.DISPLAY_JI_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_TING] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.OPERATE_LACK_START] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Start"),
	[PlayType.OPERATE_LACK] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack"),
	[PlayType.OPERATE_LACK_FINISH] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Finish"),
	[PlayType.OPERATE_LACK_SELECT] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Select"),
	[PlayType.OPERATE_GU_MAI_START] = require("app.gameMode.mahjong.region.commands.gumai.Command_GuMai_Start"),
	[PlayType.OPERATE_GU_MAI_SELECT] = require("app.gameMode.mahjong.region.commands.gumai.Command_GuMai_Select"),
}

local _replayCommands = {
	[PlayType.DISPLAY_JI_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_CHONGFENG] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_JI_WUGU_ZEREN] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.DISPLAY_TING] = require("app.gameMode.mahjong.region.commands.ji.Command_ShowJiAni"),
	[PlayType.OPERATE_LACK_START] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Start"),
	[PlayType.OPERATE_LACK] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack"),
	[PlayType.OPERATE_LACK_FINISH] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Finish"),
	[PlayType.OPERATE_LACK_SELECT] = require("app.gameMode.mahjong.region.commands.lack.Command_Lack_Select"),
	[PlayType.OPERATE_GU_MAI_START] = require("app.gameMode.mahjong.region.commands.gumai.Command_GuMai_Start"),
	[PlayType.OPERATE_GU_MAI_SELECT] = require("app.gameMode.mahjong.region.commands.gumai.Command_GuMai_Select"),
}

XingYi.commands = _commands
XingYi.replayCommands = _replayCommands

local _uiConifg = {
    UILack = "app.gameMode.mahjong.region.commands.lack.UILack",
    UIGuMai = "app.gameMode.mahjong.region.commands.gumai.UIGuMai",
    UISelectGuMai = "app.gameMode.mahjong.region.commands.gumai.UISelectGuMai",
    UI_GAME_TYPE_R_XINGYI = "app.gameMode.mahjong.region.gamePlays.guizhou.UI_GAME_TYPE_R_XINGYI"
}

XingYi.UIConfig = _uiConifg

return XingYi