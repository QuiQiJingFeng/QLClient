
--[[/**
    * 贞丰玩法
*/]]
local room = require("app.game.ui.RoomSettingDefine")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local PuNing = {}

local _roomSetting = room.GameTypeSetting.new("GAME_TYPE_PU_NING",
{
	
	room.RuleSetting.new("ROOM_ROUND_COUNT_8",
	{
		room.RuleOption.new("ROOM_ROUND_COUNT_4", "", ""),
		room.RuleOption.new("ROOM_ROUND_COUNT_8", "", ""),
		room.RuleOption.new("ROOM_ROUND_COUNT_16", "", ""),
	}, true),
	
	--胡牌 二选一 默认自摸
	room.RuleSetting.new("Hu_DIAN_HU",
	{
		room.RuleOption.new("Hu_DIAN_HU", "", ""),
		room.RuleOption.new("Hu_ZI_MO", "", ""),
	}, true),
	
	--[[        选了自摸，才有此项。
        10倍不计分，从属于自摸玩法中。当有人自摸胡牌，其他三家如果存在所听牌型分不低于10倍底分的玩家时，则此人此局不付给胡牌者分数
    ]]
	room.RuleSetting.new("",
	{
		-- 10倍不计分
		room.RuleOption.new("HU_ZI_MO_TARGET_SCORE_LIMIT", "Hu_ZI_MO", "Hu_ZI_MO"),
	}, false),
	
	-- 吃杠杠爆全包
	room.RuleSetting.new("",
	{
		room.RuleOption.new("CHI_GANG_GANG_BAO_QUAN_BAO", "", ""),
	}, false),
	
	-- 跟庄
	room.RuleSetting.new("SCORE_GEN_ZHUANG",
	{
		room.RuleOption.new("SCORE_GEN_ZHUANG", "", ""),
	}, false),
	
	--[[     选了跟庄，才有此项。
     从属于跟庄玩法
    ]]
	room.RuleSetting.new("SCORE_GEN_ZHUANG_LIANG_FEN",
	{
		--跟庄一分
		room.RuleOption.new("SCORE_GEN_ZHUANG_YI_FEN", "SCORE_GEN_ZHUANG", "SCORE_GEN_ZHUANG"),
		--跟庄二分
		room.RuleOption.new("SCORE_GEN_ZHUANG_LIANG_FEN", "SCORE_GEN_ZHUANG", "SCORE_GEN_ZHUANG"),
	}, true),
	
	-- 封顶
	room.RuleSetting.new("SCORE_LIMIT_NONE",
	{
		room.RuleOption.new("SCORE_LIMIT_5", "", ""),
		room.RuleOption.new("SCORE_LIMIT_10", "", ""),
		room.RuleOption.new("SCORE_LIMIT_NONE", "", ""),
	}, true),
	
	-- 鬼牌
	room.RuleSetting.new("MASTER_CARD_NONE",
	{
		room.RuleOption.new("MASTER_CARD_NONE", "", ""),
		room.RuleOption.new("MASTER_CARD_HONG_ZHONG", "not GAME_PLAY_NO_ZI", ""),
		room.RuleOption.new("MASTER_CARD_BAI_BAN", "not GAME_PLAY_NO_ZI", ""),
		room.RuleOption.new("MASTER_CARD_GENERATE", "", ""),
	}, true),
	
	room.RuleSetting.new("",
	{
		-- 无鬼加倍
		room.RuleOption.new("MASTER_CARD_NONE_DOUBLE", "MASTER_CARD_HONG_ZHONG or MASTER_CARD_BAI_BAN or MASTER_CARD_GENERATE", ""),
	}, false),
	room.RuleSetting.new("",
	{
		-- 四鬼胡牌
		room.RuleOption.new("MASTER_CARD_FORE_HU", "MASTER_CARD_HONG_ZHONG or MASTER_CARD_BAI_BAN or MASTER_CARD_GENERATE", ""),
	}, false),
	room.RuleSetting.new("",
	{
		-- 四鬼胡牌时，双倍分数
		room.RuleOption.new("MASTER_CARD_DOUBLE_SCORE", "MASTER_CARD_FORE_HU", "MASTER_CARD_FORE_HU"),
	}, false),
	
	--[[马牌，默认无马]]
	room.RuleSetting.new("BETTING_HORSE_8",
	{
		room.RuleOption.new("BETTING_HORSE_0", "", ""),
		room.RuleOption.new("BETTING_HORSE_2", "", ""),
		room.RuleOption.new("BETTING_HORSE_5", "", ""),
		room.RuleOption.new("BETTING_HORSE_8", "", ""),
	}, true),
	
	room.RuleSetting.new("",
	{
		-- 马跟杠
		room.RuleOption.new("BETTING_HORSE_WITH_GANG", "BETTING_HORSE_2 or BETTING_HORSE_5 or BETTING_HORSE_8", ""),
	}, false),
	
	room.RuleSetting.new("BUY_HORSE_1",
	{
		room.RuleOption.new("NO_BUY_HORSE", "", ""),
		room.RuleOption.new("BUY_HORSE_1", "", ""),
		room.RuleOption.new("BUY_HORSE_2", "", ""),
		room.RuleOption.new("PUNISH_HORSE_1", "", ""),
		room.RuleOption.new("PUNISH_HORSE_2", "", ""),
	}, true),
	
	--连庄
	room.RuleSetting.new("SCORE_LIAN_ZHUANG",
	{
		room.RuleOption.new("SCORE_LIAN_ZHUANG", "", ""),
	}, false),

	--/**听牌提示 */
	room.RuleSetting.new("GAME_PLAY_COMMON_TING_TIPS_CLOSE",
	{
		room.RuleOption.new("GAME_PLAY_COMMON_TING_TIPS_OPEN", "", ""),
		room.RuleOption.new("GAME_PLAY_COMMON_TING_TIPS_CLOSE", "", ""),
	}, true),
})

