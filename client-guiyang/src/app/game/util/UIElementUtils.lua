local UIElementUtils = class("UIElementUtils")

function UIElementUtils:ctor()
end

function UIElementUtils:createMaskLayer(ui, clickedCallback, ...)
    local Mask_Name = "dlg_mask";
	local maskUI = ui:getChildByName(Mask_Name);
	local name = ui:getName()
	if nil ~= maskUI then
        Logger.error("element 自动创建Mask出错，UI不能有名字为dlg_mask的控件")
        return
    end

    local mask = ccui.ImageView:create();
    mask:loadTexture("gaming/blackMask.png");
    mask:setTouchEnabled(true)
    mask:setScale9Enabled(true);
    mask:setName(Mask_Name);
    mask:setOpacity(178);
    -- 遮罩适配
    mask:setAnchorPoint(cc.p(0, 0))
    local offset = cc.p(CC_DESIGN_RESOLUTION.screen.offsetPoint().x, CC_DESIGN_RESOLUTION.screen.offsetPoint().y)
    offset.x = offset.x - CC_DESIGN_RESOLUTION.screen._safeAreaOffset_x
    mask:setPosition(offset)
    local contentSize = mask:getContentSize()
    if contentSize.width / contentSize.height > display.width / display.height then
        mask:setScale(display.height / contentSize.height)
    else
        mask:setScale(display.width / contentSize.width)
    end
    -- 设置遮罩的点击事件
    ui:addChild(mask,-1);
    maskUI = mask;
    
    if type(clickedCallback) == "function" then
        mask:setTouchEnabled(true)
        local args = ...
        bindEventCallBack(mask, function () clickedCallback(args) end , ccui.TouchEventType.ended);
    end
end

return UIElementUtils