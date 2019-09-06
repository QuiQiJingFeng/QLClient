-- 癞子鸡动画（一张）
local super = require("app.manager.CommandBase")
local Constants = require("app.gameMode.mahjong.core.Constants")
local Command_LaiZiJi = class("Command_LaiZiJi", super)
local UI_ANIM = require("app.manager.UIAnimManager")

--是否开启步骤提示
local ENABLE_STEP_LOG = false;

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_LaiZiJi:ctor(args)
	self.super:ctor(args)
	self._isRecover = self.__args[1]
	self._stepGroup = self.__args[2]
	self._scope = self.__args[3]
end

function Command_LaiZiJi:execute(args)
	if self._isRecover then
		return 0;
	end
	
	-- 癞子鸡只有一张
	local temp = self._stepGroup[1]._cards
	if #temp ~= 1 then 
		return 
	end 

	local csbName = "ui/csb/Effect_fangui.csb"
	local animClip = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new(csbName, function()end))
	
	-- 更换牌面
	local fanpaiCard = animClip:getChild("Fanpai_Card", "ccui.ImageView")
	fanpaiCard:loadTexture(CardFactory:getInstance():getSurfaceSkin(temp[1]), ccui.TextureResType.plistType)
	
	-- 隐藏无关牌面
	animClip:getChild("Image_1_1_0", "ccui.ImageView"):setVisible(false)
	animClip:getChild("Guipai_Image", "ccui.ImageView"):setVisible(false)
	animClip:getChild("Shuanggui_Image", "ccui.ImageView"):setVisible(false)
	
	return 800
end

return Command_LaiZiJi