PuNing.roomSetting = _roomSetting


local _commonEvent = {
	[PlayType.UNKNOW]	= {name = "未知", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_PING_HU] = {name = "平胡", be = "被平胡", skin = "mahjong_tile/icon_37", beskin = "", weight = - 1},
	[PlayType.HU_DA_HU]	= {name = "大胡", be = "", skin = "mahjong_tile/icon_37", beskin = "", weight = - 1},
	[PlayType.HU_QI_DUI]	= {name = "七对", be = "被七对", skin = "mahjong_tile/icon_46", beskin = "", weight = - 1},
	[PlayType.HU_SHI_SAN_YAO] = {name = "十三幺", be = "被十三幺", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QING_YI_SE] = {name = "清一色", be = "被清一色", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_YI_TIAO_LONG] = {name = "一条龙", be = "被一条龙", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_GEN] = {name = "根", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_DAI_YAO] = {name = "带幺九", be = "", skin = "mahjong_tile/icon_43", beskin = "", weight = - 1},
	[PlayType.HU_PENG_PENG_HU] = {name = "碰碰胡", be = "被碰碰胡", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_JIANG_DUI] = {name = "将对", be = "", skin = "mahjong_tile/icon_36", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_XIAO] = {name = "全小", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_ZHONG] = {name = "全中", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_DA] = {name = "全大", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_ZHONG_ZHANG] = {name = "中张", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_MEN_QIAN_QING] = {name = "门清", be = "", skin = "mahjong_tile/icon_71", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_QIU_REN] = {name = "全求人", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_TIAN_HU] = {name = "天胡", be = "被天胡", skin = "mahjong_tile/icon_48", beskin = "", weight = - 1},
	[PlayType.HU_DI_HU] = {name = "地胡", be = "被地胡", skin = "mahjong_tile/icon_64", beskin = "", weight = - 1},
	[PlayType.HU_GANG_SHANG_HUA] = {name = "杠爆", be = "被杠爆", skin = "icon/icon_jsgb", beskin = "icon/icon_jsbgb", weight = - 1},
	[PlayType.HU_GANG_SHANG_PAO] = {name = "杠上炮", be = "", skin = "mahjong_tile/icon_87", beskin = "", weight = - 1},
	[PlayType.HU_QIANG_GANG_HU] = {name = "抢杠胡", be = "被抢杠胡", skin = "icon/icon_jsqgh", beskin = "icon/icon_jsbqg", weight = - 1},
	[PlayType.HU_HAI_DI_LAO_YUE] = {name = "海底捞月", be = "被海底捞月", skin = "icon/icon_jshl", beskin = "icon/icon_jsbhl", weight = - 1},
	[PlayType.HU_JIN_GOU] = {name = "金钩", be = "", skin = "mahjong_tile/icon_35", beskin = "", weight = - 1},
	[PlayType.HU_ZI_MO] = {name = "自摸", be = "被自摸", skin = "icon/icon_jszm", beskin = "icon/icon_jsbzm", weight = - 1},
	[PlayType.HU_DIAN_PAO] = {name = "吃胡", be = "点炮", skin = "icon/icon_jsch", beskin = "icon/icon_jsdp", weight = - 1},
	[PlayType.DISPLAY_DIANPAO] = {name = "点炮", be = "吃胡", skin = "mahjong_tile/icon_69", beskin = "mahjong_tile/icon_49", weight = - 1},
	[PlayType.HU_QING_YAO_JIU] = {name = "清一九", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_HUN_YAO_JIU] = {name = "一九", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_HUN_YAO_JIU_CHAOZHOU] = {name = "混一九", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_ZI_YI_SE] = {name = "字一色", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_HUN_YI_SE] = {name = "混一色", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_SI_GANG] = {name = "十八罗汉", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_SI_MASTER_CARD_HU] = {name = "四鬼胡牌", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_HAO_HUA_QI_DUI] = {name = "豪华七小对", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_HAO_HUA_QING_QI_DUI] = {name = "豪华清七对", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QUE_YI_MEN] = {name = "缺一门", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_BIAN_ZHANG] = {name = "边张", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_KAN_ZHANG] = {name = "坎张", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_DAN_DIAO] = {name = "单钓", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_GOU_ZHANG] = {name = "够张", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_DAI_PIAO] = {name = "带漂", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_SHUANG_HAO_HUA_QI_DUI] = {name = "双豪华七小对", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_SAN_HAO_HUA_QI_DUI] = {name = "三豪华七小对", be = "", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.HU_QUAN_ZI_DUI_DUI_PENG] = {name = "全字对对碰", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_QING_PENG] = {name = "清碰", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_HUN_PENG] = {name = "混碰", be = "", skin = "", beskin = "", weight = - 1},
	
	
	[PlayType.OPERATE_GANG_A_CARD] = {name = "吃杠", be = "被吃杠", skin = "mahjong_tile/icon_78", beskin = "mahjong_tile/icon_79", weight = - 1},
	[PlayType.OPERATE_AN_GANG] = {name = "暗杠", be = "被暗杠", skin = "mahjong_tile/icon_61", beskin = "mahjong_tile/icon_89", weight = - 1},
	[PlayType.OPERATE_BU_GANG_A_CARD] = {name = "明杠", be = "被明杠", skin = "mahjong_tile/icon_60", beskin = "mahjong_tile/icon_90", weight = - 1,},
	
	[PlayType.DISPLAY_HUAZHU] = {name = "查花猪", be = "查花猪", skin = "mahjong_tile/icon_63", beskin = "mahjong_tile/icon_63", weight = - 1},
	[PlayType.DISPLAY_DAJIAO] = {name = "查大叫", be = "查大叫", skin = "mahjong_tile/icon_62", beskin = "mahjong_tile/icon_62", weight = - 1},
	[PlayType.DISPLAY_HU_JIAO_ZHUAN_YI] = {name = "呼叫转移", be = "呼叫转移", skin = "mahjong_tile/icon_38", beskin = "mahjong_tile/icon_38", weight = - 1},
	[PlayType.DISPLAY_ZIMO_FAN] = {name = "自摸加番", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.DISPLAY_ZIMO_FEN] = {name = "自摸加分", be = "", skin = "", beskin = "", weight = - 1},
	
	[PlayType.DISPLAY_BETTING_HORSE] = {name = "奖马", be = "被奖马", skin = "mahjong_tile/icon_117", beskin = "mahjong_tile/icon_119", weight = - 1},
	
	[PlayType.DISPLAY_NO_MASTER_CARD] = {name = "无鬼加倍", be = "无鬼加倍", skin = "mahjong_tile/", beskin = "", weight = - 1},
	[PlayType.DISPLAY_FOLLOW_BANKER] = {name = "被跟庄", be = "跟庄", skin = "mahjong_tile/icon_53", beskin = "mahjong_tile/icon_52", weight = - 1},
	
	--/** 广东 推到胡  */
	[PlayType.HU_YAO_JIU_GDTDH] = {name = "幺九", be = "", skin = "mahjong_tile/icon_43", beskin = "", weight = - 1},
	
	[PlayType.HU_MEN_QING] = {name = "门清", be = "", skin = "", beskin = "", weight = - 1},
	
	--/** 潮汕-- 汕尾 */
	[PlayType.HU_DA_SAN_YUAN] = {name = "大三元", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_XIAO_SAN_YUAN] = {name = "小三元", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_DA_SI_XI] = {name = "大四喜", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_XIAO_SI_XI] = {name = "小四喜", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.DISPLAY_ZI_JIA_FAN] = {name = "字牌加番", be = "被字牌加番", skin = "mahjong_tile/icon_123", beskin = "mahjong_tile/icon_126", weight = - 1},
	[PlayType.DISPLAY_HUA_JIA_FAN] = {name = "花牌加番", be = "被花牌加番", skin = "mahjong_tile/icon_124", beskin = "mahjong_tile/icon_127", weight = - 1},
	[PlayType.DISPLAY_FENG_JIA_FAN] = {name = "风牌加番", be = "被风牌加番", skin = "mahjong_tile/icon_125", beskin = "mahjong_tile/icon_128", weight = - 1},
	[PlayType.DISPLAY_EX_CARD] = {name = "花牌", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.DISPLAY_GEN_ZHUANG] = {name = "被跟庄", be = "跟庄", skin = "mahjong_tile/icon_52", beskin = "mahjong_tile/icon_53", weight = - 1},
	
	--// 汕头全牌型，所有胡牌固定显示
	[PlayType.HU_QUAN_PAI_XING] = {name = "胡牌", be = "", skin = "", beskin = "", weight = - 1},
	[PlayType.HU_CHI_GANG_GANG_BAO] = {name = "吃杠杠爆全包", be = "被吃杠杠爆全包", skin = "", beskin = "", weight = - 1},
	
	--// 马牌/罚马
	[PlayType.DISPLAY_BUY_HORSE] = {name = "买马", be = "买马", skin = "mahjong_tile/icon_135", beskin = "mahjong_tile/icon_136", weight = - 1},
	[PlayType.DISPLAY_PUNISH_HORSE] = {name = "罚马", be = "罚马", skin = "mahjong_tile/icon_137", beskin = "mahjong_tile/icon_138", weight = - 1},
	
	[PlayType.DISPLAY_HU_BUY_HORSE_SCORE] = {name = "买马", be = "被买马", skin = "mahjong_tile/icon_135", beskin = "mahjong_tile/icon_136", weight = - 1},
	[PlayType.DISPLAY_HU_PUNISH_HORSE_SCORE] = {name = "罚马", be = "被罚马", skin = "mahjong_tile/icon_137", beskin = "mahjong_tile/icon_138", weight = - 1},
	
	[PlayType.DISPLAY_BE_HU_BUY_HORSE_SCORE] = {name = "被买马", be = "买马", skin = "mahjong_tile/icon_135", beskin = "mahjong_tile/icon_136", weight = - 1},
	[PlayType.DISPLAY_BE_HU_PUNISH_HORSE_SCORE] = {name = "被罚马", be = "罚马", skin = "mahjong_tile/icon_135", beskin = "mahjong_tile/icon_136", weight = - 1},
	[PlayType.DISPLAY_ALL_HORSE_CARD_COUNT] = {name = "马牌", be = "", skin = "", beskin = "", weight = - 1},
	
	[PlayType.DISPLAY_GANG_GEN_DI_FEN] = {name = "杠跟底分", be = "被杠跟底分", skin = "", beskin = "", weight = - 1},
	[PlayType.DISPLAY_LIAN_ZHUANG] = {name = "连庄", be = "被连庄", skin = "", beskin = "", weight = - 1},
	[PlayType.DISPLAY_MULTIPLE ] =  {name = "底倍", be = "底倍", skin = "mahjong_tile/icon_zhuang2", beskin = "mahjong_tile/icon_zhuang2", weight = -1},
}

