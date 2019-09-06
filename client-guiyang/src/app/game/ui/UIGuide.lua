local csbPath = "ui/csb/UIGuide.csb" --ui文件
local super = require("app.game.ui.UIBase")
local UIGuide = class("UIGuide", super, function () return kod.LoadCSBNode(csbPath) end)

--构造函数
function UIGuide:ctor()
    --这里可以写成员的声明等
    self._clipping = nil
    self._backgroung = nil
    self._foregroung = nil
    self._bgImageView = nil
    self._fgSprite = nil

    self._block = nil
    self._tips1 = nil
    self._tips2 = nil
end

--析构函数
function UIGuide:destroy()
	--释放内存
end

--初始化函数
function UIGuide:init()
    self._clipping = cc.ClippingNode:create()
    self:addChild(self._clipping)
    self._clipping:setLocalZOrder(-1)

	self._backgroung = cc.Node:create()
    self._foregroung = cc.Node:create()
    self._clipping:addChild(self._backgroung)
    self._clipping:setStencil(self._foregroung)

	self._bgImageView = ccui.ImageView:create("img/img_black2.png")
	self._bgImageView:setScale9Enabled(true)
	self._bgImageView:setContentSize(CC_DESIGN_RESOLUTION.screen.size())
    self._bgImageView:setPosition(cc.p(568, 320))
    self._backgroung:addChild(self._bgImageView)

	self._fgSprite = ccui.ImageView:create("img/zhezhao.png")
	-- self._fgSprite:setScale9Enabled(true)
	-- self._fgSprite:setContentSize(400,400)
    self._fgSprite:setPosition(cc.p(568, 320))
    self._foregroung:addChild(self._fgSprite)

	self._clipping:setAlphaThreshold( 0.05 )
    self._clipping:setInverted(true)
    
    self._block = seekNodeByName(self, "block", "ccui.Layout")
    self._tips1 = seekNodeByName(self, "txtTips1", "ccui.Text")
    self._tips2 = seekNodeByName(self, "txtTips2", "ccui.Text")
end

function UIGuide:_connectTarget(target, swallow, callback)
    if not target then
        return
    end

    local srcPos = target:getParent():convertToWorldSpace(cc.p(target:getPosition()))
    local disPos = self:convertToNodeSpace(srcPos)
    self._fgSprite:setPosition(disPos)

    if swallow and callback then
        --[[ 
            以下代码测试通过，但是为保证安全，还是用后面的代码，如有扩充，可以考虑是否使用
        ]]
        -- local listener = cc.EventListenerTouchOneByOne:create()
        -- local dispatcher = self._block:getEventDispatcher()
        -- listener:setSwallowTouches(true)
        -- listener:registerScriptHandler(function(touch)
        --     local location = touch:getLocation()
        --     location = self:convertToNodeSpace(location)
        --     listener:setSwallowTouches(true)
        --     if cc.rectContainsPoint(self._fgSprite:getBoundingBox(), location) then
        --         self._block:setTouchEnabled(false)
        --         listener:setSwallowTouches(false)
        --     end
        --     return true
        -- end, cc.Handler.EVENT_TOUCH_BEGAN)
        -- listener:registerScriptHandler(function(touch)
        --     local location = touch:getLocation()
        --     location = self:convertToNodeSpace(location)
        --     if cc.rectContainsPoint(self._fgSprite:getBoundingBox(), location) then
        --         dispatcher:removeEventListenersForTarget(self._block)
        --         UIManager:getInstance():destroy("UIGuide")
        --     end
        -- end, cc.Handler.EVENT_TOUCH_ENDED)
        -- dispatcher:addEventListenerWithSceneGraphPriority(listener, self._block)
        self._block:setTouchEnabled(true)
        self._block:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                local location = sender:getTouchEndPosition()
                location = self:convertToNodeSpace(location)
                if cc.rectContainsPoint(self._fgSprite:getBoundingBox(), location) then
                    UIManager:getInstance():destroy("UIGuide")
                    callback()
                else
                    self._block:setTouchEnabled(true)
                end
            elseif eventType == ccui.TouchEventType.canceled then
            end
        end)
    end
end

--[[
    可用param
    target 挂载节点
    blocked 当前界面阻塞鼠标事件
    swallow 接收挂载目标的事件
    alpha 黑底的透明度
]]
--显示函数
function UIGuide:onShow(...)
    --界面显示逻辑
    local tmp = {...}
    local args = tmp[1]
    local tp = tmp[2]
    if type(args) == "table" then
        if args.blocked ~= nil and args.blocked == false then
            self._block:setVisible(false)
        end
        self:_connectTarget(args.target, args.swallow, args.callback)
        -- args.alpha = args.alpha or 128
        -- self._bgImageView:setOpacity(args.alpha)
    end
    if tp == "club" then
        self._tips1:setVisible(true)
        self._tips2:setVisible(false)
    else
        self._tips1:setVisible(false)
        self._tips2:setVisible(true)
    end
end

--隐藏函数
function UIGuide:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIGuide:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGuide:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIGuide:needBlackMask()
	return false;
end

--关闭时操作
function UIGuide:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIGuide:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIGuide:isFullScreen()
	return false;
end

return UIGuide