--奖马动画 一炮多项(暂未使用)
local CommandBase = require("app.manager.CommandBase")

local Command_BettingHorseMulti = class("Command_BettingHorseMulti", CommandBase)
local UI_ANIM = require("app.manager.UIAnimManager")

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_BettingHorseMulti:ctor( args )
    self.super:ctor(args)
    self._stepGroup = self.__args[2]
    self._scope = self.__args[3]
end

function Command_BettingHorseMulti:execute( args )
    -- H5 对应代码 onMultiJiangMa (这里的路径应该是有问题的，等做到这个地区的这个玩法再改)
    local step = self._stepGroup[1]
    
    -- 一炮多响的奖马
    if #step ~= 2 then
        return 0;
	end

    -- 生成动画
    local data = {all = {},highlight = {}};

    for _,v in ipairs(step) do
        if (v.playType == PlayType.DISPLAY_BETTING_HORSE_MULTI) then
            table.insert( data.highlight ,  v.cards);
        else
            table.insert( data.all ,  v.cards);
        end
    end

    --买马动画
    local cards = data.all;
    local animClip = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_mapai"..#cards..".csb", function()
    end))

	for i=1,#cards do
		-- 更换卡牌，牌面
		local cardTexture = animClip:getChild("Image_t_"..i.."_mapai"..#cards, "ccui.ImageView")
		cardTexture:loadTexture(CardFactory:getInstance():getSurfaceSkin(cards[i]), ccui.TextureResType.plistType)
		-- 决定牌是否高亮显示
		local imgHighlight	= animClip:getChild("imgHighlight_"..i, "ccui.ImageView") 
		imgHighlight:setVisible(table.indexof(data.highlight , cards[i]) ~= false)
	end

	if self._scope:getRoomSeat():getChairType() ~= nil then
		local root = animClip:getChild("Panel_mapai"..#cards, "ccui.Layout") 
		if showSeat == CardDefines.Chair.Down then
			root:setRotation(0)
		elseif showSeat == CardDefines.Chair.Left then
			root:setRotation(90)
		elseif showSeat == CardDefines.Chair.Top then
			root:setRotation(0)
		elseif showSeat == CardDefines.Chair.Right then
			root:setRotation(-90)
		end
	end
end

return Command_BettingHorseMulti
