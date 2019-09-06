local CommandCenter = require("app.manager.CommandCenter")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local room = require("app.game.ui.RoomSettingDefine")
local RoomSetting = config.GlobalConfig.getRoomSetting()

-- 子玩法
local GamePlay_ChaoShan = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_ChaoShan")
local GamePlay_ChaoZhou = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_ChaoZhou")
local GamePlay_GuiChaoShan = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_GuiChaoShan")
local GamePlay_PuNing = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_PuNing")
local GamePlay_ShanTou = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_ShanTou")
local GamePlay_HuiLai = require("app.gameMode.mahjong.region.gamePlays.guangdong.GamePlay_HuiLai")
local GamePlay_ZhengShangYou = require("app.gameMode.zhengshangyou.region.gamePlays.zhengshangyou.GamePlay_ZhengShangYou")

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

local CHAOSHAN = {}

local _gameType = {
    name = "潮汕麻将",
    gameTypes = {
        {
            id = "GAME_TYPE_CHAO_SHAN",
            name = "潮汕麻将",
            destopSkin = "gaming/z_czmq.png",
            isNew = false,
            isOpenTingTips = false,
        },
        {
            id = "GAME_TYPE_CHAO_ZHOU",
            name = "潮州麻将",
            destopSkin = "gaming/z_czmq.png",
            isNew = false,
            isOpenTingTips = false,
        },

        {
            id = "GAME_TYPE_SHAN_TOU",
            name = "汕头麻将",
            destopSkin = "gaming/z_stmj.png",
            isNew = false,
            isOpenTingTips = false,
        },
        {
            id = "GAME_TYPE_ZHENGSHANGYOU",
            name = "争上游",
            destopskin = "gaming/z_asmj.pn",
            isNew = false,        
            isOpenTingTips = false,
        },


        {
            id = "GAME_TYPE_GUI_CHAO_SHAN",
            name = "潮汕鬼牌",
            destopSkin = "gaming/z_csgpmj.png",
            isNew = false,
            isOpenTingTips = false,
        },

        {
            id = "GAME_TYPE_HUI_LAI",
            name = "惠来麻将",
            destopSkin = "gaming/z_hlmj.png",
            isNew = false,
            isOpenTingTips = false,
        },
        {
            id = "GAME_TYPE_PU_NING",
            name = "普宁麻将",
            destopSkin = "gaming/z_pnmj.png",
            isNew = false,
            isOpenTingTips = false,
        },
    },

    -- 微信号
    weChat = "qyhjlb01",
    -- 活动领取红包公众号
    activityRedpackWechat = "潮汕雀友会互动娱乐",
    -- 能否分享战绩
    shareRecord = true,
    -- 分享图片地址
    shareImg = "art/chaoshan",
    -- 分享短链
    shareShortUrl =     {
        -- 大厅朋友分享
        main_friend = "ELl80gsk",
        -- 大厅朋友圈分享
        main_group = "ELVF9Yhg",
        -- 大厅系统分享
        main_system = "ELVF9Yhg",
    },
    -- 能否分享战绩
    shareRecord = true,
    clubHelpTxt = [[1、玩家可联系雀友会代理为自己创建好友圈与充值好友圈钻石，成为好友圈群主。
2、其他玩家加入好友圈后，打牌自动扣除群主身上的好友圈钻石，无需再为玩家充值。
3、在好友圈内玩家创建房间，只有同一好友圈内的玩家才可加入。
4、玩家可以快捷加入同一好友圈玩家创建的房间。
5、玩家可自由查询在好友圈中的战绩，包括赢家信息和最终成绩。
如需创建好友圈及购买好友圈钻石，请联系“雀友会”代理。如有疑问，请联系客服微信qyhmj8。]],

    --新增地区配置 
    --key(规则代码) 与 value(局数)的对应
    roundType = {
        [1] = 4,
        [2] = 8,
        [3] = 16
    },
    --key(局数规则代码) 与 value(耗钻数量)的对应
    roomCost = {
        [1] = 2,
        [2] = 3,
        [3] = 6,
    },
    --设置游戏桌面背景图片资源
    playerSceneBgImg = {
        bgImg = "gaming/Img_chaoshan.png",
        bgImg_3d = "",
        textImg = ""
    },
    --是否开启规则盒子
    isShowRuleBox = true,

    safeNotices = [[亲爱的玩家：
	随着《雀友会广东潮汕麻将》的成功，市面上有不法分子借着所谓的升级、创新等旗号推出仿冒山寨产品。这些未经审核的非法产品不仅侵犯了我方的权益，同时也对玩家的隐私、财产安全造成了巨大风险。《雀友会广东潮汕麻将》郑重声明，这些产品与我方无任何关系，请认准唯一正版的《雀友会广东潮汕麻将》！
	《雀友会广东潮汕麻将》拥有中国版权保护中心审查通过的《计算机软件著作权》，及国家新闻出版广播电影电视总局批准核发的《网络游戏出版物号（ISBN）》，并荣获“天府奖2017年度最佳休闲棋牌游戏”，请广大用户放心游戏。]],


    HuAnis = {
        [PlayType.HU_DIAN_PAO] = { pfx = "ui/csb/Effect_dianpao.csb", sfx = Constants.SFX_OpKey.DianPao },
        [PlayType.HU_ZI_MO] = { pfx = "ui/csb/Effect_zimo.csb", sfx = Constants.SFX_OpKey.ZiMo },
        -- [PlayType.HU_GANG_SHANG_HUA] = { pfx= ui.tx_gangshanghuaUI, sfx= "" },
        -- [PlayType.HU_QIANG_GANG_HU] = { pfx= ui.tx_qiangganghuUI, sfx= "" },
        [PlayType.DISPLAY_JI_FANPAI] = { pfx = "ui/csb/Effect_zhuoji.csb", sfx = Constants.NONE },
        [PlayType.DISPLAY_JI_CHUIFENG] = { pfx = "ui/csb/Effect_chuifengji.csb", sfx = Constants.NONE },
        -- 加上潮汕有的
        [PlayType.HU_HAI_DI_LAO_YUE]    = { pfx = "ui/csb/Effect_haidilaoyue.csb", sfx = Constants.NONE },
        [PlayType.HU_GANG_SHANG_HUA]    = { pfx = "ui/csb/Effect_gangbao.csb",    sfx = Constants.NONE },
        [PlayType.HU_QIANG_GANG_HU]    = { pfx = "ui/csb/Effect_qiangganghu.csb", sfx = Constants.NONE },
    },
    -- UIRoom_Hu 中的延时时间
    HU_WAIT_TIME = {
        1, 2
    },

    mainButtons = {
        'songzuan', 'setting', 'activity', 'message', 'help', 'history', 'share', 'bag', 'agent_before', 'agent_after', 'shop', 'tree', 'zuanshi',
        'gamble', 'fanpai', 'question', 'question_ok'
    }
}

