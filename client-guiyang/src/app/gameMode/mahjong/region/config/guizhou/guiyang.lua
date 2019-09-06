local CommandCenter = require("app.manager.CommandCenter")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local room = require( "app.game.ui.RoomSettingDefine" )
local RoomSetting = config.GlobalConfig.getRoomSetting()

local utils = require("app.gameMode.mahjong.region.config.AreaCfgUtils")

-- 子玩法
local GamePlay_AnShun_GuiYang = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_AnShun_GuiYang")
local GamePlay_GuiYang = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_GuiYang")
local GamePlay_LiangDing = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_LiangDing")
local GamePlay_ZunYi = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_ZunYi")
local GamePlay_AnLong = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_AnLong")
local GamePlay_TongRen = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_TongRen")
local GamePlay_LiangFang = require("app.gameMode.mahjong.region.gamePlays.guizhou.GamePlay_LiangFang")
local GamePlay_Paodekuai = require("app.gameMode.paodekuai.region.gamePlays.guizhou.GamePlay_Paodekuai")

local GUIYANG = {}

local _gameType = {
    name = "贵阳麻将",
    gameTypes = {
        {
            id = "GAME_TYPE_R_GUIYANG",
            name = "贵阳麻将",
            destopSkin = "gaming/z_gyzj.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_LIANG_FANG",
            name = "两房麻将",
            destopSkin = "gaming/z_trmj.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_LIANGDING",
            name = "两丁一房",
            destopSkin = "gaming/z_gyzj.png",
            isNew = true,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_TONGREN",
            name = "铜仁麻将",
            destopSkin = "gaming/z_trmj.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_ANLONG",
            name = "闷胡血流",
            destopSkin = "gaming/z_mhxl.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_ZUNYI",
            name = "遵义麻将",
            destopSkin = "gaming/z_zymj.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_R_ANSHUN_GUIYANG",
            name = "安顺麻将",
            destopSkin = "gaming/z_asmj.png",
            isNew = false,
            isOpenTingTips = true,
        },
        {
            id = "GAME_TYPE_PAODEKUAI",
            name = "跑得快",
            destopSkin = "gaming/z_asmj.png",
            isNew = false,
            isOpenTingTips = false,
        }
    },
    -- 微信号
    weChat = "myqtr001",
    weChat1 = "myqtr002",
    -- 活动领取红包公众号
    activityRedpackWechat = "myqhd2017",
    -- 公众号
    noPublic = "myqhd2017",
    -- 能否分享战绩
    shareRecord = true,
    -- 分享图片地址
    shareImg = "art/guiyang",
    -- 战绩名片分享链接,测试域名需要改apid，已经agtzf开头的两个改成test.
    businessUrl = "http://agtzf.gzgy.gymjnxa.com/detailRecord?areaid=%s&roomId=%s&roomCreateTime=%s",
    -- 分享短链
    shareShortUrl =
    {
        -- 大厅朋友分享
        HALL_FRIENDS = "ELRFNdc0",
        -- 大厅朋友圈分享
        HALL_MOMENTS = "ELABxpso",
        -- 大厅系统分享
        HALL_SYSTEM = "ELFxxh4g",
    },
    clubHelpTxt = [[1、玩家可联系聚友代理为自己创建亲友圈与充值亲友圈卡，成为亲友圈群主。
2、其他玩家加入亲友圈后，打牌自动扣除群主身上的亲友圈卡，无需再为玩家充值。
3、在亲友圈内玩家创建房间，只有同一亲友圈内的玩家才可加入。
4、玩家可以快捷加入同一亲友圈玩家创建的房间。
5、玩家可自由查询在亲友圈中的战绩，包括赢家信息和最终成绩。
如需创建亲友圈及购买亲友圈房卡，请联系聚友代理。如有疑问，请联系客服微信myqgm009。]] ,
    --捉鸡寻宝捕捉器消耗房卡数目
    catcherCost = 10,

    --新增地区配置 
    --key(局数规则代码) 与 value(局数)的对应
    roundType = {
        [1] = 8,
        [2] = 16
    },
    --key(局数规则代码) 与 value(耗钻数量)的对应
    roomCost = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
    },
    --设置游戏桌面背景图片资源
    playerSceneBgImg = {
        bgImg = "gaming/Img_11.png" ,
        bgImg_3d = "gaming/Img_11_3D.png",
        textImg = "gaming/z_aqb.png",
        bgImgClassice = "gaming/Img_22.png",
        bgImgClassice_3d = "gaming/Img_22_3D.png",
    },
    --是否开启规则盒子
    isShowRuleBox = false,
   
    -- safeNotices = [[亲爱的玩家：
    -- 随着《聚友贵州麻将》的成功，市面上有不法分子借着所谓的升级、创新等旗号推出仿冒山寨产品。这些未经审核的非法产品不仅侵犯了我方的权益，同时也对玩家的隐私、财产安全造成了巨大风险。《聚友贵州麻将》郑重声明，这些产品与我方无任何关系，请认准唯一正版的《聚友贵州麻将》！
    -- 《聚友贵州麻将》拥有中国版权保护中心审查通过的《计算机软件著作权》，及国家新闻出版广播电影电视总局批准核发的《网络游戏出版物号（ISBN）》，并荣获“天府奖2017年度最佳休闲棋牌游戏”，请广大用户放心游戏。]],
    safeNotices = [[各位亲爱的麻友：
    作为“绿色娱乐、健康游戏”的践行者，聚友贵州麻将坚决拥护国家文化部近日关于规范网络游戏的发文，将继续加强游戏管理，维护游戏行业的健康发展，与广大玩家一同构建绿色、健康、可持续发展的游戏环境。

同时，我们郑重声明：
一、游戏中的结算成绩，仅用于对局的分数记录，在游戏结束时清零，仅限本人在游戏中使用，不具有任何货币价值，不可流通及交易；
二、游戏中的房卡属于游戏道具，仅能用于开设游戏房间，不具备其他任何用途；
三、聚友贵州麻将严禁用户之间进行任何赌博行为，对用户所拥有的积分、房卡等均不提供任何形式的官方回购、直接或间接兑换现金或实物、相互赠予转让等服务及相关功能；
四、聚友贵州麻将在游戏中已公布客服微信及官方公众号等联系方式，以供用户监督。一旦发现涉嫌赌博等违法行为，将第一时间封停相关人员的账号，情节严重者将移交公安机关进行处理。
    为了共同营造绿色健康的游戏环境，请各位用户文明游戏，远离赌博，拒绝违法违规行为！]],


    HuAnis = {
        [PlayType.HU_DIAN_PAO] = {pfx = "ui/csb/Effect_dianpao.csb", sfx = Constants.SFX_OpKey.DianPao},
        [PlayType.HU_ZI_MO] = {pfx = "ui/csb/Effect_zimo.csb", sfx = Constants.SFX_OpKey.ZiMo},
        -- [PlayType.HU_GANG_SHANG_HUA] = { pfx= ui.tx_gangshanghuaUI, sfx= "" },
        -- [PlayType.HU_QIANG_GANG_HU] = { pfx= ui.tx_qiangganghuUI, sfx= "" },
        [PlayType.DISPLAY_JI_FANPAI] = {pfx = "ui/csb/Effect_zhuoji.csb", sfx = Constants.NONE},
        [PlayType.DISPLAY_JI_CHUIFENG] = {pfx = "ui/csb/Effect_chuifengji.csb", sfx = Constants.NONE},
    },
    -- UIRoom_Hu 中的延时时间
    HU_WAIT_TIME = {
        2, 1
    },

    mainButtons = {
        'setting','activity','message','help','history','share','bag','agent_before','agent_after','customer_service','real_name','free_card','tree','zuanshi',
        'gamble',  'pullNew', "lucky_draw",'week_sign','qixi_charge',"bag",
        "more","monthsign","bindphone",
        "btnShuang11","Button_Comeback",
        "btnleaderboardActivity",
         "feedback",'redpack',
        "btnBlessing",
        -- 'qixi_two_gay','verified', 'verified_ok', "buyu","chuanqi",
        -- "friend",
        --'fanpai',
        -- "btnAccountRecovery",
         "egg",
        "btnChristmasSign","btnSpringInvited",
        "Button_CollectCode",
        "CollectCodeIcon",
        "ClubRed",
        "Nianbao",
        "Questionnare",
        "welfare",
        "ufo_catcher"
    },
    
    -- 解散房间原因列表配置
    reasonForm =
    {
        {type = "gamePlay", id = 0, name = "玩法问题"},
        {type = "gamePlay", id = bit.bxor(bit.lshift(1, 16), 1), name = "玩法算分错误"},
        {type = "gamePlay", id = bit.bxor(bit.lshift(1, 16), 2), name = "鸡牌算分错误"},
        {type = "gamePlay", id = bit.bxor(bit.lshift(1, 16), 3), name = "豆算分错误"},
        {type = "otherReason", id = 0, name = "其他原因"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 1), name = "临时有事"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 2), name = "有玩家离线"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 3), name = "其他玩家出牌太慢"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 4), name = "系统卡顿"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 5), name = "网速不稳定"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 6), name = "设备电量不足"},
        {type = "otherReason", id = bit.bxor(bit.lshift(2, 16), 7), name = "玩法选择错误"},
        {type = "otherReason", id = bit.bxor(bit.lshift(6, 16), 1), name = "其他"},
    }
       
}
-- GUIYANG.mainButtons = _registRuleType

