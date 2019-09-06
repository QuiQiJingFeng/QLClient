local ns = namespace("config")

local WeekSignConfig = class("WeekSignConfig")
ns.WeekSignConfig = WeekSignConfig;

WeekSignConfig.operateType = {
	sign = 1,		--签到
	supplement= 2	--补签
}

WeekSignConfig.statusType = {
	refuse_operate = 0 ,		--不可签到或补签
	can_sign_in	   = 1 ,		--可签到
	can_supplement = 2 ,		--可补签
	sign_in  	   = 3 ,		--已签到
	supplement 	   = 4 ,		--已补签
}

WeekSignConfig.itemConfig = {
	{"参赛券X1", "art/function/icon_q1.png"},
	{"金币5000", "art/function/icon_j5000.png"},
	{"房卡X1", "art/function/icon_f1.png"},
	{"中秋头像框(三天)", "art/function/icon_t12.png"},	
	{"金币5000", "art/function/icon_j5000.png"},
	{"参赛券X1", "art/function/icon_q1.png"},
	{"中秋头像框(永久)", "csb/HeadFrame/frames/frame_lstm.csb","房卡X1","art/function/icon_f1.png"},
}

function WeekSignConfig.getItemName(day)
	if day >=1 and day<=7 then
		return WeekSignConfig.itemConfig[day][1]
	end
	return ""
end


WeekSignConfig.rule = "活动时间：4.11-4.20；\n活动期间，每天登录即可签到领取当天对应奖励；\n未签到的日期，可通过补签来领取当天对应奖励，每次补签使用两张房卡，每天可多次补签；\n签到或补签满六天，方可签到获得第七天对应奖励；"