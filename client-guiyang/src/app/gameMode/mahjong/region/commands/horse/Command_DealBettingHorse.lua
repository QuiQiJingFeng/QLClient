--奖马动画 
local CommandBase = require("app.manager.CommandBase")

local Command_DealBettingHorse = class("Command_DealBettingHorse", CommandBase)
local UI_ANIM = require("app.manager.UIAnimManager")

--是否开启步骤提示
local ENABLE_STEP_LOG = false;

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_DealBettingHorse:ctor( args )
    self.super:ctor(args)
    self._stepGroup = self.__args[2]
    self._scope = self.__args[3]
end

function Command_DealBettingHorse:execute( args )
    if args[1] == true then
        return
    end
    
    local steps = self._stepGroup

    local totalCards = steps[1]._cards;
    local matchedCards = steps[2]._cards;

    --买马动画
    local animClip = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_mapai"..#totalCards..".csb", function()
    end))

	for i=1,#totalCards do
		-- 更换卡牌，牌面
		local cardTexture = animClip:getChild("Image_t_"..i.."_mapai"..#totalCards, "ccui.ImageView")
		cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(totalCards[i]), ccui.TextureResType.plistType)
		-- 决定牌是否高亮显示
		local imgHighlight	= animClip:getChild("imgHighlight_"..i, "ccui.ImageView") 
		imgHighlight:setVisible(table.indexof(matchedCards , totalCards[i]) ~= false)
	end

    -- if (ENABLE_STEP_LOG) {
    --     local log = "奖马：\n";
    --     for i,v in ipairs(totalCards) do
    --         log = `${log}${GetCardName(totalCards[i])},`;
    --     end
    --     log += "\n中马：\n";
    --     for i,v in ipairs(matchedCards) do
    --         log = `${log}${GetCardName(matchedCards[i])},`;
    --     end
    --     console.log(log);
    -- }

end

return Command_DealBettingHorse
