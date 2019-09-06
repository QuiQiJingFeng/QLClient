local ns = namespace("config")
-- 层级范围,ui实现层级排序相关功能
local UIConstants = {
    -- UI基础层级
    UIZorder = 50,
    UI_LAYER_MAX_UI = 200;
    UI_LAYER_ID     = {BottomMost = 1, Bottom = 2, Normal = 3, Top = 4, TopMost = 5};
}

ns.UIConstants = UIConstants

local UIRecordLevel ={
	MainLayer = 1,
	MainButton = 2,
	OtherLayer = 3,
	OtherButton = 4
}
ns.UIRecordLevel = UIRecordLevel

local UIDestops = {
    ["2D_1"] = "art/gaming/destop1.png",
    ["2D_2"] = "art/gaming/destop2.png",
	["2D_3"] = "art/gaming/destop3.png",
	["2D_classic"] = "art/gaming/destop.png",
	["3D_1"] = "art/table_3d/mj_desktop1.png",
	["3D_2"] = "art/table_3d/mj_desktop2.png",
	["3D_3"] = "art/table_3d/mj_desktop3.png",
	["3D_classic"] = "art/table_3d/mj_desktop.png",
}

ns.UIDestops = UIDestops

ns.CONST_CLONED_NAME = "itemcloned"


ns.SHARE_TYPE = {
	SCREEN_SHOT = 1, -- 截屏
	SCREEN_SHOT_WITH_LOGO = 2, -- 截屏logo
	URL = 3, -- 链接
    MAIN_URL = 4, -- 大厅链接
    URL_IS_PIC_PATH = 5, -- 自带图片分享
}

-- 牌的皮肤
local cardStyles = {
	["STYLE_1"] = "style_1",
	["STYLE_2"] = "style_2",
	["STYLE_3"] = "style_3",
	["STYLE_1_3D"] = "style_1_3d",
	["STYLE_2_3D"] = "style_2_3d",
	["STYLE_3_3D"] = "style_3_3d",
	["STYLE_1_CLASSICAL"] = "style_1_classical",
	["STYLE_3D_CLASSICAL"] = "style_3d_classical",
}

-- 具体配置
local cardStyleCfg = {
	[cardStyles.STYLE_1] = {
		["name"] = "STYLE_1",
		["atlas"] = "mahjong_card",
		["csb"] = "c01",
		['bg'] = "bg01"
	},
	[cardStyles.STYLE_2] = {
		["name"] = "STYLE_2",
		["atlas"] = "mahjong_card",
		["csb"] = "c01",
		['bg'] = "bg02"
	},
	[cardStyles.STYLE_3] = {
		["name"] = "STYLE_3",
		["atlas"] = "mahjong_card",
		["csb"] = "c01",
		['bg'] = "bg03"
	},
	[cardStyles.STYLE_1_3D] = {
		["name"] = "STYLE_1_3D",
		["atlas"] = "mahjong_card_3d_new",
		["csb"] = "3d_new",
		['bg'] = "bg01"
	},
	[cardStyles.STYLE_2_3D] = {
		["name"] = "STYLE_2_3D",
		["atlas"] = "mahjong_card_3d_new",
		["csb"] = "3d_new",
		['bg'] = "bg01"
	},
	[cardStyles.STYLE_3_3D] = {
		["name"] = "STYLE_3_3D",
		["atlas"] = "mahjong_card_3d_new",
		["csb"] = "3d_new",
		['bg'] = "bg01"
	},
	[cardStyles.STYLE_1_CLASSICAL] = {
		["name"] = "STYLE_1_CLASSICAL",
		["atlas"] = "mahjong_card_classical",
		["csb"] = "classical",
		['bg'] = "bg01"
	},
	[cardStyles.STYLE_3D_CLASSICAL] = {
		["name"] = "STYLE_3D_CLASSICAL",
		["atlas"] = "mahjong_card_classical",
		["csb"] = "3d_new",
		['bg'] = "bg01"
	}
}
ns.CARD_STYLE = cardStyles
ns.CARD_STYLE_CFG = cardStyleCfg

