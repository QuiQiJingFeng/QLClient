-------------------------------------------------
-- 比赛场内开场动画播放类
local CampaignAnimPlayer = class("CampaignAnimPlayer")

CampaignAnimPlayer._instance = nil
function CampaignAnimPlayer:ctor()

end

-- 单例
function CampaignAnimPlayer:getInstance()
    if nil == CampaignAnimPlayer._instance then
        CampaignAnimPlayer._instance = CampaignAnimPlayer:new()
    end
    return CampaignAnimPlayer._instance;
end

--[[
@param node 动画挂载的节点
@param anim 动画的路径
@param scale 动画的缩放
@param isLoop 是否循环播放
]]
function CampaignAnimPlayer:play( node, anim, scale, isLoop)
    local _scale = scale or 1
    local _isLoop = isLoop or false

    local csbAnim = kod.LoadCSBNode(anim)
    csbAnim:setScale(_scale)
    local action = cc.CSLoader:createTimeline(anim)
    csbAnim:runAction(action)
	action:play("animation0", _isLoop)
    node:addChild(csbAnim)
    csbAnim:setPosition(cc.p(0,0))
    
    return csbAnim
end

--[[
    播放动画，并在animation1动画中一直停留
@param node 动画挂载的节点
@param anim 动画的路径
@param scale 动画的缩放
@param isLoop 是否循环播放
]]
function CampaignAnimPlayer:play1AndStay2( node, anim, scale, isLoop)
    local _scale = scale or 1
    local _isLoop = isLoop or false

    local csbAnim = kod.LoadCSBNode(anim)
    csbAnim:setScale(_scale)
    local action = cc.CSLoader:createTimeline(anim)
    csbAnim:runAction(action)
	action:play("animation0", _isLoop)
    node:addChild(csbAnim)
    local schedule = scheduleOnce(function ()
        if action.play ~= nil then
            action:play("animation1", true)
        end
    end,self:getAnimTime(action),csbAnim)
    
    return csbAnim , schedule
end

--[[
获取当前动画实际时间
因为lua没有导出动画播放完成后的回调
]]
function CampaignAnimPlayer:getAnimTime(timeline)
    local speed = timeline:getTimeSpeed()
    local startFrame = timeline:getStartFrame()
    local endFrame = timeline:getEndFrame()
    local frameNum = endFrame - startFrame

    return 1.0 /(speed * 60.0) * frameNum
end

return CampaignAnimPlayer