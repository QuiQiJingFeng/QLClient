--奖马动画 
local CommandBase = require("app.manager.CommandBase")
local Constants = require("app.gameMode.mahjong.core.Constants")
local Command_FanGui = class("Command_FanGui", CommandBase)
local UI_ANIM = require("app.manager.UIAnimManager")

--是否开启步骤提示
local ENABLE_STEP_LOG = false;

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_FanGui:ctor(args)
	self.super:ctor(args)
	self._isRecover = self.__args[1]
	self._stepGroup = self.__args[2]
	self._scope = self.__args[3]
end

function Command_FanGui:execute(args)
	
	if self._isRecover then
		return 0;
	end
	
	local temp = self._stepGroup[1]._cards
	local _gameType = Constants.SpecialEvents.gameType
	if _gameType ~= "GAME_TYPE_R_GUIYANG" then 
		--翻鬼处理失败
		Macro.assertTrue(#self._stepGroup[1]._cards < 2)
	end 
	
	-- // (ui.tx_guipaiUI.prototype as any).NeedBlackMask = () => { return true; }
	-- // (ui.tx_guipaiUI.prototype as any).CloseWhenClickMask = () => { return { close: false, destroy: false }; }
	local animClip = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_fangui.csb", function()
	end))
	
	-- 更换卡牌，牌面
	local fanpaiCard = animClip:getChild("Fanpai_Card", "ccui.ImageView")
	fanpaiCard:loadTexture(CardFactory:getInstance():getSurfaceSkin(temp[1]), ccui.TextureResType.plistType)
	
	local guipaiCard = animClip:getChild("Guipai_Card", "ccui.ImageView")
	guipaiCard:loadTexture(CardFactory:getInstance():getSurfaceSkin(temp[2]), ccui.TextureResType.plistType)
	
	-- 是否开启双鬼
	local isNeedTwoGuipai = #temp > 2;
	
	local shuanggui = animClip:getChild("Shuanggui_Image", "ccui.ImageView")
	shuanggui:setVisible(isNeedTwoGuipai);
	
	if isNeedTwoGuipai then
		local shuangguiCard = animClip:getChild("Shuanggui_Card", "ccui.ImageView")
		shuangguiCard:loadTexture(CardFactory:getInstance():getSurfaceSkin(temp[2]), ccui.TextureResType.plistType)
	end
	
	
	-- local battlePage = UIManager.Instance.GetUI(BattlePage);
	-- animUI.ani1.on(Laya.Event.COMPlocalE, this, () => {
	--     battlePage.timer.once(500, this, () => {
	--         CardFactory:getInstance():releaseCard(fanpai);
	--         CardFactory:getInstance():releaseCard(guiPai);
	--         if (isNeedTwoGuipai) CardFactory:getInstance():releaseCard(guiPai2);
	--         UIManager.Instance.Destroy(ui.tx_guipaiUI);
	--         if (onFinish)
	--             onFinish();
	--     });
	-- });
	-- animUI.ani1.play(0, false);
	return 800;
end

return Command_FanGui