PuNing.commonEvent = _commonEvent

local _commands = {
	[PlayType.DISPLAY_BUY_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_PUNISH_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_WIN_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_LOSE_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_HORSE_END] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_GEN_ZHUANG] = require("app.gameMode.mahjong.region.commands.Command_GenZhuang"),
	[PlayType.DISPLAY_DEAL_BETTING_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_DealBettingHorse"),
	[PlayType.DISPLAY_BETTING_HORSE_MULTI] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_DEAL_BETTING_HORSE_MULTI] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_DEAL_MASTER_CARD] = require("app.gameMode.mahjong.region.commands.guipai.Command_FanGui"),
	[PlayType.DISPLAY_SHOW_MASTER_CARD] = require("app.gameMode.mahjong.region.commands.guipai.Command_showMasterCard"),
	[PlayType.DISPLAY_ZHENG_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_LIAN_ZHUANG] = require("app.gameMode.mahjong.region.commands.Command_LianZhuang"),
}

local _replayCommands = {
	[PlayType.DISPLAY_BUY_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_PUNISH_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_WIN_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_LOSE_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_HORSE_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_HORSE_END] = require("app.gameMode.mahjong.region.commands.horse.Command_MaData"),
	[PlayType.DISPLAY_GEN_ZHUANG] = require("app.gameMode.mahjong.region.commands.Command_GenZhuang"),
	[PlayType.DISPLAY_DEAL_BETTING_HORSE] = require("app.gameMode.mahjong.region.commands.horse.Command_DealBettingHorse"),
	[PlayType.DISPLAY_BETTING_HORSE_MULTI] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_DEAL_BETTING_HORSE_MULTI] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_DEAL_MASTER_CARD] = require("app.gameMode.mahjong.region.commands.guipai.Command_FanGui"),
	[PlayType.DISPLAY_SHOW_MASTER_CARD] = require("app.gameMode.mahjong.region.commands.guipai.Command_showMasterCard"),
	[PlayType.DISPLAY_ZHENG_CARD] = require("app.gameMode.mahjong.region.commands.horse.Command_BettingHorseMulti"),
	[PlayType.DISPLAY_LIAN_ZHUANG] = require("app.gameMode.mahjong.region.commands.Command_LianZhuang"),
}

PuNing.commands = _commands
PuNing.replayCommands = _replayCommands

local _uiConifg = {
	UILack = "app.gameMode.mahjong.region.commands.lack.UILack",
	UI_GAME_TYPE_PU_NING = "app.gameMode.mahjong.region.gamePlays.guangdong.UI_GAME_TYPE_PU_NING"
}

PuNing.UIConfig = _uiConifg

return PuNing 