local seekButton = require("app.game.util.UtilsFunctions").seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Activity/CollectCode/UICollectCodeGuide.csb"
local UICollectCodeGuide = super.buildUIClass("UICollectCodeGuide", csbPath)

function UICollectCodeGuide:ctor()
    self._clipping = cc.ClippingNode:create()
    self:addChild(self._clipping)
    self._clipping:setLocalZOrder(-1)

    self._backgroung = cc.Node:create()
    self._foregroung = cc.Node:create()
    self._clipping:addChild(self._backgroung)
    self._clipping:setStencil(self._foregroung)

    self._bgImageView = ccui.ImageView:create("img/img_black.png")
    self._bgImageView:setScale9Enabled(true)
    self._bgImageView:setContentSize(CC_DESIGN_RESOLUTION.screen.size())
    self._bgImageView:setPosition(cc.p(568, 320))
    self._bgImageView:setTouchEnabled(true)
    self._bgImageView:setOpacity(255 * 0.85)
    self._backgroung:addChild(self._bgImageView)

    self._fgSprite = ccui.ImageView:create("img/img_black.png")
    self._fgSprite:setScale9Enabled(true)
    self._fgSprite:setContentSize(400, 400)
    self._foregroung:addChild(self._fgSprite)

    self._clipping:setAlphaThreshold( 0.05 )
    self._clipping:setInverted(true)

    self._currentShowPage = 0
    self._btn = seekButton(self, "Button", handler(self, self._onBtnClick))
    self._layout = seekNodeByName(self, "Layout")
    self._text = seekNodeByName(self, "Text_Guide")
end

function UICollectCodeGuide:onShow(targets, texts, onOkCallback)
    self._targets = targets
    self._texts = texts
    self._onOkCallback = onOkCallback

    self:showPage(1)
end

function UICollectCodeGuide:mask(target)
    local srcPos = target:getParent():convertToWorldSpace(cc.p(target:getPosition()))
    local disPos = self:convertToNodeSpace(srcPos)
    local size = target:getContentSize()
    self._fgSprite:setPosition(disPos)
    self._fgSprite:setContentSize(cc.size(size.width + 30, size.height + 30))
end

function UICollectCodeGuide:showPage(page)
    self._currentShowPage = page
    self._text:setString(self._texts[page] or "")
    if page == 1 then
        self._layout:setPositionPercent(cc.p(0.25, 0.5))
    else
        self._layout:setPositionPercent(cc.p(0.75, 0.5))
    end
    self:mask(self._targets[self._currentShowPage])
end

function UICollectCodeGuide:_onBtnClick()
    if self._currentShowPage ~= #self._texts then
        if self._onOkCallback then
            self._onOkCallback(self._currentShowPage)
        end
        self:showPage(self._currentShowPage + 1)
    else
        self:hideSelf()
    end
end

return UICollectCodeGuide