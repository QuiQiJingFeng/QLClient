local csbPath = "ui/csb/Club/UIClubZhuoJi_Introduction2.csb"
local super = require("app.game.ui.UIBase")

local UIClubZhuoJiHelp = class("UIClubZhuoJiHelp", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubZhuoJiHelp:ctor()
	
end

function UIClubZhuoJiHelp:init()
	-- self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	
	-- self._textContent = seekNodeByName(self, "Text_content_ZhuoJiReward", "ccui.Text")
	
	-- self._scorllView = seekNodeByName(self, "ScrollView_ZhuoJiReward", "ccui.ScrollView")
	-- self._scorllView:setScrollBarEnabled(false)
	self:_registerCallBack()
end

function UIClubZhuoJiHelp:_registerCallBack()
	-- bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
end

function UIClubZhuoJiHelp:onShow(totalReward, catcherLimit)
	local helpString = [[
活动说明：
捉鸡寻宝是亲友圈群主专属活动。群主可使用亲友圈房卡制造捕捉器用于捉鸡，每10张亲友圈房卡可制造一个捕捉器，可累积制造。每期活动捕捉器数量达到%d个时，活动开奖，鸡会随机困在其中一个捕捉器中，制造该捕捉器的群主可获得%d张亲友圈房卡奖励。当一只鸡被捕捉，就会有新的鸡出现，活动继续。群主制造的捕捉器越多，获奖概率越大哦！！！

每期活动奖品：
%d张亲友圈房卡

每期开奖条件：
参与活动群主制造捕捉器总数达到%d个

参与流程：
1.制造捕捉器：每10张亲友圈房卡可以制造一个捕捉器，每一期您都可以自由选择数量并累加，若您制造的捕捉器超过了活动捕捉器上限，系统将自动退还多余的房卡；
2.活动开奖：每期活动捕捉器总量达到%d个时，随机诞生一位幸运群主。幸运群主可得%d亲友圈房卡，系统会自动发送到该群主的后台；
3.新活动开启：每期活动结束，新一期活动立刻开始；
	]]
	
	-- helpString = string.format(helpString, catcherLimit, totalReward, totalReward, catcherLimit, catcherLimit, totalReward)
	
	-- self._textContent:setString(helpString)
	
end

function UIClubZhuoJiHelp:needBlackMask()
	return true
end

function UIClubZhuoJiHelp:closeWhenClickMask()
	return true
end


function UIClubZhuoJiHelp:_onClose()
	
	UIManager.getInstance():hide("UIClubZhuoJiHelp")
end

return UIClubZhuoJiHelp 