local UI_ANIM = {}
local UIAnim = class("UIAnim")
local UIAnimConfig = class("UIAnimConfig")
local UIAnimManager = class("UIAnimManager")

-- 播放动画的实体
UI_ANIM.UIAnim = UIAnim
-- 播放动画的配置
UI_ANIM.UIAnimConfig = UIAnimConfig
-- 播放动画的管理器
UI_ANIM.UIAnimManager = UIAnimManager

--"ui/csb/Effect_cfwgj.csb"
--------------------------------------------------------------
function UIAnim:ctor(path)
    self._path = path

    -- 为了能够让动画的csd也参与适配
    self._csbAnim = kod.LoadCSBNode(path)
    -- self._csbAnim:setPosition(cc.p(0,0))
    self._action = cc.CSLoader:createTimeline(path)
    self._csbAnim:runAction(self._action)
    -- self._action:gotoFrameAndPlay(0,false)
    -- self:addChild(self._csbAnim)
    self._csbAnim:setAnchorPoint(cc.p(0.5, 0.5))
    self._parent = nil
    self._schedule = nil
    -- 改用自己的节点来调用回调，可以有效控制生命周期结束后不再调用回调。
    self._callbackNode = cc.Node:create();
    self._csbAnim:addChild(self._callbackNode);
end

--[[
@param pos 全局坐标
]]
function UIAnim:pos(pos)
    local parent = self._csbAnim:getParent()
    local newPos = parent:convertToNodeSpace(pos)
    self._csbAnim:setPosition(newPos)
end

--[[
@param target 在某个控件位置播放动画
]]
function UIAnim:toPos(target)
    local targetParent = target:getParent()
    local x,y = target:getPosition()
    local pos = targetParent:convertToWorldSpace(cc.p(x,y))
    self:pos(pos)
end

--[[
中心位置播放动画
]]
function UIAnim:center()
    local size = cc.Director:getInstance():getWinSize()
    local pos = cc.p(size.width/2,size.height/2)
    self:pos(pos)
end

--[[
获取当前动画实际时间
因为lua没有导出动画播放完成后的回调
]]
function UIAnim:getAnimTime(timeline)
    local speed = timeline:getTimeSpeed()
    local startFrame = timeline:getStartFrame()
    local endFrame = timeline:getEndFrame()
    local frameNum = endFrame - startFrame

    return 1.0 /(speed * 60.0) * frameNum
end

--[[
@param parent 要添加动画的节点
@param zorder 动画的zorder
]]
function UIAnim:show(parent, zorder)
    if self._parent == nil then
        self._parent = parent
        self._parent:addChild(self._csbAnim)
    end
    if zorder ~= nil then
        self._csbAnim:setLocalZOrder(zorder)
    else
        self._csbAnim:setLocalZOrder(config.UIConstants.UIZorder)
    end
    self._csbAnim:setVisible(true)
end

--[[
]]
function UIAnim:hide()
    if self._schedule then
        unscheduleOnce(self._schedule,self._callbackNode);
    end
    self._csbAnim:setVisible(false)
    self._csbAnim:removeFromParent(true)
    self._parent = nil
end

--[[
@param pCallback 播放完成后的回调
@param pAction 播放的动作，现在似乎无用
@param pReplay 是否重复播放
@param pDelay 是否需要延时
]]
function UIAnim:play(pCallback, pAction, pReplay, pDelay)
    if self._csbAnim then
        local callback = pCallback
        local action = pAction or 0
        local replay = pReplay or false
        local delay = pDelay or 0
        self._action:gotoFrameAndPlay(0, replay)
        if not replay then
            -- 此处用getRunningScene 来调用回调，不容易控制生命周期， 而应该用自己的node来调用，
            -- 用自己的node调用可以在被remove的时候自动调用stopAllAction，从而关闭回调（c++层调用）
            self._schedule = scheduleOnce(function()
                -- self._csbAnim:removeFromParent(true)
                -- 播放完成后，可能需要延时一会
                self._schedule = nil
                if delay > 0 then
                    self._schedule = scheduleOnce(function()
                        self._schedule = nil
                        if callback then
                            callback()
                        end
                    end, delay)
                elseif delay ~= -1 then
                    if callback then
                        callback()
                    end
                end
            end, self:getAnimTime(self._action),self._callbackNode)
        else
            -- 重复播放，如果有延时，延时完成后，结束
            if delay > 0 then
                self._schedule = scheduleOnce(function()
                    self._schedule = nil
                    if callback then
                        callback()
                    end
                end, delay,self._callbackNode)
            end
        end
    end
end

function UIAnim:getChild(name, type_)
    return seekNodeByName(self._csbAnim, name, type_)
end
--------------------------------------------------------------

--------------------------------------------------------------
--[[**
 * param：what 可以是UIAnimConfig，作拷贝构造，也可以是{_path=""}这类的配置，要注意节点名字
 *        也可以直接是对应ui节点名字
 * 其它参数可以参照上面的成员变量相关
 * 如果要在弹窗上播动画，需要传入parent节点
 *]]
function UIAnimConfig:ctor(what, callback, delay, offset, scale, action, replay, parent, stay)
    if type(what) == "string" then
        self._path = what
        self._callback = callback
        self._delay = delay
        self._offset = offset
        self._scale = scale
        self._action = action
        self._replay = replay
        self._parent = parent
        self._stay = stay
    else
        -- 如果不是字符串，默认为拷贝构造
        self._path = what._path
        self._callback = what._callback
        self._delay = what._delay
        self._offset = what._offset
        self._scale = what._scale
        self._action = what._action
        self._replay = what._replay
        self._parent = what._parent
        self._stay = what._stay
    end
end
--------------------------------------------------------------

local _instance = nil
--------------------------------------------------------------
function UIAnimManager:ctor()
    self._animList = {}
end

function UIAnimManager:getInstance()
    if _instance == nil then
        _instance = UIAnimManager.new()
    end

    return _instance
end

function UIAnimManager:destroy()
    if _instance then
        _instance:dispose()
    end
end

function UIAnimManager:dispose()
end

function UIAnimManager:create(path)
    return UIAnim.new(path)
end

function UIAnimManager:onShow(config, before)
    -- 必须是有一个有效的路径
    if config._path then
        local anim = self:create(config._path)
        self:addOneAnim(anim)
        local parent = config._parent;
        if not parent then
            parent = UIManager:getInstance():getCurBottomUI();
        end
        if not parent then
            Logger.error(" ========== UIAnimManager onShow parent is nil==========> ")
            return;
        end
        anim:show(parent);
        if config._offset then
            anim:pos(config._offset)
        else
            anim:center()
        end
        anim:play(function()
            if config._callback then
                config._callback()
            end
            if not config._stay then
                self:delOneAnim(anim)
            end
        end, config._action, config._replay, config._delay)

        if before ~= nil and type(before) == "function" then
            before(anim, config._path)
        end

        return anim
    end
end

function UIAnimManager:addOneAnim(anim)
    table.insert(self._animList, anim)
    -- Logger.debug(" ========== addOneAnim ==========> ".. #self._animList)
end

function UIAnimManager:delOneAnim(anim)
    local idx = table.indexof(self._animList, anim)
    if idx ~= false then
        table.remove(self._animList, idx)
    end
    anim:hide()
    -- Logger.debug(" ========== delOneAnim ==========> ".. #self._animList)
end

function UIAnimManager:forceClear()
    for idx, val in ipairs( self._animList ) do
        val:hide()
    end

    self._animList = {}
end

return UI_ANIM