-- 分享地址
local localShare = 
{
	main = "main", -- 大厅
	moneyTree = "moneyTree", -- 摇钱树
	result_single = "result_single", -- 单句结算
	result_total = "result_total", --总结算
	redPacket = "redPacket", --红包
	reward = "reward", -- 奖励
	activity = "activity", -- 活动
	timeOut = "timeOut", --超时
	roomRules = "roomRules", -- 房间
	campaign = "campaign", -- 比赛
    ActingCreateInvite = "ActingCreateInvite", -- 代开房间邀请
    SingleRound = "SingleRound"  --单局分享
}

ns.LOCALSHARE = localShare



ns.CONVERT_NUM = {
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
    [7] = "七",
    [8] = "八",
    [9] = "九",
    [10] = "零",
}

local agtStyle =
{
	main = 1,
	club = 2,
}

local mainUIButtons ={
	joinRoom = "Button_JoinRoom", -- 加入房间
	activity = 'Button_Main_Activity',	--活动
	message = 'Button_Main_Message',	--消息
	history = 'Button_Main_History',	--战绩
	share = 'Button_Main_Share',		--分享
	bag = 'Button_Bag',		--背包
	agent_before = 'Button_zq',			--成为代理
	agent_after = 'Button_dl',		--代理后台
	shop = 'Button_Active_ChouJiang_0',	--商城
	free_card = 'Button_Active_FenXiang',	--免费房卡
	tree = 'Button_Active_YaoQianShu',		--摇钱树
	zuanshi = 'Button_Update_Reward',		--更新送钻
	liquan = 'Button_Active_FenXiang_0',		--礼券商城
	gamble = 'btnGamble', 					-- 竞彩功能
	fanpai = 'Button_Active_YaoQianShu_0',		--翻牌有奖
	report = 'Button_report', -- 举报
	verified = 'Button_smrz0', -- 实名认证
	verified_ok = 'Button_smrz0_0', -- 已实名认证
	pullNew = 'Button_pullNew', -- 拉新活动
	lucky_draw = 'Button_Active_ChouJiang', --消耗抽奖
	week_sign = 'Button_queshen',	--七日抽奖
	qixi_charge = "btnQiXiCharge",	--七夕充值
	qixi_two_gay = 'btnQiXiTwoGay',	--七夕二人世界
	egg = 'Button_egg',		--砸蛋
	more = 'Button_More',			--更多
	chuanqi = 'Button_Chuanqi',		--传奇来了
	friend = 'Button_Main_Friend', --  好友
	monthsign = 'Button_MonthSign',	--月签到
	guoQing = 'Panel_guoqing',		-- 国庆
	bindphone = 'Panel_Phone_Activity', --绑定手机活动
    btnShuang11 = "Panel_shuang11",		--双11活动
    Button_Comeback = "Button_Comeback", -- 回流活动
	btnleaderboardActivity = "Button_leaderboardActivity", --俱乐部排行榜活动
    btnAccountRecovery = "btnAccountRecovery", -- 账号找回
	feedback = "Button_kf", -- 反馈 美洽
	redpack = "Button_Redpack",				--拆红包
	buyu = 'Layout_Buyu', -- 捕鱼
	btnBlessing = "btnBlessing", --祈福
    btnChristmasSign = "btnChristmasSign", --圣诞签到
    btnSpringInvited = "btnSpringInvited",
	Button_CollectCode = "Button_CollectCode", -- 集码活动
	ClubRed = "Button_rw_top_Clubpj", -- 俱乐部红包
    Nianbao = "Panel_nb",			--年报
    Questionnare = "Button_Questionnare", -- 调查问卷
	welfare = "Panel_Phone_Activity_0", -- 每日福利,
	ufo_catcher = "Button_UFOCatcher", -- 抓娃娃
}
--获取主界面的按钮是否配置为显示
function ns.checkButtonShowByName(name)
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	local area_config = MultiArea.getMainUI(areaId)
	if area_config == nil then
		return false
	end
	local find = false
	for _,key in pairs(area_config) do
		if mainUIButtons[key] == name then
			find = true
			break
		end
	end
	return find
end


ns.AGTSTYLE = agtStyle