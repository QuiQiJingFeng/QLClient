---@class UIBase
local UIBase = class("UIBase")

function UIBase:ctor()
    self._uiName        = nil;
end

-- 当UI销毁（为什么不是  onDestroy) ?
function UIBase:destroy()
    self:onDestroy()
end

function UIBase:onDestroy()
end

function UIBase:getName()
    return self._uiName;
end

function UIBase:setName(name)
    self._uiName = name;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIBase:isFullScreen()
    return false;
end

function UIBase:init()
end

function UIBase:hideSelf()
    UIManager:getInstance():hideUI(self);
end

function UIBase:destroySelf()
	UIManager:getInstance():destroy(self.class.__cname)
	self = nil
end

function UIBase:onShow(...)
end

function UIBase:onHide()
end


-- 所在大层的初始ZOrder值
function UIBase:getUIZOrder()
    return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIBase:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal;
end

function UIBase:needBlackMask()
    return false;
end

function UIBase:closeWhenClickMask()
    return false
end

-- 标记为Persistent的UI不会destroy
function UIBase:isPersistent()
    return false;
end

-- 播放自生csd动画
function UIBase:playAnimation(csbPath, animName, isReplay)
    local _action = cc.CSLoader:createTimeline(csbPath)
    self:runAction(_action)
    if animName then
        _action:play(animName, isReplay or false)
    else
        _action:gotoFrameAndPlay(0, isReplay or false)
    end
    return _action
end

function UIBase.buildUIClass(className, csbPath, ...)
    return class(className, UIBase, function() return kod.LoadCSBNode(csbPath) end, ...)
end

function UIBase:playAnimation_Scale()
    -- local node = ccui.Helper:seekNodeByName(self, "panelContainer")
    -- -- node:setScale(0.5)
    -- node:runAction(cc.Sequence:create(
    --         cc.ScaleTo:create(0.06, 1.05),
    --         cc.ScaleTo:create(0.08, 1)
    -- ))
end

function UIBase:getUIRecordLevel()
    return config.UIRecordLevel.OtherLayer
end

return UIBase;