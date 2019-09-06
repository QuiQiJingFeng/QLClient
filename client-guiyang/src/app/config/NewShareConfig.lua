local ns = namespace("config")

local NewShareConfig = class("NewShareConfig")
ns.NewShareConfig = NewShareConfig;

NewShareConfig.itemConfig = {
	[1] = {'参赛券×1','csb/Newshare/UITicket.csb', "art/function/icon_sq0.png"},
	[2] = {'金币X500','csb/Newshare/UIGold.csb', "art/function/icon_gold.png"},
	[3] = {'礼券X200','csb/Newshare/UIGiftTicket.csb', "art/function/icon_lq0.png"},
	[4] = {'2元红包','csb/Newshare/UIHongbao.csb', "art/function/icon_redbag.png"},
}

--各阶段需要的牌局数
-- NewShareConfig.rawardProgress = {0, 8, 40, 168}
NewShareConfig.rawardProgress = {0, 1, 2, 3}
--领取状态
NewShareConfig.getState ={
	CAN_GET = 1,
	ALREADY_GET = 2,
	CAN_NOT_GET = 3
}
--分享图片
NewShareConfig.shareImage = {
	[1] = "art/newshare/share_1.jpg",
	[2] = "art/newshare/share_2.jpg",
	[3] = "art/newshare/share_3.jpg",
	[4] = "art/fm/img_fm.png",
	[5] = "art/fm/img_fm.png",
	[6] = "art/fm/img_fm.png",
	[7] = "art/fm/img_fm.png",
	[8] = "art/fm/img_fm.png",
	[9] = "art/fm/img_fm.png",
	[10] = "art/newshare/share_10.jpg"
}

--找微信引导
NewShareConfig.findWxGuide = {
	[1] = {"打开安全分享，点击\"更多\"","art/function/wx_guide_1.png"},
	[2] = {"将微信打开，点击右上角完成按钮保存","art/function/wx_guide_2.png"},
	[3] = {"选择分享给好友或朋友圈","art/function/wx_guide_3.png"},
}
--规则
NewShareConfig.rule = "分享分为微信好友分享和朋友圈分享； 新用户通过分享链接下载并登录游戏时，即与分享人绑定，成为好友关系；每个用户可以拥有10个好友关系，每对好友关系自建立之日起3个月后自动解绑；\n拉新奖励\n老玩家每成功拉到一个新玩家，即可领取一张参赛券作为奖励；\n打牌奖励：\n新用户在俱乐部对局8局，奖励邀请人500金币； \n新用户在俱乐部对局40局，奖励邀请人200礼券；\n新用户在俱乐部对局168局，奖励邀请人2元红包；\n红包领取通过官方微信myqhd2017领取"


--获取百分比，n为完成局数
function NewShareConfig.getPercent(n)
	if n >= NewShareConfig.rawardProgress[4] then
		return 100
	end
	for i = 2, 4 do
		if n < NewShareConfig.rawardProgress[i] then
			local p = (n - NewShareConfig.rawardProgress[i - 1]) / (NewShareConfig.rawardProgress[i]- NewShareConfig.rawardProgress[i - 1]) / 3 * 100
			return 33 * (i -2) + p
		end
	end 
end