local csbPath = "ui/csb/UI_Talking.csb"
local super = require("app.game.ui.UIBase")

local UI_Talking = class("UI_Talking", super, function () return kod.LoadCSBNode(csbPath) end)

function UI_Talking:ctor()
	self.Img_ht1_Talking = nil
	self.Img_ht2_Talking = nil
	self.Img_xh3_Talking = nil
	self.Img_xh2_Talking = nil
	self.Img_xh1_Talking = nil
end

function UI_Talking:init()
	self.Img_ht1_Talking = seekNodeByName(self, "Img_ht1_Talking", "cc.Sprite")
	self.Img_ht2_Talking = seekNodeByName(self, "Img_ht2_Talking", "cc.Sprite")
	self.Img_xh3_Talking = seekNodeByName(self, "Img_xh3_Talking", "cc.Sprite")
	self.Img_xh2_Talking = seekNodeByName(self, "Img_xh2_Talking", "cc.Sprite")
	self.Img_xh1_Talking = seekNodeByName(self, "Img_xh1_Talking", "cc.Sprite")
end


function UI_Talking:onShow(...)
	local parms = {...}
	if parms[1] == true then
		self.Img_ht2_Talking:setVisible(false)
		self.Img_ht1_Talking:setVisible(true)
		
		local func1 = cc.CallFunc:create(function ()
			self.Img_xh1_Talking:setVisible(true)
			self.Img_xh2_Talking:setVisible(false)
			self.Img_xh3_Talking:setVisible(false)
		end)
		
		local func2 = cc.CallFunc:create(function ()
			self.Img_xh1_Talking:setVisible(false)
			self.Img_xh2_Talking:setVisible(true)
			self.Img_xh3_Talking:setVisible(false)
		end)
		
		local func3 = cc.CallFunc:create(function ()
			self.Img_xh1_Talking:setVisible(false)
			self.Img_xh2_Talking:setVisible(false)
			self.Img_xh3_Talking:setVisible(true)
		end)
		
		local delay1 = cc.DelayTime:create(0.3)
		local delay2 = cc.DelayTime:create(0.3)
		local delay3 = cc.DelayTime:create(0.3)
		
		local sequ = cc.Sequence:create(func1,delay1,func2,delay2,func3,delay3)
		local forever = cc.RepeatForever:create(sequ)
		
		self.Img_ht1_Talking:runAction(forever)
	else
		self.Img_ht1_Talking:stopAllActions()
		self.Img_ht2_Talking:setVisible(true)
		self.Img_ht1_Talking:setVisible(false)
		self.Img_xh1_Talking:setVisible(false)
		self.Img_xh2_Talking:setVisible(false)
		self.Img_xh3_Talking:setVisible(false)
	end
	
	-- 播放语音的时候暂时禁止游戏内音乐
	manager.AudioManager.getInstance():mute()
end

function UI_Talking:onHide()
	self.Img_ht1_Talking:stopAllActions()
	self.Img_ht2_Talking:setVisible(false)
	self.Img_ht1_Talking:setVisible(false)
	self.Img_xh1_Talking:setVisible(false)
	self.Img_xh2_Talking:setVisible(false)
	self.Img_xh3_Talking:setVisible(false)

	manager.AudioManager.getInstance():unmute()
end

function UI_Talking:needBlackMask()
	return false
end

function UI_Talking:closeWhenClickMask()
	return false
end

return UI_Talking