GUIYANG.gameType = _gameType

-- 亲友圈禁用玩法
local _registForbidPlay = {
    {name = "本鸡",         gamePlayId = RoomSetting.GamePlay.CHICKEN_BENJI,     ruleSetName = "GAME_PLAY_CHICKEN_BENJI"},
    {name = "乌骨鸡",       gamePlayId = RoomSetting.GamePlay.CHICKEN_WUGU,      ruleSetName = "GAME_PLAY_CHICKEN_WUGU" },
    {name = "吹风鸡",       gamePlayId = RoomSetting.GamePlay.CHICKEN_CHUIFENG,     ruleSetName = "GAME_PLAY_CHICKEN_CHUIFENG"},
    {name = "星期鸡",       gamePlayId = RoomSetting.GamePlay.CHICKEN_XINQQI,     ruleSetName = "GAME_PLAY_CHICKEN_XINQQI"},
}

GUIYANG.registForbidPlay = _registForbidPlay

-- 地区玩法
local _registRuleType = {
    -- /** 贵阳玩法 */
    GAME_TYPE_R_GUIYANG= {RoomSetting.GamePlay.REGION_GUIYANG, "贵阳麻将", "type", "guiyang"},
    --/** 安龙玩法 */
    GAME_TYPE_R_ANLONG = {RoomSetting.GamePlay.REGION_ANLONG, "闷胡血流", "type", "anlong"},
    --/** 遵义玩法 */
    GAME_TYPE_R_ZUNYI = {RoomSetting.GamePlay.REGION_ZUNYI, "遵义麻将", "type", "zunyi"},
    --/** 贵阳安顺玩法 */
    GAME_TYPE_R_ANSHUN_GUIYANG = {RoomSetting.GamePlay.REGION_ANSHUN_GUIYANG, "安顺麻将", "type", "anshun"},
    -- 铜仁玩法
    GAME_TYPE_R_TONGREN = {RoomSetting.GamePlay.REGION_TONGREN, "铜仁麻将", "type", "anshun"},
    -- 两房玩法
    GAME_TYPE_R_LIANG_FANG = {RoomSetting.GamePlay.REGION_LIANGFANG, "两房玩法", "type", "liangfang"},
    -- 两丁一房
    GAME_TYPE_R_LIANGDING = {RoomSetting.GamePlay.REGION_LIANGDING, "两丁一房", "type", "liangdingyifang"},
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
    --/**首圈鸡*/
    GAME_PLAY_CHOUQUANJI_CHUIFENG = {RoomSetting.GamePlay.CHICKEN_SHOUQUAN, "首圈鸡", "rule", "sqj"},
    --/*银鸡*/
    GAME_PLAY_YINJI_CHUIFENG = {RoomSetting.GamePlay.CHECKEN_YIN, "银鸡", "rule", "yj"},

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
    --/**红中*/
    GAME_PLAY_CHICKEN_HONGZHONG = {RoomSetting.GamePlay.CHICKEN_HONGZHONG, "红中", "rule", "dil"},

    --/**闷胡*/
    GAME_PLAY_MEN_HU = {RoomSetting.GamePlay.GAMEPLAY_MENHU, "闷胡血流", "rule", "menhu"},
    -- 打一张可报听
    GAME_PLAY_TING_CARD = {RoomSetting.GamePlay.GAMEPLAY_TINGCARD, "打一张可报听", "rule", "dapkbt1"},
    -- 打两张可报听
    GAME_PLAY_TING_SECOND_CARD = {RoomSetting.GamePlay.GAME_PLAY_TING_SECOND_CARD, "打两张可报听", "rule", "dapkbt2"},
    --打牌不报听
    GAME_PLAY_NO_TING_CARD = {RoomSetting.GamePlay.GAME_PLAY_NO_TING_CARD, "打牌不报听", "rule", "dapbkbt"},
    --/**小胡必闷*/
    GAME_PLAY_XIAO_HU_BI_MEN  = {RoomSetting.GamePlay.GAME_PLAY_XIAO_HU_BI_MEN , "小胡必闷", "rule", "xiaohubimen"},
    -- 连胡
    GAME_PLAY_LIAN_HU = {RoomSetting.GamePlay.GAME_PLAY_LIAN_HU , "连胡", "rule", "lianhu"},

    --/**一扣二 */
    GAME_PLAY_BANKER_ONE = {RoomSetting.GamePlay.BANKER_ONE, "一扣二", "rule", "yike"},
    --/**连庄*/
    GAME_PLAY_BANKER_SERIES = {RoomSetting.GamePlay.BANKER_SERIES, "连庄", "rule", "lianzh"},
    --/**通三*/
    GAME_PLAY_BANKER_TONGSAN = {RoomSetting.GamePlay.BANKER_TONGSAN, "通三", "rule", "tongs"},
    --/**烧鸡烧豆*/
    GAME_PLAY_SHAO_JI_SHAO_DOU = {RoomSetting.GamePlay.GAME_PLAY_SHAO_JI_SHAO_DOU, "烧鸡烧豆", "rule", "lianzh"},
    --/**包鸡*/
    GAME_PLAY_BAO_JI = {RoomSetting.GamePlay.GAME_PLAY_BAO_JI, "包鸡", "rule", "tongs"},
    --/**包豆*/
    GAME_PLAY_BAO_DOU = {RoomSetting.GamePlay.GAME_PLAY_BAO_DOU, "包豆", "rule", "tongs"},

    --/**一扣三*/
    GAME_PLAY_YIKOUSAN = {RoomSetting.GamePlay.GAME_PLAY_YIKOUSAN, "一扣三", "rule", "tongs"},

    --/**热炮必胡*/
    GAME_PLAY_HOT_PAO_MUST_HU = {RoomSetting.GamePlay.GAME_PLAY_HOT_PAO_MUST_HU , "热炮必胡", "rule", "repaobihu"},

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
   --/**估卖*/
   GAME_PLAY_GU_MAI = {RoomSetting.GamePlay.GAMEPLAY_GUMAI, "估卖", "rule", "menhu"},
   --/** 鬼牌_翻鬼 */
   MASTER_CARD_GENERATE = {RoomSetting.GamePlay.LAIZIJI, "癞子鸡", "gui", "fg" },

   -- 不托管
   TRUSTEESHIP_NO = {RoomSetting.GamePlay.COMMON_TRUSTEESHIP_CLOSE, "不托管", "gui", "fg" }, 
   -- 60秒托管
   TRUSTEESHIP_60 = {RoomSetting.GamePlay.COMMON_TRUSTEESHIP_60, "60秒托管", "gui", "fg" }, 
   -- 180秒托管
   TRUSTEESHIP_180 = {RoomSetting.GamePlay.COMMON_TRUSTEESHIP_180, "180秒托管", "gui", "fg" },
   -- 300秒托管
   TRUSTEESHIP_300 = {RoomSetting.GamePlay.COMMON_TRUSTEESHIP_300, "300秒托管", "gui", "fg" },
}

GUIYANG.registRuleType = _registRuleType

local gameplays = {
    ["GAME_TYPE_R_TONGREN"] = GamePlay_TongRen,
    ["GAME_TYPE_R_GUIYANG"] = GamePlay_GuiYang,
    ["GAME_TYPE_R_LIANGDING"] = GamePlay_LiangDing,
	["GAME_TYPE_R_ANLONG"] = GamePlay_AnLong,
	["GAME_TYPE_R_ZUNYI"] = GamePlay_ZunYi,
	["GAME_TYPE_R_ANSHUN_GUIYANG"] = GamePlay_AnShun_GuiYang,
	["GAME_TYPE_PAODEKUAI"] = GamePlay_Paodekuai,
	["GAME_TYPE_R_LIANG_FANG"] = GamePlay_LiangFang,
}
-- setfenv(utils.addGamePlays, {_G = GUIYANG, _g = _G})
utils.addGamePlays(GUIYANG, gameplays)

return GUIYANG