CHAOSHAN.gameType = _gameType

-- 创建房间界面配置
local _roomSettings = {
    -- 潮汕麻将
    GamePlay_ChaoShan.roomSetting,
    -- 潮州麻将
    GamePlay_ChaoZhou.roomSetting,
    -- 鬼潮汕麻将
    GamePlay_GuiChaoShan.roomSetting,
    -- 普宁麻将
    GamePlay_PuNing.roomSetting,
    -- 汕头麻将
    GamePlay_ShanTou.roomSetting,
    -- 惠来麻将
    GamePlay_HuiLai.roomSetting,
    -- 争上游
    GamePlay_ZhengShangYou.roomSetting,
}

-- 玩法特殊字体文字配置
local _commonEvents = {
    ["GAME_TYPE_CHAO_SHAN"] = GamePlay_ChaoShan.commonEvent,
    ["GAME_TYPE_CHAO_ZHOU"] = GamePlay_ChaoZhou.commonEvent,
    ["GAME_TYPE_GUI_CHAO_SHAN"] = GamePlay_GuiChaoShan.commonEvent,
    ["GAME_TYPE_PU_NING"] = GamePlay_PuNing.commonEvent,
    ["GAME_TYPE_SHAN_TOU"] = GamePlay_ShanTou.commonEvent,
    ["GAME_TYPE_HUI_LAI"] = GamePlay_HuiLai.commonEvent,
    ["GAME_TYPE_ZHENGSHANGYOU"] = GamePlay_ZhengShangYou.commonEvent,
}

