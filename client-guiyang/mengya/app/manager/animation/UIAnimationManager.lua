local UIAnimationManager = class("UIAnimationManager")

local _instance = nil
--------------------------------------------------------------
function UIAnimationManager:ctor()

end

function UIAnimationManager:getInstance()
    if _instance == nil then
        _instance = UIAnimationManager.new()
    end

    return _instance
end

function UIAnimationManager:destroy()
    if _instance then
        _instance:dispose()
    end
end

function UIAnimationManager:dispose()
end

--[[
获取当前动画实际时间
因为lua没有导出动画播放完成后的回调
因为是按照60FPS算的,所以跟实际上可能是有误差的
]]
function UIAnimationManager:getAnimTime(timeline)
    local speed = timeline:getTimeSpeed()
    local startFrame = timeline:getStartFrame()
    local endFrame = timeline:getEndFrame()
    local frameNum = endFrame - startFrame

    local isDone = timeline:isDone()
    return 1.0 /(speed * 60.0) * frameNum
end


--指定父节点添加之后播放动画
function UIAnimationManager:playAnimationWithParent(parent,target,csbPath,aminateName,pos,zorder,finishFunc,delay,replay)
    if target then
        self._animNode = target
    else
        self._animNode = cc.CSLoader:createNode(csbPath)
    end
    
    self._action = cc.CSLoader:createTimeline(csbPath)
    self._animNode:runAction(self._action)
    if parent then
        local child = parent:getChildByTag(999)
        if child then
            child:removeSelf()
        end
        self._animNode:setTag(999)
        parent:addChild(self._animNode)
    end
    local callbackNode = cc.Node:create()
    self._animNode:addChild(callbackNode)

    replay = replay or false
    if pos then self._animNode:setPosition(pos) end
    if zorder then self._animNode:setLocalZOrder(zorder) end
    if aminateName then
        local info = self._action:getAnimationInfo(aminateName)
        self._action:gotoFrameAndPlay(info.startIndex, info.endIndex,replay)
    else
        self._action:gotoFrameAndPlay(0,replay)
    end

    if finishFunc and not replay then
        delay = delay or 0
        local time = self:getAnimTime(self._action) + delay
        app.Util:scheduleOnce(finishFunc,time,callbackNode)
    end
end
--[[
example:
    scheduleOnce(function() 
        local UIAnimationManager = app.UIAnimationManager
        UIAnimationManager:getInstance():playAnimation("xx.csb","animation0",self,display.center,0,function() 
            print("FYD-=---------END=======")
            self:setRotation(10)
        end)
    end,1)
]]

return UIAnimationManager