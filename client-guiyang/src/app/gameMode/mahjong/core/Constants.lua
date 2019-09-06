local bit      = require("bit")
local CardType = require("app.gameMode.mahjong.core.CardDefines").CardType
local room        = require("app.game.ui.RoomSettingHelper")

local Constants = class("Constants")

--[[module battle {
	import CardType = CardDefines.CardType;
--]]
local SFX_OpKey = {
    Peng         = 10000,
    Chi          = 10001,
    MingGang     = 10003,
    AnGang       = 10004,
    BuGang       = 10005,
    CaiShen      = 10006,
    HU           = 10007,
    HuangZhuang  = 10008,
    ZiMo         = 10009,
    DianPao      = 10010,
    MingDa       = 10011,
    MingLou      = 10012,
    GangShangHua = 10013,
    QiangGangHu  = 10014,
    TianTing     = 10015,
}
Constants.SFX_OpKey = SFX_OpKey
-- 表示没有，可以表示没有音效，没有动画等
Constants.NONE = 0
local GenderType = {
    InValid = 0,
    --男 */
    Male    = 1,
    --女 */
    Female  = 2,
}
Constants.GenderType = GenderType;

local GENDER_PATH               = {}
Constants.GENDER_PATH           = GENDER_PATH
GENDER_PATH[GenderType.InValid] = "Man/";
GENDER_PATH[GenderType.Male]    = "Man/";
GENDER_PATH[GenderType.Female]  = "Woman/";

local SFXCONFIG                   = {}
Constants.SFXCONFIG               = SFXCONFIG
SFXCONFIG[CardType.Wan + 0]       = {[GenderType.Male] = {"yiwan.mp3"}       , [GenderType.Female] = {"yiwan.mp3"}};
SFXCONFIG[CardType.Wan + 1]       = {[GenderType.Male] = {"erwan.mp3"}       , [GenderType.Female] = {"erwan.mp3"}};
SFXCONFIG[CardType.Wan + 2]       = {[GenderType.Male] = {"sanwan.mp3"}      , [GenderType.Female] = {"sanwan.mp3"}};
SFXCONFIG[CardType.Wan + 3]       = {[GenderType.Male] = {"siwan.mp3"}       , [GenderType.Female] = {"siwan.mp3"}};
SFXCONFIG[CardType.Wan + 4]       = {[GenderType.Male] = {"wuwan.mp3"}       , [GenderType.Female] = {"wuwan.mp3"}};
SFXCONFIG[CardType.Wan + 5]       = {[GenderType.Male] = {"liuwan.mp3"}      , [GenderType.Female] = {"liuwan.mp3"}};
SFXCONFIG[CardType.Wan + 6]       = {[GenderType.Male] = {"qiwan.mp3"}       , [GenderType.Female] = {"qiwan.mp3"}};
SFXCONFIG[CardType.Wan + 7]       = {[GenderType.Male] = {"bawan.mp3"}       , [GenderType.Female] = {"bawan.mp3"}};
SFXCONFIG[CardType.Wan + 8]       = {[GenderType.Male] = {"jiuwan.mp3"}      , [GenderType.Female] = {"jiuwan.mp3"}};
SFXCONFIG[CardType.Tiao + 0]      = {[GenderType.Male] = {"yitiao.mp3"}      , [GenderType.Female] = {"yitiao.mp3"}};
SFXCONFIG[CardType.Tiao + 1]      = {[GenderType.Male] = {"ertiao.mp3"}      , [GenderType.Female] = {"ertiao.mp3"}};
SFXCONFIG[CardType.Tiao + 2]      = {[GenderType.Male] = {"santiao.mp3"}     , [GenderType.Female] = {"santiao.mp3"}};
SFXCONFIG[CardType.Tiao + 3]      = {[GenderType.Male] = {"sitiao.mp3"}      , [GenderType.Female] = {"sitiao.mp3"}};
SFXCONFIG[CardType.Tiao + 4]      = {[GenderType.Male] = {"wutiao.mp3"}      , [GenderType.Female] = {"wutiao.mp3"}};
SFXCONFIG[CardType.Tiao + 5]      = {[GenderType.Male] = {"liutiao.mp3"}     , [GenderType.Female] = {"liutiao.mp3"}};
SFXCONFIG[CardType.Tiao + 6]      = {[GenderType.Male] = {"qitiao.mp3"}      , [GenderType.Female] = {"qitiao.mp3"}};
SFXCONFIG[CardType.Tiao + 7]      = {[GenderType.Male] = {"batiao.mp3"}      , [GenderType.Female] = {"batiao.mp3"}};
SFXCONFIG[CardType.Tiao + 8]      = {[GenderType.Male] = {"jiutiao.mp3"}     , [GenderType.Female] = {"jiutiao.mp3"}};
SFXCONFIG[CardType.Tong + 0]      = {[GenderType.Male] = {"yibing.mp3"}      , [GenderType.Female] = {"yibing.mp3"}};
SFXCONFIG[CardType.Tong + 1]      = {[GenderType.Male] = {"erbing.mp3"}      , [GenderType.Female] = {"erbing.mp3"}};
SFXCONFIG[CardType.Tong + 2]      = {[GenderType.Male] = {"sanbing.mp3"}     , [GenderType.Female] = {"sanbing.mp3"}};
SFXCONFIG[CardType.Tong + 3]      = {[GenderType.Male] = {"sibing.mp3"}      , [GenderType.Female] = {"sibing.mp3"}};
SFXCONFIG[CardType.Tong + 4]      = {[GenderType.Male] = {"wubing.mp3"}      , [GenderType.Female] = {"wubing.mp3"}};
SFXCONFIG[CardType.Tong + 5]      = {[GenderType.Male] = {"liubing.mp3"}     , [GenderType.Female] = {"liubing.mp3"}};
SFXCONFIG[CardType.Tong + 6]      = {[GenderType.Male] = {"qibing.mp3"}      , [GenderType.Female] = {"qibing.mp3"}};
SFXCONFIG[CardType.Tong + 7]      = {[GenderType.Male] = {"babing.mp3"}      , [GenderType.Female] = {"babing.mp3"}};
SFXCONFIG[CardType.Tong + 8]      = {[GenderType.Male] = {"jiubing.mp3"}     , [GenderType.Female] = {"jiubing.mp3"}};
SFXCONFIG[CardType.Zi + 0]        = {[GenderType.Male] = {"dong.mp3"}        , [GenderType.Female] = {"dong.mp3"}};
SFXCONFIG[CardType.Zi + 1]        = {[GenderType.Male] = {"nan.mp3"}         , [GenderType.Female] = {"nan.mp3"}};
SFXCONFIG[CardType.Zi + 2]        = {[GenderType.Male] = {"xi.mp3"}          , [GenderType.Female] = {"xi.mp3"}};
SFXCONFIG[CardType.Zi + 3]        = {[GenderType.Male] = {"bei.mp3"}         , [GenderType.Female] = {"bei.mp3"}};
SFXCONFIG[CardType.Zi + 4]        = {[GenderType.Male] = {"zhong.mp3"}       , [GenderType.Female] = {"zhong.mp3"}};
SFXCONFIG[CardType.Zi + 5]        = {[GenderType.Male] = {"fa.mp3"}          , [GenderType.Female] = {"fa.mp3"}};
SFXCONFIG[CardType.Zi + 6]        = {[GenderType.Male] = {"bai.mp3"}         , [GenderType.Female] = {"bai.mp3"}};
--SFXCONFIG[CardType.Hua + 0] = { [GenderType.Male] = "chun.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 1] = { [GenderType.Male] = "xia.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 2] = { [GenderType.Male] = "qiu.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 3] = { [GenderType.Male] = "dong - caishen.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 4] = { [GenderType.Male] = "mei.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 5] = { [GenderType.Male] = "lan.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 6] = { [GenderType.Male] = "zhu.mp3", woman = ".mp3" };
--SFXCONFIG[CardType.Hua + 7] = { [GenderType.Male] = "ju.mp3", woman = ".mp3" };
SFXCONFIG[SFX_OpKey.Peng]         = {[GenderType.Male] = {"peng.mp3"}        , [GenderType.Female] = {"peng.mp3"}};
SFXCONFIG[SFX_OpKey.MingGang]     = {[GenderType.Male] = {"minggang.mp3"}    , [GenderType.Female] = {"minggang.mp3"}};
SFXCONFIG[SFX_OpKey.AnGang]       = {[GenderType.Male] = {"angang.mp3"}      , [GenderType.Female] = {"angang.mp3"}};
SFXCONFIG[SFX_OpKey.BuGang]       = {[GenderType.Male] = {"bugang.mp3"}      , [GenderType.Female] = {"bugang.mp3"}};
SFXCONFIG[SFX_OpKey.CaiShen]      = {[GenderType.Male] = {"caishen.mp3"}     , [GenderType.Female] = {"caishen.mp3"}};
SFXCONFIG[SFX_OpKey.HU]           = {[GenderType.Male] = {"hupai.mp3"}       , [GenderType.Female] = {"hupai.mp3"}};
SFXCONFIG[SFX_OpKey.ZiMo]         = {[GenderType.Male] = {"zimo.mp3"}        , [GenderType.Female] = {"zimo.mp3"}};
SFXCONFIG[SFX_OpKey.DianPao]      = {[GenderType.Male] = {"dianpao.mp3"}     , [GenderType.Female] = {"dianpao.mp3"}};
SFXCONFIG[SFX_OpKey.Chi]          = {[GenderType.Male] = {"chi.mp3"}         , [GenderType.Female] = {"chi.mp3"}};
SFXCONFIG[SFX_OpKey.MingDa]       = {[GenderType.Male] = {"mingda.mp3"}      , [GenderType.Female] = {"mingda.mp3"}};
SFXCONFIG[SFX_OpKey.MingLou]      = {[GenderType.Male] = {"minglou.mp3"}     , [GenderType.Female] = {"minglou.mp3"}};
SFXCONFIG[SFX_OpKey.GangShangHua] = {[GenderType.Male] = {"gangshanghua.mp3"}, [GenderType.Female] = {"gangshanghua.mp3"}};
SFXCONFIG[SFX_OpKey.QiangGangHu]  = {[GenderType.Male] = {"qiangganghu.mp3"} , [GenderType.Female] = {"qiangganghu.mp3"}};
SFXCONFIG[SFX_OpKey.HuangZhuang]  = {[GenderType.Male] = {"huangzhuang.mp3"} , [GenderType.Female] = {"huangzhuang.mp3"}};
SFXCONFIG[SFX_OpKey.TianTing]     = {[GenderType.Male] = {"tianting.mp3"}    , [GenderType.Female] = {"tianting.mp3"}};

-- 牌桌内动效map
Constants.EffectMap = {
	gang = {
		[0x07000001] = "csb/Effect/gang_specialEffect.csb"
	},
	gangshanghua = {
		[0x07000002] = "csb/Effect/kaihua_specialEffect.csb",
    },
    -- 聊天气泡，需要两个样式图
    dialog = {
        [0x07000003] = {
            Right = "art/effect/dialog/img_christmas_dh1.png",
            Left = "art/effect/dialog/img_christmas_dh2.png",
            Color = cc.c3b(255,241,117),
            expandSize = cc.size(35,0)
        },
        [0x07000004] = {
            Right = "art/effect/dialog/img_qp_cj1.png",
            Left = "art/effect/dialog/img_qp_cj2.png",
            Color = cc.c3b(255,241,117),
            expandSize = cc.size(60,0)
        },
        [0x07000005] = {
            Right = "art/effect/dialog/img_qp_yxj1.png",
            Left = "art/effect/dialog/img_qp_yxj2.png",
            Color = cc.c3b(255,241,117),
            expandSize = cc.size(60,0)
        },
    }
}

--[[	
-- 同步服务器的PlayType
-- 操作类型&操作结果显示类型
-- 前30位为操作类型 用于与或操作
-- 从 1 << 30 + 1开始为显示类型 只用于等于
--]]
Constants.PlayType                = {
    DISTORY_FINISH_ROOM = -3,  --FYD 中途解散房间
    DISPLAY_FINISH_ALL_REPLAY = -2,
    DISPLAY_FINISH_ALL        = -1,
    UNKNOW                    = 0,
    -- /** 手牌(开局发牌/重新加入房间复牌/胡牌后公开手牌) */
    OPERATE_DEAL_FIRST        = 1,
    -- /** 抓牌 */
    OPERATE_DEAL              = 2,
    -- /** 过 */
    OPERATE_CAN_PASS          = 3,
    OPERATE_PASS              = 4,
    -- /** 等待 */
    OPERATE_WAIT              = 5,
    OPERATE_CANCEL            = 6,

    -- /** 断线重连指示灯 */
	OPERATE_LIGHT = 7,
    -- /** 断线重连蒙灰 */
	OPERATE_REJOIN_MASK = 8,

        --/** 托管*/
    OPERATE_TRUSTEESHIP       = 9,
    OPERATE_TRUSTEESHIP_CANCLE       = 10,
    OPERATE_TRUSTEESHIP_DELAY_TIME   = 11,
    OPERATE_TRUSTEESHIP_DELAY_TIME_ALL = 12,
    OPERATE_TING_TIP = 13,

    -- /** 可以出牌 */
    OPERATE_CAN_PLAY_A_CARD = 100,
    -- /** 出牌 */
    OPERATE_PLAY_A_CARD     = 101,

    -- /** 可以自动出牌 */
    OPERATE_CAN_AUTO_PLAY_LAST_DEALED_CARD = 102,

    -- /** 可以出牌，并翻到背面 */
    OPERATE_CAN_PLAY_A_CARD_HIDE = 103,
    -- /** 出牌，并翻到背面 */
    OPERATE_PLAY_A_CARD_HIDE     = 104,

    -- /** 可以吃牌 */
    OPERATE_CAN_CHI_A_CARD = 110,
    -- /** 吃牌 */
    OPERATE_CHI_A_CARD     = 111,

    -- /** 可以碰牌 */
    OPERATE_CAN_PENG_A_CARD = 120,
    -- /** 碰牌 */
    OPERATE_PENG_A_CARD     = 121,

    -- /** 可以杠牌 */
    OPERATE_CAN_GANG_A_CARD = 130,
    -- /** 杠牌 */
    OPERATE_GANG_A_CARD     = 131,
    --/** 明杠（赔） */
    OPERATE_GANG_A_CARD_PEI = 132,

    -- /** 可以补杠 */
    OPERATE_CAN_BU_GANG_A_CARD = 140,
    -- /** 补杠 */
    OPERATE_BU_GANG_A_CARD     = 141,
    --/** 补杠（赔） */
    OPERATE_BU_GANG_A_CARD_PEI = 142,

    -- /** 可以胡 */
    OPERATE_CAN_HU      = 150,
    -- /** 胡 */
    OPERATE_HU          = 151,
    -- /** 可以自动胡 */
    OPERATE_CAN_AUTO_HU = 152,

    -- /** 可以暗杠 */
    OPERATE_CAN_AN_GANG = 160,
    -- /** 暗杠 */
    OPERATE_AN_GANG     = 161,
    --/** 暗杠（赔） */
    OPERATE_AN_GANG_PEI = 162,

    -- /** 换三张开始 */
    OPERATE_CHANGECARD_START  = 170,
    -- /** 换三张操作 */
    OPERATE_CHANGECARD        = 171,
    -- /** 换三张结束 */
    OPERATE_CHANGECARD_FINISH = 172,
    -- /** 换三张结束的方式，顺时针还是对家换牌 */
    OPERATE_CHANGECARD_RULE   = 173,
    -- /** 换三张已选择 */
    OPERATE_CHANGECARD_SELECT = 174,

    -- /** 定缺开始 */
    OPERATE_LACK_START  = 180,
    -- /** 定缺操作 */
    OPERATE_LACK        = 181,
    -- /** 定缺结束 */
    OPERATE_LACK_FINISH = 182,
    -- /** 定缺已选择 */
    OPERATE_LACK_SELECT = 183,

    -- /** 蹲拉跑开始 （内蒙） */
    OPERATE_DUN_LA_PAO_START  = 190,
    -- /** 蹲拉跑操作 （内蒙） */
    OPERATE_DUN_LA_PAO        = 191,
    -- /** 蹲拉跑结束 （内蒙） */
    OPERATE_DUN_LA_PAO_FINISH = 192,
    -- /** 蹲拉跑已选择 （内蒙） */
    OPERATE_DUN_LA_PAO_SELECT = 193,

    -- /** 明打开始 （聊城） */
    OPERATE_MING_DA_START   = 200,
    -- /** 明打操作 （聊城） */
    OPERATE_MING_DA         = 201,
    -- /** 明打拒绝 （聊城） */
    OPERATE_MING_DA_REFUSED = 202,
    -- /** 明打 结束（聊城） */
    OPERATE_MING_DA_END     = 203,

    -- /** 可以听牌 */
    OPERATE_CAN_TING = 210,
    -- /** 听牌 */
    OPERATE_TING     = 211,

    -- /** 可以听牌，需要打牌 */
    OPERATE_CAN_TING_CARD = 212,
    -- /** 打牌听牌 */
    OPERATE_TING_CARD     = 213,

    -- /** 上火选择开始（江西） */
    OPERATE_SHANG_HUO_START = 230,
    -- /** 上火选择开始（江西） */
    OPERATE_SHANG_HUO       = 231,
    -- /** 上火选择开始（江西） */
    OPERATE_SHANG_HUO_END   = 232,

    -- /** 漂选择开始（江西） */
    OPERATE_PIAO_START = 235,
    -- /** 漂选择开始（江西） */
    OPERATE_PIAO       = 236,
    -- /** 漂选择开始（江西） */
    OPERATE_PIAO_END   = 237,

    -- /** 上正精 (南昌) */
    OPERATE_SHANGJING_ZHENG = 240,
    -- /** 上副精 (南昌) */
    OPERATE_SHANGJING_FU    = 241,
    -- /** 下正精 (南昌) */
    OPERATE_XIAJING_ZHENG   = 242,
    -- /** 下副精 (南昌) */
    OPERATE_XIAJING_FU      = 243,

    -- /** 冷碰(河源) */
    OPERATE_LENG_PENG_A_CARD = 250,
    -- /** 可以翻 (河源) */
    OPERATE_CAN_FAN_A_CARD   = 251,
    -- /** 翻 (河源) */
    OPERATE_FAN_A_CARD       = 252,
    -- /** Break翻 (河源) */
    OPERATE_BREAK_FAN_A_CARD = 253,

    -- /** 平胡 */
    HU_PING_HU               = 1000,
    -- /** 七对 */
    HU_QI_DUI                = 1001,
    -- /** 十三幺 */
    HU_SHI_SAN_YAO           = 1002,
    -- /** 清一色 */
    HU_QING_YI_SE            = 1003,
    -- /** 一条龙 */
    HU_YI_TIAO_LONG          = 1004,
    -- /** 根(川麻) */
    HU_GEN                   = 1005,
    -- /** 全带幺(带幺九) */
    HU_QUAN_DAI_YAO          = 1006,
    -- /** 碰碰和(对对和) */
    HU_PENG_PENG_HU          = 1007,
    -- /** 将对 全为2,5,8的对对胡 */
    HU_JIANG_DUI             = 1008,
    -- /** 全小 */
    HU_QUAN_XIAO             = 1009,
    -- /** 全中 */
    HU_QUAN_ZHONG            = 1010,
    -- /** 全大 */
    HU_QUAN_DA               = 1011,
    -- /** 中张, 没有1,9的数牌 */
    HU_ZHONG_ZHANG           = 1012,
    -- /** 门前清(门清) 没有吃、碰、明杠，四个组合全由自己摸牌组成(可以暗杠) */
    HU_MEN_QIAN_QING         = 1013,
    -- /** 全求人(全求) 全靠吃牌、碰牌、单钓别人打出的牌和牌。不计单钓将。简称"全求"。 */
    HU_QUAN_QIU_REN          = 1014,
    -- /** 天和 */
    HU_TIAN_HU               = 1015,
    -- /** 地和 */
    HU_DI_HU                 = 1016,
    -- /** 杠上花 */
    HU_GANG_SHANG_HUA        = 1017,
    -- /** 杠上炮 */
    HU_GANG_SHANG_PAO        = 1018,
    -- /** 杠上胡 */
    HU_QIANG_GANG_HU         = 1019,
    -- /** 海底捞月(海底胡) */
    HU_HAI_DI_LAO_YUE        = 1020,
    -- /** 金钩 */
    HU_JIN_GOU               = 1021,
    -- /** 自摸 */
    HU_ZI_MO                 = 1022,
    -- /** 点炮胡, 对应于自摸 */
    HU_DIAN_PAO              = 1023,
    -- /** 清幺九 */
    HU_QING_YAO_JIU          = 1025,
    -- /** 混幺九(幺九胡) */
    HU_HUN_YAO_JIU           = 1026,
    -- /** 字一色 */
    HU_ZI_YI_SE              = 1027,
    -- /** 混一色 */
    HU_HUN_YI_SE             = 1028,
    -- /** 四杠 */
    HU_SI_GANG               = 1029,
    -- /** 四鬼胡牌 */
    HU_SI_MASTER_CARD_HU     = 1030,
    -- /** 豪华七对 */
    HU_HAO_HUA_QI_DUI        = 1031,
    --/** 豪华清七对 */
    HU_HAO_HUA_QING_QI_DUI   = 1032,
    -- /** 缺一门 */
    HU_QUE_YI_MEN            = 1033,
    -- /** 边张 */
    HU_BIAN_ZHANG            = 1034,
    -- /** 坎张 */
    HU_KAN_ZHANG             = 1035,
    -- /** 单钓 */
    HU_DAN_DIAO              = 1036,
    -- /** 够张 */
    HU_GOU_ZHANG             = 1037,
    -- /** 庄家 */
    HU_ZHUANG_JIA            = 1038,
    -- /** 带漂 */
    HU_DAI_PIAO              = 1039,
    -- /** 双豪华七对 */
    HU_SHUANG_HAO_HUA_QI_DUI = 1040,
    -- /** 三豪华七对 */
    HU_SAN_HAO_HUA_QI_DUI    = 1041,
    -- /** 门清自摸 */
    HU_MEN_QING_ZI_MO        = 1042,
    -- /** 广州推倒胡的幺九（包含清幺九和混幺九） */
    HU_YAO_JIU_GDTDH         = 1043,
    -- /** 大胡（广东潮汕的小胡规则下除去平胡外的所有加分，乘分不变） */
    HU_DA_HU                 = 1044,
    -- /** 一般高 */
    HU_YI_BAN_GAO            = 1045,
    -- /** 小连 */
    HU_XIAO_LIAN             = 1046,
    -- /** 大连 */
    HU_DA_LIAN               = 1047,
    -- /** 老少 */
    HU_LAO_SHAO              = 1048,
    -- /** 刻 */
    HU_KE                    = 1049,
    -- /** 四归一 */
    HU_SI_GUI_YI             = 1050,
    -- /** 坎五魁 */
    HU_KAN_WU_KUI            = 1051,
    -- /** 九莲宝灯 */
    HU_JIU_LIAN_BAO_DENG     = 1052,
    -- /** 13烂 */
    HU_13LAN                 = 1053,
    -- /** 七星13烂 */
    HU_QIXING13LAN           = 1054,
    -- /** 四对 （三人三房） */
    HU_SI_DUI                = 1055,
    -- /** 混幺九（潮州麻将） */
    HU_HUN_YAO_JIU_CHAOZHOU  = 1056,
    -- /** 夹心五 */
    HU_JIA_XIN_WU            = 1057,
    -- /** 大单吊 */
    HU_DA_DAN_DIAO           = 1058,
    -- /** 超豪华七对 */
    HU_CHAO_HAO_HUA_QI_DUI   = 1059,

    -- /** 精钓乘分 */
    HU_JING_DIAO_MULTIPLY   = 1070,
    -- /** 德国乘分 */
    HU_DE_GUO_MULTIPLY      = 1071,
    -- /** 德国加分 */
    HU_DE_GUO_ADD           = 1072,
    -- /** 德中德乘分 */
    HU_DE_ZHONG_DE_MULTIPLY = 1073,
    -- /** 德中德加分 */
    HU_DE_ZHONG_DE_ADD      = 1074,
    -- /** 精钓加分 */
    HU_JING_DIAO_ADD        = 1075,

    -- /** 门清 */
    HU_MEN_QING      = 1060,
    -- /** 开门 */
    HU_KAI_MEN       = 1061,
    -- /** 死卡 */
    HU_SI_KA         = 1062,
    -- /** 活卡 */
    HU_HUO_KA        = 1063,
    -- /** 摸宝 */
    HU_MO_BAO        = 1064,
    -- /** 宝中宝 */
    HU_BAO_ZHONG_BAO = 1065,
    -- /** 未上听 */
    HU_NO_TING_CARD  = 1066,
    -- /** 上听 */
    HU_TING_CARD     = 1067,
    -- /** 胡牌 客户端显示 */
    HU_HU_PAI        = 1068,
    -- /** 卡当次数 */
    HU_KA_DANG       = 1069,

    -- /** 大三元 */
    HU_DA_SAN_YUAN   = 1080,
    -- /** 小三元 */
    HU_XIAO_SAN_YUAN = 1081,
    -- /** 大四喜 */
    HU_DA_SI_XI      = 1082,
    -- /** 小四喜 */
    HU_XIAO_SI_XI    = 1083,

    -- /** 支牌(安徽-马鞍山) */
    HU_ZHI_PAI            = 1090,
    -- /** 大吊车(安徽-马鞍山) */
    HU_DA_DIAO_CHE        = 1091,
    -- /** 压挡(安徽-马鞍山) */
    HU_YA_DANG            = 1092,
    -- /** 枯枝压(安徽-马鞍山) */
    HU_KU_ZHI_YA          = 1093,
    -- /** 双扑(安徽-马鞍山) */
    HU_SHUANG_PU          = 1094,
    -- /** 四核(安徽-马鞍山) */
    HU_SI_HE              = 1095,
    -- /** 五通(安徽-马鞍山) */
    HU_WU_TONG            = 1096,
    -- /** 六连(安徽-马鞍山) */
    HU_LIU_LIAN           = 1097,
    -- /** 十老(安徽-马鞍山) */
    HU_SHI_LAO            = 1098,
    -- /** 十小(安徽-马鞍山) */
    HU_SHI_XIAO           = 1099,
    -- /** 挖摸(安徽-马鞍山) */
    HU_WA_MO              = 1100,
    -- /** 平摸(安徽-马鞍山) */
    HU_PING_MO            = 1101,
    -- /** 清水大拿(安徽-马鞍山) */
    HU_QING_SHUI_DA_NA    = 1102,
    -- /** 浑水大拿(安徽-马鞍山) */
    HU_HUN_SHUI_DA_NA     = 1103,
    -- /** 三张在手(安徽-马鞍山) */
    HU_SAN_ZHANG_ZAI_SHOU = 1104,
    -- /** 三张碰出 (安徽-马鞍山) */
    HU_SAN_ZHANG_PENG_CHU = 1105,

    -- /** 跑风 (安徽-铜陵) */
    HU_PAO_FENG      = 1106,
    -- /** 跑风杠 (安徽-铜陵) */
    HU_PAO_FENG_GANG = 1107,
    -- /** 跑配 (安徽-铜陵) */
    HU_PAO_PEI       = 1108,
    -- /** 素牌(安徽-红中) */
    HU_SU_PAI        = 1109,

    -- /** 坎坎胡（梅州） */
    HU_KAN_KAN_HU          = 1110,
    -- /** 红中宝（梅州） */
    HU_MAIN_HONG_ZHONG_BAO = 1111,
    -- /** 无红中（梅州） */
    HU_WU_HONG_ZHONG       = 1112,
    -- /** 红中宝（梅州） */
    HU_SUB_HONG_ZHONG_BAO  = 1113,
    -- /** 吃杠杠爆分（汕头） */
    HU_CHI_GANG_GANG_BAO   = 1120,
    -- /** 全牌型（汕头） */
    HU_QUAN_PAI_XING       = 1121,

    -- /** 大哥（河源） */
    HU_DA_GE        = 1130,
    -- /** 混碰（河源） */
    HU_HUN_PENG     = 1131,
    -- /** 打翻倍（河源） */
    HU_DA_FAN_BEI   = 1132,
    -- /** 花吊花（河源） */
    HU_HUA_DIAO_HUA = 1133,

    -- /** 不动手(安徽-马鞍山) */
    HU_BU_DONG_SHOU             = 1150,
    -- /** 花开(安徽-池州) */
    HU_HUA_KAI                  = 1151,
    -- /** 大吊车+花开(安徽-池州) */
    HU_DA_DIAO_CHE_JIA_HUA_KAI  = 1152,
    -- /** 大吊车+杠开(安徽-池州) */
    HU_DA_DIAO_CHE_JIA_GANG_KAI = 1153,
    -- /** 小胡(安徽-池州) */
    HU_XIAO_HU                  = 1154,
    -- /** 中胡(安徽-池州) */
    HU_ZHONG_HU                 = 1155,
    -- /** 辣子(安徽-池州) */
    HU_LA_ZI                    = 1156,
    -- /** 压挡自摸(安徽-芜湖) */
    HU_YA_DANG_ZI_MO            = 1157,
    -- /** 支番(安徽-芜湖)*/
    HU_ZHI_FAN                  = 1158,
    -- /** 庄家底番(安徽-芜湖) */
    HU_ZHUANG_JIA_DI_FAN        = 1159,
    -- /** 自摸嘴子(安徽-芜湖) */
    HU_ZI_MO_ZUI_ZI             = 1160,
    -- /** 双四核(安徽-芜湖)*/
    HU_SHUANG_SI_HE             = 1161,
    -- /** 双八支(安徽-芜湖)*/
    HU_SHUANG_BA_ZHI            = 1162,
    -- /** 全交(安徽-芜湖)*/
    HU_QUAN_JIAO                = 1163,
    -- /** 四鬼胡牌(安徽-芜湖) */
    HU_SI_HONG_ZHONG            = 1164,
    --/** 清碰(广西-柳州) */
    HU_QING_PENG                = 1300,
    --/** 全字对对碰（潮汕） */
    HU_QUAN_ZI_DUI_DUI_PENG     = 1400,
    -- /** 龙七对（贵阳） */
    HU_LONG_QI_DUI              = 1600,
    -- /** 清大对（贵阳） */
    HU_QING_DA_DUI              = 1601,
    -- /** 清七对（贵阳） */
    HU_QING_QI_DUI              = 1602,
    -- /** 青龙背（贵阳） */
    HU_QING_LONG_BEI            = 1603,
    -- /** 硬报（贵阳） */
    HU_YING_BAO                 = 1604,
    -- /** 软报（贵阳） */
    HU_RUAN_BAO                 = 1605,
    -- /** 叫牌（贵阳） */
    HU_JIAO_PAI                 = 1606,
    -- /** 叫牌（贵阳） */
    HU_WEI_JIAO_PAI             = 1607,
    -- /** 查大叫（贵阳） */
    HU_CHA_DA_JIAO_GUIYANG      = 1608,
    -- /** 边卡吊 */
    HU_BIAN_KA_DIAO             = 1609,
    -- /** 大宽张 */
    HU_DAKUANZHANG              = 1610,
    -- /** 清单吊（贵阳） */
	HU_QING_DAN_DIAO            = 1611,
    -- /** 地龙 （贵阳） */
	HU_DI_LONG                  = 1612,
    -- /**  清地龙（贵阳） */
	HU_QING_DI_LONG             = 1613,
    -- /** 地龙七对 （贵阳） */
	HU_DI_LONG_QI_DUI           = 1614,
    -- /** 双清 （贵阳） */
	HU_SHUANG_QING              = 1615,
    -- /** 闷胡 （贵阳） */
	HU_MEN_HU                   = 1616,


    HU_END = 2000,

    -- /** 剩余牌池 */
    DISPLAY_LAST_CARD_COUNT = 2001,
    -- /** 花牌 */
    DISPLAY_EX_CARD         = 2002,
    -- /** 正牌（汕尾） */
    DISPLAY_ZHENG_CARD      = 2009,
    -- /** 牌局倍率   */
    DISPLAY_MULTIPLE        =2010,

    -- /** 被吃 */
    DISPLAY_BE_CHI                     = 3000,
    -- /** 被碰 */
    DISPLAY_BE_PENG                    = 3001,
    -- /** 点杠 */
    DISPLAY_BE_GANG                    = 3002,
    -- /** 自摸加番 */
    DISPLAY_ZIMO_FAN                   = 3003,
    -- /** 自摸加分 */
    DISPLAY_ZIMO_FEN                   = 3004,
    -- /** 花猪 */
    DISPLAY_HUAZHU                     = 3005,
    -- /** 大叫 */
    DISPLAY_DAJIAO                     = 3006,
    -- /** 点炮 */
    DISPLAY_DIANPAO                    = 3007,
    -- /** 未胡牌 */
    DISPLAY_LOSER                      = 3008,
    -- /** 听牌 */
    DISPLAY_TING                       = 3009,
    --普通听 听牌 无动画
    DISPLAY_TING_NO_ACTION             = 3040,
    -- /** */
    DISPLAY_UN_TING                    = 3010,
    -- /** 退税:退分 */
    DISPLAY_TUI_SHUI                   = 3011,
    -- /** 呼叫转移 */
    DISPLAY_HU_JIAO_ZHUAN_YI           = 3012,
    -- /** 奖马:总牌数(广东) */
    DISPLAY_DEAL_BETTING_HORSE         = 3013,
    -- /** 奖马:中马牌(广东) */
    DISPLAY_BETTING_HORSE              = 3014,
    -- /** 翻鬼(广东) */
    DISPLAY_DEAL_MASTER_CARD           = 3015,
    -- /** 显示鬼(广东) */
    DISPLAY_SHOW_MASTER_CARD           = 3016,
    -- /** 无鬼加倍得分(广东) */
    DISPLAY_NO_MASTER_CARD             = 3017,
    -- /** 跟庄(广东) */
    DISPLAY_FOLLOW_BANKER              = 3018,
    -- /** 手牌全部蒙灰 */
    DISPLAY_MASK_ALL_HAND_CARD         = 3019,
    -- /** 开启自动打牌 */
    DISPLAY_AUTO_PLAY_LAST_DEALED_CARD = 3020,
    -- /** 奖马:马牌分值（汕尾，服务器内部使用，为了方便房间结算时计算奖马个数） */
    DISPLAY_BETTING_HORSE_VALUE        = 3021,
    -- /** 花牌加番（汕尾） */
    DISPLAY_HUA_JIA_FAN                = 3024,
    -- /** 字牌分（汕尾） */
    DISPLAY_ZI_JIA_FAN                 = 3025,
    -- /** 风牌分（汕尾） */
    DISPLAY_FENG_JIA_FAN               = 3026,
    -- /** 买马（潮汕） */
    DISPLAY_BUY_HORSE                  = 3027,
    -- /** 罚马（潮汕） */
    DISPLAY_PUNISH_HORSE               = 3028,
    -- /** 买马罚马的马牌值（潮汕） */
    DISPLAY_HORSE_CARD                 = 3029,
    -- /** 赢的买马罚马牌（潮汕） */
    DISPLAY_WIN_HORSE_CARD             = 3030,
    -- /** 输的买马罚马牌（潮汕） */
    DISPLAY_LOSE_HORSE_CARD            = 3031,
    -- /** 买马罚马结束（潮汕） */
    DISPLAY_HORSE_END                  = 3032,
    -- /** 买马的中马胡牌分值（潮汕） */
    DISPLAY_HU_BUY_HORSE_SCORE         = 3033,
    -- /** 罚马的中马胡牌分值（潮汕） */
    DISPLAY_HU_PUNISH_HORSE_SCORE      = 3034,
    -- /** 赢的被买马罚马牌（潮汕） */
    DISPLAY_BE_HU_BUY_HORSE_SCORE      = 3035,
    -- /** 输的被买马罚马牌（潮汕） */
    DISPLAY_BE_HU_PUNISH_HORSE_SCORE   = 3036,
    -- /** 买中的马的个数（潮汕） */
    DISPLAY_BUY_HORSE_CARD_COUNT       = 3037,
    -- /** 最终结算界面所有的马牌的个数（潮汕） */
    DISPLAY_ALL_HORSE_CARD_COUNT       = 3038,
    -- /** 杠跟底分（潮汕） */
    DISPLAY_GANG_GEN_DI_FEN            = 3039,

    -- /** 连庄 潮汕 */
    DISPLAY_LIAN_ZHUANG = 3040,
    -- /** 奖马:总牌数(潮汕揭阳一炮多响) */
    DISPLAY_DEAL_BETTING_HORSE_MULTI = 3041,
    -- /** 奖马:中马牌(潮汕揭阳一炮多响) */
    DISPLAY_BETTING_HORSE_MULTI = 3042,

    -- /** 蹲 （内蒙） */
    DISPLAY_DUN      = 4000,
    -- /** 拉 （内蒙） */
    DISPLAY_LA       = 4001,
    -- /** 跑 （内蒙） */
    DISPLAY_PAO      = 4002,
    -- /** 赔杠（内蒙） */
    DISPLAY_PEI_GANG = 4003,

    -- /** 摊牌 （聊城） */
    DISPLAY_TANPAI = 4100,

    -- /** 对火 */
    DISPLAY_DUI_HUO = 4200,
    -- /** 被漂 */
    DISPLAY_BE_PIAO = 4201,

    -- /** 提宝(哈尔滨) */
    DISPLAY_LIFT_BAO_CARD = 4300,
    -- /** 翻宝(哈尔滨) */
    DISPLAY_DEAL_BAO_CARD = 4301,
    -- /** 换宝(哈尔滨) */
    DISPLAY_HUAN_BAO_CARD = 4302,
    -- /** 显示宝牌(哈尔滨) */
    DISPLAY_SHOW_BAO_CARD = 4303,

    -- /** 被明杠(宜昌) */
    DISPLAY_HU_BE_GANG                       = 4400,
    -- /** 被暗杠(宜昌) */
    DISPLAY_HU_BE_AN_GANG                    = 4401,
    -- /** 实时总分数 （宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_TOTAL_POINT       = 4402,
    -- /** 实时当前局分数 （宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_POINT_IN_GAME     = 4403,
    -- /** 实时计分自摸分数 （宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_ZI_MO             = 4404,
    -- /** 实时计分胡牌分数 （宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_HU_PAI            = 4405,
    -- /** 实时计分被自摸分数（宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_BEI_ZI_MO         = 4406,
    -- /** 实时计分点炮分数（宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_DIAN_PAO          = 4407,
    -- /** 实时计分查花猪分数（宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_HUA_ZHU           = 4408,
    -- /** 实时计分查大叫分数（宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_DA_JIAO           = 4409,
    -- /** 实时计分赢家花猪大叫分数（宜昌血流） */
    DISPLAY_SHI_SHI_JI_FEN_SUM_SCORE         = 4410,
    -- /** 査听功能 打出能胡的牌以及听牌之后能听的牌和数据（宜昌血流） */
    DISPLAY_CHA_TING_PLAY_CARD_CAN_HU_CARD   = 4411,
    -- /** 査听功能 听牌之后能听的牌以及能听的牌的数据（宜昌血流） */
    DISPLAY_CHA_TING_PLAY_CARD_CAN_TING_CARD = 4412,
    -- /** 査听功能 显示査听（宜昌血流） */
    DISPLAY_XIAN_SHI_CHA_TING                = 4413,
    -- /** 査听功能 取消显示査听（宜昌血流） */
    DISPLAY_QU_XIAO_CHA_TING                 = 4414,
    -- /** 査听功能 用于客户端清除打出去能胡的牌和数据 */
    DISPLAY_QING_CHU_CAN_HU_CARD             = 4415,
    -- /** 査听功能 用于客户端清除能听的牌的数据 */
    DISPLAY_QING_CHU_CAN_TING_CARD           = 4416,

    -- /** 抄庄 (南昌) */
    DISPLAY_CHAOZHUANG            = 4500,
    -- /** 跟庄，用于动画判断 */ (之前的贵阳叫抄庄没有用到)
    DISPLAY_GEN_ZHUANG            = 4500,
    -- /** 抄庄流局(南昌) */
    DISPLAY_CHAOZHUANG_LIUJU      = 4511,
    -- /** 回头一笑 (南昌) */
    DISPLAY_HUI_TOU_YI_XIAO       = 4501,
    -- /** 上精 (南昌) */
    DISPLAY_SHANG_JING            = 4502,
    -- /** 下翻精 (南昌) */
    DISPLAY_XIA_FAN_JING          = 4503,
    -- /** 埋地雷 (南昌) */
    DISPLAY_MAI_DI_LEI            = 4504,
    -- /** 冲关 */
    DISPLAY_CHONG_GUAN            = 4505,
    -- /** 霸王精 */
    DISPLAY_BA_WANG_JING          = 4506,
    -- /** 杠精 */
    DISPLAY_GANG_JING             = 4507,
    -- /** 精（用于房间结算） */
    DISPLAY_JING                  = 4508,
    -- /** 未点炮 (相对于自摸和点炮) */
    DISPLAY_UN_DIAN_PAO           = 4509,
    -- /** 翻地雷（南昌最后结算翻开地雷） */
    DISPLAY_FAN_DI_LEI            = 4510,
    -- /** 总胡牌次数（用于房间总结算） */
    DISPLAY_HU_TOTAL              = 4511,
    -- /** 总杠牌次数（用于房间总结算） */
    DISPLAY_GANG_TOTAL            = 4512,
    -- /** 回头一笑 牌(南昌，用于客户端显示自己手里的回头一笑牌) */
    DISPLAY_HUI_TOU_YI_XIAO_CARDS = 4513,
    -- /** 同一首歌开头(南昌) */
    DISPLAY_TONG_YI_SHOU_GE_START = 4514,
    -- /** 同一首歌(南昌) */
    DISPLAY_TONG_YI_SHOU_GE_END   = 4515,

    -- /** 跑配(安徽-铜陵) */
    DISPLAY_PAO_PEI                = 4600,
    -- /** 弃牌(安徽-铜陵) */
    DISPLAY_QI_PAI                 = 4601,
    -- /** 鬼牌(安徽-红中) */
    DISPLAY_SHOW_ZHONG_MASTER_CARD = 4602,
    -- /** 翻码(安徽-红中) */
    DISPLAY_FAN_HORSE              = 4603,
    -- /** 中码(安徽-红中) */
    DISPLAY_ZHONG_HORSE            = 4604,

    -- /** 鸡（开始） */
    DISPLAY_JI_START                      = 4699,
    -- /** 冲锋鸡（贵阳） */
    DISPLAY_JI_CHONGFENG                  = 4700,
    -- /** 冲锋金鸡（贵阳） */
    DISPLAY_JI_CHONGFENG_GOLD             = 4701,
    -- /** 责任鸡（贵阳） */
    DISPLAY_JI_ZEREN                      = 4702,
    -- /** 责任金鸡（贵阳） */
    DISPLAY_JI_ZEREN_GOLD                 = 4703,
    -- /** 乌骨冲锋鸡（贵阳） */
    DISPLAY_JI_WUGU_CHONGFENG             = 4704,
    -- /** 乌骨冲锋金鸡（贵阳） */
    DISPLAY_JI_WUGU_CHONGFENG_GOLD        = 4705,
    -- /** 乌骨责任鸡（贵阳） */
    DISPLAY_JI_WUGU_ZEREN                 = 4706,
    -- /** 乌骨责任金鸡（贵阳） */
    DISPLAY_JI_WUGU_ZEREN_GOLD            = 4707,
    -- /** 普通鸡（贵阳） */
    DISPLAY_JI_NORMAL                     = 4708,
    -- /** 普通金鸡（贵阳） */
    DISPLAY_JI_NORMAL_GOLD                = 4709,
    -- /** 普通鸡-乌骨（贵阳） */
    DISPLAY_JI_WUGU                       = 4710,
    -- /** 普通金鸡-乌骨（贵阳） */
    DISPLAY_JI_WUGU_GOLD                  = 4711,
    -- /** 本鸡（贵阳） */
    DISPLAY_JI_SELF                       = 4712,
    -- /** 金本鸡（贵阳） */
    DISPLAY_JI_SELF_GOLD                  = 4713,
    -- /** 翻牌鸡（贵阳） */
    DISPLAY_JI_FANPAI                     = 4714,
    -- /** 翻牌金鸡（贵阳） */
    DISPLAY_JI_FANPAI_GOLD                = 4715,
    -- /** 标记责任鸡收分方（贵阳） */
    DISPLAY_JI_ZEREN_TARGET               = 4716,
    -- /** 标记乌骨责任鸡收分方（贵阳） */
    DISPLAY_JI_WUGU_ZEREN_TARGET          = 4717,
    -- /** 星期鸡（贵阳） */
    DISPLAY_JI_WUGU_XINGQI                = 4718,
    -- /** 吹风鸡（贵阳） */
    DISPLAY_JI_CHUIFENG                   = 4719,
    -- /** 普通鸡—反赔（贵阳） */
    DISPLAY_JI_NORMAL_FANPEI              = 4720,
    -- /** 乌骨鸡—反赔（贵阳） */
    DISPLAY_JI_WUGU_FANPEI                = 4721,
    -- /** 金鸡—反赔（贵阳） */
    DISPLAY_JI_NORMAL_GOLD_FANPEI         = 4722,
    -- /** 金乌骨—反赔（贵阳） */
    DISPLAY_JI_WUGU_GOLD_FANPEI           = 4723,
    -- /** 冲锋鸡—反赔（贵阳） */
    DISPLAY_JI_CHONGFENG_FANPEI           = 4724,
    -- /** 乌骨冲锋鸡—反赔（贵阳） */
    DISPLAY_JI_WUGU_CHONGFENG_FANPEI      = 4725,
    -- /** 责任鸡—反赔（贵阳） */
    DISPLAY_JI_ZEREN_FANPEI               = 4726,
    -- /** 乌骨责任鸡—反赔（贵阳） */
    DISPLAY_JI_WUGU_ZEREN_FANPEI          = 4727,
    -- /** 冲锋金鸡—反赔（贵阳） */
    DISPLAY_JI_CHONGFENG_GOLD_FANPEI      = 4728,
    -- /** 乌骨冲锋金鸡—反赔（贵阳） */
    DISPLAY_JI_WUGU_CHONGFENG_GOLD_FANPEI = 4729,
    -- /** 责任金鸡—反赔（贵阳） */
    DISPLAY_JI_ZEREN_GOLD_FANPEI          = 4730,
    -- /** 乌骨责任金鸡—反赔（贵阳） */
    DISPLAY_JI_WUGU_ZEREN_GOLD_FANPEI     = 4731,
    -- /** 星期鸡 */
    DISPLAY_JI_XINGQI                     = 4732,
    -- /** 红中鸡 */
    DISPLAY_JI_HONGZHONG                  = 4733,
    -- /** 极品鸡 */
	DISPLAY_JI_JIPIN                      = 4734,
    -- /** 开局翻鸡 */
    DISPLAY_JI_KAIJUFANJI                 = 4735,
    --/** 首圈鸡（贵阳） */
    DISPLAY_JI_SHOUQUAN                   = 4736,
    --/** 银鸡（贵阳） */
    DISPLAY_JI_SILVER                     = 4737,
    --/** 首圈鸡-反赔（贵阳） */
    DISPLAY_JI_SHOUQUAN_FANPEI            = 4738,
     --/** 首圈金鸡（贵阳） */
    DISPLAY_JI_SHOUQUAN_GOLD              = 4739,
     --/** 首圈金鸡-反赔（贵阳） */
    DISPLAY_JI_SHOUQUAN_GOLD_FANPEI       = 4740,
  
    -- /** 鸡（结束）*/
    DISPLAY_JI_END                        = 4750,
    -- /** 杀报 （贵阳） */
    DISPLAY_JI_KILLREADYHAND              = 4751,
    -- /** 鸡牌数量 （贵阳） */
    DISPLAY_JI_COUNT                      = 4752,
    -- /** 天缺 （贵阳） */
    DISPLAY_TIANQUE                       = 4753,
    -- /** 查缺 （贵阳） */
    DISPLAY_CHAQUE                        = 4754,
    -- /** 查叫 （贵阳） */
    DISPLAY_CHAJIAO                       = 4755,
    -- /** 连庄 （贵阳） */
    DISPLAY_LIANZHUANG                    = 4756,
    -- /** 连庄次数（贵阳） */
    DISPLAY_LIANZHUANG_COUNT              = 4757,
    -- /** 特殊牌-红中（贵阳） */
	DISPLAY_HONG_ZHONG                    = 4758,

    
    -- /** 估卖开始 （贵州兴义） */
    OPERATE_GU_MAI_START                  = 4760,
    -- /** 估卖操作 （贵州兴义） */
    OPERATE_GU_MAI                        = 4761,
    -- /** 估卖结束 （贵州兴义） */
    OPERATE_GU_MAI_FINISH                 = 4762,
    -- /** 估卖已选择 （贵州兴义） */
    OPERATE_GU_MAI_SELECT                 = 4763,
    -- /** 不估卖 */
	DISPLAY_NO_GU_MAI                     = 4764,
	-- /** 估卖2分 */
    DISPLAY_GU_MAI_2                      = 4765,
	-- /** 估卖3分 */
    DISPLAY_GU_MAI_3                      = 4766,
    -- /** 估卖4分 */
    DISPLAY_GU_MAI_4                      = 4767,
    -- /** 估卖2分（赔） */
    DISPLAY_GU_MAI_2_PEI                  = 4768,
    -- /** 估卖3分（赔） */
    DISPLAY_GU_MAI_3_PEI                  = 4769,
    -- /** 估卖4分（赔） */
    DISPLAY_GU_MAI_4_PEI                  = 4770,
    -- /** 可以闷 */
    OPERATE_CAN_MEN                       = 4771,
	-- /** 闷 */
    OPERATE_MEN                           = 4772,
    -- /** 被闷 */
    DISPLAY_BE_MEN                        = 4773,
    -- /** 抢杠闷 */
    DISPLAY_QIANG_GANG_MEN                = 4774,

    -- /** 河源开始 */
    DISPLAY_HE_YUAN_START = 4800,
    -- /** 万能花牌(河源) */
    DISPLAY_HUA_PAI       = 4888,
    -- /** 河源结束 */
    DISPLAY_HE_YUAN_END   = 4899,

    -- /** 梅州开始 */
    DISPLAY_MEI_ZHOU_START    = 4900,
    -- /** 万能红中(梅州) */
    DISPLAY_MASTER_HONG_ZHONG = 4966,
    -- /** 梅州结束 */
    DISPLAY_MEI_ZHOU_END      = 4999,

    -- /** GPS检测开 */
    GPS_CHECK_OPEN = 65525,
    -- /** GPS检测关 */
    GPS_CHECK_CLOSE = 65524,

    -- @param valueToBeChecked: number
    -- @param match: number
    Check = function(valueToBeChecked, match)
        return valueToBeChecked == match
    end
}

--[[-- 玩家常量
-- 同步于服务器的 PlayerStatus
--]]
Constants.PlayerStatus = {
    DEFAULT        = bit.lshift(1, 0) , -- 默认状态
    READY          = bit.lshift(1, 1) , -- 是否准备好打牌
    HOST           = bit.lshift(1, 2) , -- 是房主
    WAITING        = bit.lshift(1, 3) , -- 等待
    ZHUANGJIA      = bit.lshift(1, 8) , -- 庄家
    ONLINE         = bit.lshift(1, 13), -- 是否在线
    IGNORE_SAME_IP = bit.lshift(1, 15), -- 相同IP同意
}


--[[-- 按钮列表
-- 同步于服务器的 buttonValue字段
--]]
Constants.ButtonConst = {
    CLUB_BTN                = bit.lshift(1, 0) ,    -- 亲友圈按钮
    SWITCH_REGION_BTN       = bit.lshift(1, 1) ,    -- 切换地区按钮
    CREATE_CLUB             = bit.lshift(1, 2),     -- 控制自主创建亲友圈按钮
    CAMPAIGN_BTN            = bit.lshift(1, 3),     -- 控制比赛场开关按钮
    GOLD_BTN                = bit.lshift(1, 4),     -- 金币场开关
    NIAN_BAO                = bit.lshift(1, 5),     -- 年报
    TUI_SONG                = bit.lshift(1, 6),     -- 推送
    SHARE_TYPE              = bit.lshift(1, 7),     -- 分享
    DAILY_BENEFITS          = bit.lshift(1, 8),     -- 每日福利
}

-- 结算的全部相关配置
local PlayType = Constants.PlayType

local RoomSetting       = config.GlobalConfig.getRoomSetting()

Constants.CommonEvents  = {}

Constants.SpecialEvents = {}

Constants.SpecialEvents.setGameType = function(gameType)
    Constants.SpecialEvents.gameType = gameType
end

-- 这里选取默认gametype有问题，setGameType在登录进去之后没有立即调用，而是在创建房间后才调用
-- 打个补丁，改成遍历当前地区的gametype
Constants.SpecialEvents.getConfig = function(playtype)
    local conf = nil
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local gameTypes = MultiArea.getGameTypeKeys(areaId);
    local gameType = Constants.SpecialEvents.gameType;

    if gameType and Constants.CommonEvents[areaId][gameType] and Constants.CommonEvents[areaId][gameType][playtype] then
        conf = Constants.CommonEvents[areaId][gameType][playtype];
        return  conf;
    end

    for i,v in ipairs(gameTypes) do
        if v and Constants.CommonEvents[areaId][v] and Constants.CommonEvents[areaId][v][playtype] then
            conf = Constants.CommonEvents[areaId][v][playtype];
            return  conf;
        end
    end
    return nil;
end

Constants.SpecialEvents.getName = function(playtype, initiative)
    local conf = Constants.SpecialEvents.getConfig(playtype)
    if not conf then
        Logger.error(playtype.." can`t find !!!!")
        return "unknow"
    else
        return (initiative or initiative == nil) and conf.name or conf.be
    end
end

Constants.SpecialEvents.getValue = function(playtype)
    local conf = Constants.SpecialEvents.getConfig(playtype)
    if not conf then
        Logger.error(playtype.." can`t find !!!!")
        return -1
    else
        return conf.weight
    end
end

Constants.SpecialEvents.getUiSkin = function(playtype, initiative)
    local conf  = Constants.SpecialEvents.getConfig(playtype)
    if not conf then
        Logger.error(playtype.." can`t find !!!!")
        return "unknow.png"
    else
        return ((initiative or initiative == nil) and conf.skin or conf.beskin)..".png"
    end
end

Constants.SpecialEvents.getDestopSkin = function()
    local gameTypes, gameTypesConfig = room.RoomSettingHelper.getGameTypes()
    local skin = gameTypesConfig[Constants.SpecialEvents.gameType].destopSkin
    if not skin then
        return "gaming/z_gyzj.png"
    else
        return skin
    end
end

Constants.GameUIType = {
    ["UI_GAME_SCENE"] = 'UI_GAME_SCENE'
}

--[[	export class RoundReportInfo {
		public chi: Array<Array<number>> = [];
		public peng: number[] = [];
		public gang: number[] = [];
		public anGang: number[] = [];
		public hand: number[] = [];
		public hus: number[];
		public guiCards: number[] = [];
		public result: net.core.protocol.BCMatchResultSYN;
		public isWin: boolean;
		public player: Player;
	}

	export const PLAYER_STATUS_IMAGE = {
		[PlayType.DISPLAY_TING]: "mahjong_tile/icon_51.png",
		[PlayType.OPERATE_MING_DA]: "mahjong_tile/icon_52.png",
	}

	export enum ScoreCalculateType {
		/**
		 * 最后分数加减, 不用计算翻数
		 */
		NONE = 0,

		/**
		 * 二的指数次幂
		 */
		TWO_INDEX,

		/**
		 * 最后分数加减, 不用计算翻数
		 */
		TOTAL_ADD,

		/**
		 * 最后分数乘翻
		 */
		TOTAL_MULTI,

		/**
		 * 最后分数乘翻(第二种)
		 */
		TOTAL_MULTI_2ND
	}

	export const CALC_OP_MAP = {
		[ScoreCalculateType.NONE]: "",
		[ScoreCalculateType.TWO_INDEX]: "+",
		[ScoreCalculateType.TOTAL_ADD]: "+",
		[ScoreCalculateType.TOTAL_MULTI]: "x",
		[ScoreCalculateType.TOTAL_MULTI_2ND]: "x",
	}

	export class SpecialEvent {
		public static getName(__playtype: number, initiative: boolean = true): string {
			let conf = ROUND_REPORT_CONFIG[__playtype];
			if (conf != undefined && conf != null) {
				return !initiative ? conf.be : conf.name;
			}
			else {
				console.error("__playtype:", __playtype);
				return "unknow";
			}
		}
		public static getValue(__playtype: number): number {
			let conf = ROUND_REPORT_CONFIG[__playtype];
			if (conf != undefined && conf != null) {
				return conf.weight;
			}
			else {
				console.error("__playtype:", __playtype);
				return -1
			}
		}

		public static getUiSkin(__playtype: number, initiative: boolean = true): string {
			let conf = ROUND_REPORT_CONFIG[__playtype];
			if (conf != undefined && conf != null) {
				return (!initiative ? conf.beskin : conf.skin) + ".png";
			}
			else {
				console.error("__playtype:", __playtype);
				return "unknow.png"
			}
		}
	}
}--]]
return Constants