CHAOSHAN.roomSettings = _roomSettings
CHAOSHAN.commonEvents = _commonEvents

local _registCommands = function(gameType)
    local cmds = {
        ["GAME_TYPE_CHAO_SHAN"] = GamePlay_ChaoShan.commands,
        ["GAME_TYPE_CHAO_ZHOU"] = GamePlay_ChaoZhou.commands,
        ["GAME_TYPE_GUI_CHAO_SHAN"] = GamePlay_GuiChaoShan.commands,
        ["GAME_TYPE_PU_NING"] = GamePlay_PuNing.commands,
        ["GAME_TYPE_SHAN_TOU"] = GamePlay_ShanTou.commands,
        ["GAME_TYPE_HUI_LAI"] = GamePlay_HuiLai.commands,
        ["GAME_TYPE_ZHENGSHANGYOU"] = GamePlay_ZhengShangYou.commands,
    }
    CommandCenter.getInstance():unregistAll()
    CommandCenter.getInstance():registCommands(cmds[gameType])
end

local _registReplayCommands = function(gameType)
    local cmds = {
        ["GAME_TYPE_CHAO_SHAN"] = GamePlay_ChaoShan.replayCommands,
        ["GAME_TYPE_CHAO_ZHOU"] = GamePlay_ChaoZhou.replayCommands,
        ["GAME_TYPE_GUI_CHAO_SHAN"] = GamePlay_GuiChaoShan.replayCommands,
        ["GAME_TYPE_PU_NING"] = GamePlay_PuNing.replayCommands,
        ["GAME_TYPE_SHAN_TOU"] = GamePlay_ShanTou.replayCommands,
        ["GAME_TYPE_HUI_LAI"] = GamePlay_HuiLai.replayCommands,
        ["GAME_TYPE_ZHENGSHANGYOU"] = GamePlay_ZhengShangYou.replayCommands,
    }
    CommandCenter.getInstance():unregistAll()
    CommandCenter.getInstance():registCommands(cmds[gameType])
end

CHAOSHAN.registCommands = _registCommands
CHAOSHAN.registReplayCommands = _registReplayCommands

-- ui
local _uiConfig = {}
table.merge(_uiConfig, GamePlay_ChaoShan.UIConfig)
table.merge(_uiConfig, GamePlay_ChaoZhou.UIConfig)
table.merge(_uiConfig, GamePlay_GuiChaoShan.UIConfig)
table.merge(_uiConfig, GamePlay_PuNing.UIConfig)
table.merge(_uiConfig, GamePlay_ShanTou.UIConfig)
table.merge(_uiConfig, GamePlay_HuiLai.UIConfig)
table.merge(_uiConfig, GamePlay_ZhengShangYou.UIConfig)
CHAOSHAN.UIConfig = _uiConfig

-- 好友圈禁用玩法
local _registForbidPlay = {
}

CHAOSHAN.registForbidPlay = _registForbidPlay

