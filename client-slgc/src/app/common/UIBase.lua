---@class UIBase
local UIBase = class("UIBase")

function UIBase:ctor()
    self._uiName  = nil
end

function UIBase:onInit()
end

function UIBase:onDestroy()
end

function UIBase:onShow(...)
end

function UIBase:onHide()
    game.EventCenter:off(self)
end

function UIBase:getName()
    return self._uiName
end

function UIBase:setName(name)
    self._uiName = name
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIBase:isFullScreen()
    return false
end

function UIBase:destroy()

end

-- @override 获取显示层层级,需要修改默认层级的，覆盖这个函数
function UIBase:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.NORMAL
end

-- @override 是否需要遮罩
function UIBase:needBlackMask()
    return false
end

-- @override 是否点击遮罩时关闭页面
function UIBase:closeWhenClickMask()
    return false
end

-- @override 标记为Persistent的UI不会在clear的时候销毁
function UIBase:isPersistent()
    return false
end

-- 播放自身csd动画
function UIBase:playAnimation(csbPath,animName,finishFunc,delay,replay)
    game.UIAnimationManager:getInstance():playAnimationWithParent(nil,self,csbPath,animName,nil,nil,finishFunc,delay,replay)
end

-- onShow时候的动画,如果不需要的话,重写这个方法
function UIBase:playShowAction()
    local node = ccui.Helper:seekNodeByName(self, "panelContainer")
    assert(node,"node must be none nil")
    node:setScale(0.5)
    node:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.06, 1.05),
            cc.ScaleTo:create(0.08, 1)
    ))

    local mask = ccui.Helper:seekNodeByName(node, "__MASK__")
    if mask then
        mask:setOpacity(0)
        mask:runAction(cc.FadeTo:create(0.15,178))
    end
end

return UIBase