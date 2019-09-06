-- 比赛场第一次进入的时候的引导界面
local csbPath = "ui/csb/Campaign/campaignUtils/UICampaignGuide.csb"
local super = require("app.game.ui.UIBase")
local UI_ANIM = require("app.manager.UIAnimManager")
local CampaignAnimPlayer = require("app.game.campaign.utils.CampaignAnimPlayer");

local UICampaignGuide = class("UICampaignGuide", super, function () return kod.LoadCSBNode(csbPath) end)

local GuideConfig = {
    [1] = "红包赛",
    [2] = "房卡赛",
    [3] = "免费赛"
}


function UICampaignGuide:ctor()
    self._popQueue = {}
    self._block = nil

    self._origin = -1    --初始tag
end

function UICampaignGuide:init()
    self._clipping = cc.ClippingNode:create()
    self:addChild(self._clipping)
    self._clipping:setLocalZOrder(1)

    self._background = cc.Node:create()
    self._foreground = cc.Node:create()
    self._clipping:addChild(self._background)
    self._clipping:setStencil(self._foreground)

    self._bgImageView = ccui.ImageView:create("img/img_black2.png")
	self._bgImageView:setScale9Enabled(true)
	self._bgImageView:setContentSize(CC_DESIGN_RESOLUTION.screen.size())
    self._bgImageView:setPosition(cc.p(568, 320))
    self._background:addChild(self._bgImageView)

    self._fgSprite = ccui.ImageView:create("img/zhezhao.png")
	self._fgSprite:setScale9Enabled(true)
    self._fgSprite:setAnchorPoint(cc.p(0,0))
    -- self._fgSprite:setScale(0.6,0.37)

    -- self._fgSprite2 = ccui.ImageView:create("img/zhezhao.png")
	-- self._fgSprite2:setScale9Enabled(true)
    -- self._fgSprite2:setScale(2.8,3.1)
    -- self._fgSprite2:setPosition(cc.p(660, 280))

    self._foreground:addChild(self._fgSprite)
    -- self._foreground:addChild(self._fgSprite2)

    self._clipping:setInverted(true)

    self._block = seekNodeByName(self, "block", "ccui.Layout")

    self._chickenDlg = seekNodeByName(self, "Image_3", "ccui.ImageView")
    self._chickenText = seekNodeByName(self, "BitmapFontLabel_2", "ccui.TextBMFont")
    self._btnNext = seekNodeByName(self, "Button_Next", "ccui.Button")

    self._chickenDlg:setLocalZOrder(2)
    self._btnNext:setLocalZOrder(2)
    self._bgImageView:setTouchEnabled(true)

    -- self._animNode = CampaignAnimPlayer:getInstance():play(self, config.CampaignConfig.CampaignAnim["FingerTouch"], 1, true)
    -- self._animNode:setLocalZOrder(2)

    -- bindEventCallBack(self._block, handler(self, self._showNextPos), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNext, handler(self, self._showNextPos), ccui.TouchEventType.ended)
end

function UICampaignGuide:_showNextPos()
    if #self._popQueue <= 0 then
        if self._origin ~= -1 then
            game.service.CampaignService.getInstance():dispatchEvent({name ="ON_SELECT_CAMPAIGN_TAB",key = self._origin})
        end
        game.service.CampaignService.getInstance():dispatchEvent({name ="ON_POPUP_NEWPLAYER_GUIDE"})
        UIManager:getInstance():destroy("UICampaignGuide")
        return
    end
    local info = table.remove(self._popQueue,1)
    if self._origin == -1 then
        self._origin = info.key
    end
    local posX = info.pos.x
    local posY = info.pos.y
    local width = info.size.width
    local height = info.size.height
    local position = cc.p(posX ,posY)
    
    self._fgSprite:setPosition(position)
    
    -- 添加动画
    -- self._animNode:setPosition(cc.p(position.x + width/2,position.y + height/2))
    self._chickenDlg:setPosition(cc.p(position.x + width,position.y + height/2))
    local typeString = GuideConfig[info.key] or ""
    self._chickenText:setString( typeString .. "在这里!")

    game.service.CampaignService.getInstance():dispatchEvent({name ="ON_SELECT_CAMPAIGN_TAB",key = info.key})
    print("POP ONE!!!!! " .. #self._popQueue)
end

function UICampaignGuide:onShow(...)
    local args = {...}
    local list = args[1].target
    self._popQueue = {}

    table.foreach(list:getSpawnItems(),function(k,v)      
        local x,y = v:getPosition() 
        local size = v:getContentSize()
        self._fgSprite:setContentSize(size)
        -- print("button Anchor X " .. v:getAnchorPoint().x .."Y " .. v:getAnchorPoint().y)
        -- print("sprite Anchor X " .. self._fgSprite:getAnchorPoint().x .."Y " .. self._fgSprite:getAnchorPoint().y)
        -- local pos = cc.p(x ,y)
        local pos = v:getParent():convertToWorldSpace(cc.p(x ,y))
        pos = self._background:convertToNodeSpace(pos)
        table.insert(self._popQueue, {pos = pos, key = v:getKey(), size = size, name = v:getName()})

        print("POS X = " .. pos.x .. "POS Y = " ..pos.y)
    end
    )

    -- self._animNode = CampaignAnimPlayer:getInstance():play(self, config.CampaignConfig.CampaignAnim["FingerTouch"], 1, true)
    -- local x,y = self._btnNext:getPosition()
    -- local width = self._btnNext:getContentSize().width
    -- local height = self._btnNext:getContentSize().height
    -- self._animNode:setPosition(cc.p(x + width *0.4, y))
    -- self._animNode:setLocalZOrder(3)
    -- self._animNode:setScale(0.8)

    self:_showNextPos()
end

function UICampaignGuide:needBlackMask()
	return false;
end

function UICampaignGuide:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignGuide:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignGuide;