local _registRuleType = {
    --/**房主扣钻 */
    PAYTYPE_BY_HORSEOWNER = { 11, "房主扣钻", "payType", "fz" },
    --/**AA扣钻 */
    PAYTYPE_BY_AA = { 13, "AA扣钻", "payType", "aa" },
    --/**经理扣钻 */
    PAYTYPE_BY_MANAGER = { 14, "经理扣钻", "payType", "manager" },
    --/** 房间4局 */
    ROOM_ROUND_COUNT_4 = { 1, "4局", "4局 钻石x1/人", "4j" },
    --/** 房间8局 */
    ROOM_ROUND_COUNT_8 = { 2, "8局", "8局 钻石x1/人", "8j" },
    --/** 房间16局 */
    ROOM_ROUND_COUNT_16 = { 3, "16局", "16局 钻石x2/人", "16j" },

    --/** 潮汕玩法 */
    GAME_TYPE_CHAO_SHAN = { bit.bxor(CONST_LSHIFT_1, 1), "潮汕麻将", "type", "cs" },
    --/** 推到胡 */
    GAME_TYPE_TUI_DAO_HU = { bit.bxor(CONST_LSHIFT_1, 2), "推到胡", "type", "tdh" },
    --/** 潮汕鬼牌玩法 */
    GAME_TYPE_GUI_CHAO_SHAN = { bit.bxor(CONST_LSHIFT_1, 3), "潮汕鬼牌", "type", "gpcs" },
    --/** 潮州门清玩法 */
    GAME_TYPE_CHAO_ZHOU = { bit.bxor(CONST_LSHIFT_1, 4), "潮州门清", "type", "czmq" },
    --/**汕尾玩法 */
    GAME_TYPE_SHAN_WEI = { bit.bxor(CONST_LSHIFT_1, 5), "汕尾麻将", "type", "sw" },
    --/**汕头玩法 */
    GAME_TYPE_SHAN_TOU = { bit.bxor(CONST_LSHIFT_1, 6), "汕头麻将", "type", "st" },
    --/** 普宁玩法 */
    GAME_TYPE_PU_NING = { bit.bxor(CONST_LSHIFT_1, 7), "普宁麻将", "type", "pn" },
    --/** 惠来玩法 */
    GAME_TYPE_HUI_LAI = { bit.bxor(CONST_LSHIFT_1, 8), "惠来麻将", "type", "hl" },
    --/** 揭西玩法 */
    GAME_TYPE_JIE_XI = { bit.bxor(CONST_LSHIFT_1, 9), "揭西麻将", "type", "jx" },
    --/** 无万(广东=无字) */
    GAME_PLAY_NO_WAN = { bit.bxor(CONST_LSHIFT_2, 1), "无字", "rule", "wz" },
    --/** 无字 (广东=无风) */
    GAME_PLAY_NO_ZI = { bit.bxor(CONST_LSHIFT_2, 2), "无风", "rule", "wf" },
    --/** 三人玩法 */
    GAME_PLAY_THREE_PLAYER = { bit.bxor(CONST_LSHIFT_2, 3), "三人玩法", "rule", "3p" },
    --/** 四人玩法 */
    GAME_PLAY_FOUR_PLAYER = { bit.bxor(CONST_LSHIFT_2, 4), "四人玩法", "rule", "4p" },
    --/** 二人玩法 */
    GAME_PLAY_TWO_PLAYER = { bit.bxor(CONST_LSHIFT_2, 5), "二人玩法", "rule", "2p" },
    --/** 吃胡 */
    Hu_DIAN_HU = { bit.bxor(CONST_LSHIFT_3, 1), "吃胡", "hu", "ch" },
    --/** 自摸(20分以上可以吃胡) */
    Hu_ZI_MO = { bit.bxor(CONST_LSHIFT_3, 2), "自摸", "hu", "zm" },
    --/** 自摸胡目标听牌牌形10分限制 */
    HU_ZI_MO_TARGET_SCORE_LIMIT = { bit.bxor(CONST_LSHIFT_3, 3), "自摸（10倍不计分）", "hu", "zm10" },
    --/** 潮州十倍不计分 */
    SHI_BEI_BU_JI_FEN = { bit.bxor(CONST_LSHIFT_3, 4), "10倍不计分", "hu", "zm10" },
    --/** 汕头自摸 */
    HU_ZI_MO_SHAN_TOU = { bit.bxor(CONST_LSHIFT_3, 5), "自摸", "hu", "stzm" },
    --/* 汕头20分可吃胡 */
    HU_CHI_HU_ZI_MO_LIMIT = { bit.bxor(CONST_LSHIFT_3, 6), "20分可吃胡", "hu", "20kch" },

    --/** 小胡 */
    SCORE_XIAO_HU = { bit.bxor(CONST_LSHIFT_4, 1), "小胡", "multiple", "xh" },
    --/** 鸡胡不能吃胡 */
    SCORE_XIAO_HU_WITHOUT_DIAN_HU = { bit.bxor(CONST_LSHIFT_4, 2), "鸡胡不能吃胡", "multiple", "jhbch" },
    --/** 跟庄 */
    SCORE_GEN_ZHUANG = { bit.bxor(CONST_LSHIFT_4, 3), "跟庄", "multiple", "gz" },

    --/** 三番起胡 */
    SAN_FAN_QI_HU = { bit.bxor(CONST_LSHIFT_4, 4), "3番起胡", "hu", "3fqh" },
    --/** 流局算杠 */
    LIU_JU_SUAN_GANG = { bit.bxor(CONST_LSHIFT_4, 5), "流局算杠", "hu", "ljsg" },
    --/** 跟庄1分*/
    SCORE_GEN_ZHUANG_YI_FEN = { bit.bxor(CONST_LSHIFT_4, 6), "跟庄一分", "multiple", "gzyf" },
    --/** 跟庄2分*/
    SCORE_GEN_ZHUANG_LIANG_FEN = { bit.bxor(CONST_LSHIFT_4, 7), "跟庄二分", "multiple", "gzlf" },
    --/** 跟庄2分*/
    SCORE_LIAN_ZHUANG = { bit.bxor(CONST_LSHIFT_4, 8), "连庄", "multiple", "lz" },
    --/** 必胡 */
    SCORE_MUST_HU = { bit.bxor(CONST_LSHIFT_4, 9), "必胡", "hu", "bh" },
    --/** 最后一圈不能碰 */
    CANNT_PENG_IN_LAST_CIRCLE = { bit.bxor(CONST_LSHIFT_13, 1), "最后一圈不能碰", "peng", "zhyqbnp" },
    --/** 鸡胡 */
    SCORE_JI_HU = { bit.bxor(CONST_LSHIFT_4, 10), "鸡胡", "hu", "jh" },
    --/** 鸡大 */
    SCORE_JI_DA = { bit.bxor(CONST_LSHIFT_4, 11), "鸡大", "hu", "jd" },

    --/** 封顶5倍 */
    SCORE_LIMIT_5 = { bit.bxor(CONST_LSHIFT_5, 1), "封顶5倍", "max", "fd5" },
    --/** 封顶10倍 */
    SCORE_LIMIT_10 = { bit.bxor(CONST_LSHIFT_5, 2), "封顶10倍", "max", "fd10" },
    --/** 不设封顶 */
    SCORE_LIMIT_NONE = { bit.bxor(CONST_LSHIFT_5, 3), "不设封顶", "max", "wfd" },
    --/** 杠跟底分 */
    GANG_GEN_DI_FEN = { bit.bxor(CONST_LSHIFT_5, 4), "杠跟底分", "max", "ggdf" },

    MASTER_CARD_NONE = { bit.bxor(CONST_LSHIFT_6, 1), "无鬼", "gui", "wg" },
    --/** 鬼牌_红中 */
    MASTER_CARD_HONG_ZHONG = { bit.bxor(CONST_LSHIFT_6, 2), "红中做鬼", "gui", "hzg" },
    --/** 鬼牌_白板 */
    MASTER_CARD_BAI_BAN = { bit.bxor(CONST_LSHIFT_6, 3), "白板做鬼", "gui", "bbg" },
    --/** 鬼牌_翻鬼 */
    MASTER_CARD_GENERATE = { bit.bxor(CONST_LSHIFT_6, 4), "翻鬼", "gui", "fg" },
    --/** 鬼牌_双鬼 */
    MASTER_CARD_TOW_MASTER = { bit.bxor(CONST_LSHIFT_6, 5), "双鬼", "gui", "sg" },
    --/** 鬼牌_无鬼加倍 */
    MASTER_CARD_NONE_DOUBLE = { bit.bxor(CONST_LSHIFT_6, 6), "无鬼加倍", "gui", "wgjb" },
    --/** 鬼牌_四鬼胡牌 */
    MASTER_CARD_FORE_HU = { bit.bxor(CONST_LSHIFT_6, 7), "四鬼胡牌", "gui", "sghp" },
    --/** 鬼牌_双倍 */
    MASTER_CARD_DOUBLE_SCORE = { bit.bxor(CONST_LSHIFT_6, 8), "四鬼胡牌（双倍）", "gui", "sb" },

    BETTING_HORSE_0 = { bit.bxor(CONST_LSHIFT_7, 1), "无马", "ma", "wm" },
    --/** 马牌_2马 */
    BETTING_HORSE_2 = { bit.bxor(CONST_LSHIFT_7, 2), "2马", "ma", "2m" },
    --/** 马牌_5马 */
    BETTING_HORSE_5 = { bit.bxor(CONST_LSHIFT_7, 3), "5马", "ma", "5m" },
    --/** 马牌_8马 */
    BETTING_HORSE_8 = { bit.bxor(CONST_LSHIFT_7, 4), "8马", "ma", "8m" },
    --/** 马牌_马跟杠 */
    BETTING_HORSE_WITH_GANG = { bit.bxor(CONST_LSHIFT_7, 5), "马跟杠", "ma", "mgg" },
    --/** 马牌_马跟牌分 */
    BETTING_HORSE_MA_GEN_PAI = { bit.bxor(CONST_LSHIFT_7, 6), "马跟牌分", "ma", "mgp" },
    --/** 马牌_1马 */
    BETTING_HORSE_1 = { bit.bxor(CONST_LSHIFT_7, 7), "1马", "ma", "1m" },
    --/** 奖马翻倍 */
    BETTING_HORSE_DOUBLE = { bit.bxor(CONST_LSHIFT_7, 8), "奖马翻倍", "ma", "jmfb" },
    --/** 奖马加番 */
    BETTING_HORSE_ADD_FAN = { bit.bxor(CONST_LSHIFT_7, 9), "奖马加番", "ma", "jmjf" },
    --/** 番数_2番 */
    FAN_2 = { bit.bxor(CONST_LSHIFT_7, 10), "奖马加2番", "fan", "2fan" },
    --/** 番数_4番 */
    FAN_4 = { bit.bxor(CONST_LSHIFT_7, 11), "奖马加4番", "fan", "4fan" },
    --/** 番数_6番 */
    FAN_6 = { bit.bxor(CONST_LSHIFT_7, 12), "奖马加6番", "fan", "6fan" },
    --/** 马牌_3马 */
    BETTING_HORSE_3 = { bit.bxor(CONST_LSHIFT_7, 13), "3马", "ma", "3ma" },

    --/** 可以抢杠胡 */
    CAN_QIANG_GANG_HU = { bit.bxor(CONST_LSHIFT_8, 1), "抢杠胡", "extend", "qgh" },
    --/** 抢杠全包 */
    QIANG_GANG_QUAN_BAO = { bit.bxor(CONST_LSHIFT_8, 2), "抢杠全包", "extend", "qgqb" },

    --/** 七对2倍 */
    QI_DUI_DOUBLE = { bit.bxor(CONST_LSHIFT_9, 1), "七对2倍", "extend", "7d2" },
    --/** 七对4倍 */
    QI_DUI_FOUR_TIMES = { bit.bxor(CONST_LSHIFT_9, 2), "七对4倍", "extend", "7d4" },
    --/** 碰碰胡2倍 */
    PENG_PENG_HU_DOUBLE = { bit.bxor(CONST_LSHIFT_9, 3), "碰碰胡2倍", "extend", "pp2" },
    --/** 清一色4倍 */
    QING_YI_SE_FOUR_TIMES = { bit.bxor(CONST_LSHIFT_9, 4), "清一色4倍", "extend", "qys4" },
    --/** 全风8倍 */
    QUANG_FENG_EIGHT_TIMES = { bit.bxor(CONST_LSHIFT_9, 5), "全风8倍", "extend", "qf8" },
    --/** 十三幺8倍 */
    SHI_SAN_YAO_EIGHT_TIMES = { bit.bxor(CONST_LSHIFT_9, 6), "十三幺8倍", "extend", "13y8" },
    --/** 幺九6倍 */
    YAO_JIU_SIX_TIMES = { bit.bxor(CONST_LSHIFT_9, 7), "幺九6倍", "extend", "yj6" },
    --/** 抢杠胡3倍 */
    QIANG_GANG_HU_THREE = { bit.bxor(CONST_LSHIFT_9, 8), "抢杠胡全包", "extend", "qgh3" },
    --/** 海底捞月2倍 */
    HAI_DI_LAO_YUE_DOUBLE = { bit.bxor(CONST_LSHIFT_9, 9), "海底捞月2倍", "extend", "hdly2" },
    --/** 杠爆2倍 */
    GANG_BAO_DOUBLE = { bit.bxor(CONST_LSHIFT_9, 10), "杠爆2倍", "extend", "gb2" },
    --/** 吃杠杠爆全包 */
    CHI_GANG_GANG_BAO_QUAN_BAO = { bit.bxor(CONST_LSHIFT_9, 11), "吃杠杠爆全包", "extend", "cggbqb" },

    --// 汕头大牌型
    --/** 全牌型 */
    SHAN_TOU_QUAN_PAI_XING = { bit.bxor(CONST_LSHIFT_10, 1), "全牌型2分", "extend", "qpx2f" },
    --/** 小胡（鸡胡两分，未选牌型4分） */
    SHAN_TOU_XIAO_HU = { bit.bxor(CONST_LSHIFT_10, 2), "小胡", "extend", "xh" },
    --/** 大胡（汕头） */
    SHAN_TOU_DA_HU = { bit.bxor(CONST_LSHIFT_10, 3), "大胡", "extend", "dh" },

    --// 汕头具体牌型
    --/** 碰碰胡4分 */
    SHAN_TOU_PENG_PENG_HU = { bit.bxor(CONST_LSHIFT_11, 1), "碰碰胡4分", "extend", "pph4f" },
    --/** 混一色4分 */
    SHAN_TOU_HUN_YI_SE = { bit.bxor(CONST_LSHIFT_11, 2), "混一色4分", "extend", "hys4f" },
    --/** 清一色4分 */
    SHAN_TOU_QING_YI_SE = { bit.bxor(CONST_LSHIFT_11, 3), "清一色4分", "extend", "qys4f" },
    --/** 一条龙6分 */
    SHAN_TOU_YI_TIAO_LONG = { bit.bxor(CONST_LSHIFT_11, 4), "一条龙6分", "extend", "ytl6f" },
    --/** 一九10分 */
    SHAN_TOU_YAO_JIU = { bit.bxor(CONST_LSHIFT_11, 5), "一九10分", "extend", "yj10f" },
    --/** 小三元10分 */
    SHAN_TOU_XIAO_SAN_YUAN = { bit.bxor(CONST_LSHIFT_11, 6), "小三元10分", "extend", "xsy10f" },
    --/** 小四喜10分 */
    SHAN_TOU_XIAO_SI_XI = { bit.bxor(CONST_LSHIFT_11, 7), "小四喜10分", "extend", "xsx10f" },
    --/** 字一色20分 */
    SHAN_TOU_ZI_YI_SE = { bit.bxor(CONST_LSHIFT_11, 8), "字一色20分", "extend", "zys10f" },
    --/** 十三幺26分 */
    SHAN_TOU_SHI_SAN_YAO = { bit.bxor(CONST_LSHIFT_11, 9), "十三幺26分", "extend", "ssy26f" },
    --/** 大三元20分 */
    SHAN_TOU_DA_SAN_YUAN = { bit.bxor(CONST_LSHIFT_11, 10), "大三元20分", "extend", "dsy20f" },
    --/** 大四喜20分 */
    SHAN_TOU_DA_SI_XI = { bit.bxor(CONST_LSHIFT_11, 11), "大四喜20分", "extend", "dsx20f" },
    --/** 十八罗汉36分 */
    SHAN_TOU_SHI_BA_LUO_HAN = { bit.bxor(CONST_LSHIFT_11, 12), "十八罗汉36分", "extend", "sblh36f" },
    --/** 七对6、豪七10、双豪20、三豪30 */
    SHAN_TOU_QI_DUI_ALL = { bit.bxor(CONST_LSHIFT_11, 13), "七对6、豪七10、双豪20、三豪30分", "extend", "stqd" },
    --/** 天胡40分、地胡20分 */
    SHAN_TOU_TIAN_DI = { bit.bxor(CONST_LSHIFT_11, 14), "天胡40分、地胡20分", "extend", "td40dh20" },


    --/** 无买马*/
    NO_BUY_HORSE = { bit.bxor(CONST_LSHIFT_12, 1), "无买马", "maima", "wmm" },
    --/** 买1马 */
    BUY_HORSE_1 = { bit.bxor(CONST_LSHIFT_12, 2), "买1马", "maima", "m1m" },
    -- "买2马
    BUY_HORSE_2 = { bit.bxor(CONST_LSHIFT_12, 3), "买2马", "maima", "m2m" },
    -- 罚1马"
    PUNISH_HORSE_1 = { bit.bxor(CONST_LSHIFT_12, 4), "罚1马", "fama", "f1m" },
    -- "罚2马"
    PUNISH_HORSE_2 = { bit.bxor(CONST_LSHIFT_12, 5), "罚2马", "fama", "f2m" },


    -- -- 实时语音开
    -- GAME_PLAY_COMMON_VOICE_OPEN = {RoomSetting.GamePlay.COMMON_VOICE_OPEN, "实时语音", "rule", "yuyk"},
    -- -- 实时语音关
    -- GAME_PLAY_COMMON_VOICE_CLOSE = {RoomSetting.GamePlay.COMMON_VOICE_CLOSE, "", "rule", "yuyg"},
    -- 听牌提示开
    GAME_PLAY_COMMON_TING_TIPS_OPEN = { RoomSetting.GamePlay.COMMON_TING_TIPS_OPEN, "听牌提示", "rule", "yuyk" },
    -- 听牌提示关
    GAME_PLAY_COMMON_TING_TIPS_CLOSE = { RoomSetting.GamePlay.COMMON_TING_TIPS_CLOSE, "", "rule", "yuyg" },

}

CHAOSHAN.registRuleType = _registRuleType
table.merge(CHAOSHAN.registRuleType, GamePlay_ZhengShangYou.registRuleType)

CHAOSHAN.getGameUI = function(gamePlay, uiType)
    local uis = {
        [GamePlay_ZhengShangYou.roomSetting._gameType] = GamePlay_ZhengShangYou.registGameUI,
    }
    local registGameUi = nil
    if uis[gamePlay] ~= nil then
        registGameUi = uis[gamePlay][uiType]
    end


    return registGameUi
end


return CHAOSHAN
