--[[
    @desc: 比赛开始时动画都挂在这个ui上
    author:{贺逸}
    time:2018-06-21
    return
]]
local csbPath = "ui/csb/Campaign/anim/AnimPlayPanel.csb"
local super = require("app.game.ui.UIBase")
local UI_ANIM = require("app.manager.UIAnimManager")

local UICampaignAnimPanel = class("UICampaignAnimPanel", super, function() return kod.LoadCSBNode(csbPath) end)

function  UICampaignAnimPanel:ctor()
    super.ctor(self)
    self._animNode = nil;
    self._animList = {}

    self.schedule = nil
end

function UICampaignAnimPanel:init()
    self._animNode = seekNodeByName(self, "Node_1", "cc.Node")
end

function UICampaignAnimPanel:onShow( ... )
    self._animList = game.service.CampaignService.getInstance():getAnimCache():getCache()
    self:_playAnim(self._animList)    
end

function UICampaignAnimPanel:_playAnim(anims)
    -- 将缓存的动画都丢进来，进行排队播放，播放完毕后关闭该界面
    if anims[1] == nil then 
        UIManager:getInstance():destroy("UICampaignAnimPanel");
        game.service.CampaignService.getInstance():getAnimCache():clear()        
        return
    end
    -- 如果这时候还在显示晋级动画则关闭之
    if UIManager:getInstance():getIsShowing("UICampaignPromotion") == true then
        UIManager:getInstance():destroy("UICampaignPromotion")
    end

    if anims[1].name == "CampaignStart" then   
        if game.service.CampaignService.getInstance():getArenaService():getIsFinal() then
            local anim = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["FINALCAMPAIGN2"],false, function() 
                table.remove(anims,1)
                self:_playAnim(anims)
            end)
        else
            local anim = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["START"],false, function() 
                table.remove(anims,1)
                self:_playAnim(anims)
            end)
            local text = anim:getChildByName("BitmapFontLabel_1")
            local text2 = anim:getChildByName("BitmapFontLabel_1_0")
            local text3 = anim:getChildByName("BitmapFontLabel_2")
            local round = game.service.CampaignService.getInstance():getArenaService():getCurrentRound()
            local rank = game.service.CampaignService.getInstance():getArenaService():getPromotionNum();
            if game.service.CampaignService.getInstance():getCampaignList():getCurrentCampaignId() == config.CampaignConfig.ARENA_ID then
                text3:setString("第" .. round .."轮")
                text:setPositionX(150)
                text2:setPositionX(150)
                text:setString(string.format("前%s名晋级", rank))
                text2:setString(string.format("前%s名晋级", rank))
                text3:setVisible(true)
                text2:setVisible(true)
            else
                text:setPositionX(0)
                text2:setPositionX(0)
                text:setString("开始比赛")
                text2:setString("开始比赛")
                text2:setVisible(false)
                text3:setVisible(false)
            end
        end
    elseif anims[1].name == "PromotionReward" then
        local anim = self:_addCenterAnim(config.CampaignConfig.CampaignAnim["PROMOTREWARD"],false, function() 
            table.remove(anims,1)
            self:_playAnim(anims)
        end)
        local rankText = anim:getChildByName("BitmapFontLabel_1_0")
        local normalText = anim:getChildByName("BitmapFontLabel_1_0_0")
        local rank = game.service.CampaignService.getInstance():getArenaService():getPromotionNum();
        local round = game.service.CampaignService.getInstance():getArenaService():getCurrentRound()
        if rank ~= nil then
            rankText:setString(string.format("第%s轮 前%s名晋级", round,rank))
        end 

        local delay = cc.DelayTime:create(0.16)

        rankText:setScaleX(0.1)
        rankText:setScaleY(0.1)
        normalText:setScaleX(0.1)
        normalText:setScaleY(0.1)

        rankText:runAction(cc.Sequence:create(
            delay,
            cc.ScaleTo:create(0.5, 1.2, 1.2),
            cc.ScaleTo:create(0.16, 0.9, 0.9),
            cc.ScaleTo:create(0.16, 1.0, 1.0)
        ))
        rankText:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.16, 10),
            cc.FadeTo:create(0.5, 255)
        ))
        normalText:runAction(cc.Sequence:create(
            delay,
            cc.ScaleTo:create(0.5, 1.2, 1.2),
            cc.ScaleTo:create(0.16, 0.9, 0.9),
            cc.ScaleTo:create(0.16, 1.0, 1.0)
        ))
        normalText:runAction(cc.Sequence:create(
            cc.FadeTo:create(0.16, 10),
            cc.FadeTo:create(0.5, 255)
        ))
    end
end

-- 中间动画
function UICampaignAnimPanel:_addCenterAnim(anim,isLoop,callback)
    local node = UI_ANIM.UIAnimManager:getInstance():onShow({
		_path = anim,
        _parent = self._animNode,
        _callback = callback,
        _replay = isLoop
	})
    return node._csbAnim
end

function UICampaignAnimPanel:onHide()
end

function UICampaignAnimPanel:dispose()

end
---------------------------------------------------------------------------

function UICampaignAnimPanel:needBlackMask()
	return false;
end

function UICampaignAnimPanel:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignAnimPanel:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end
return UICampaignAnimPanel