local csbPath = "ui/csb/UIShop.csb"
local super = require("app.game.ui.UIBase")

local UIShop = class("UIShop", super, function () return kod.LoadCSBNode(csbPath) end)
local ShopCostConfig = require("app.config.ShopCostConfig")

function UIShop:ctor()
    self._btnClose = nil -- 关闭按钮
    self._btnBoxes = {} -- 购买box
    self._currentType = nil -- 购买类型
    self._agentList = nil
end

function UIShop:dispose()
    -- do nothing
end

--  初始化
function  UIShop:init()
    self._btnClose = seekNodeByName(self, "Button_x_Shop", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    for i=1, 3 do
        local box = seekNodeByName(self, "Panel_" .. i .. "_shop", "ccui.Button")
        box:setTag(i)
        self._btnBoxes[#self._btnBoxes + 1] = box
        bindEventCallBack(box, handler(self, self._onSelectBuytype), ccui.TouchEventType.ended)
    end
    self._agentList = seekNodeByName(self, "ListView_Agent", "ccui.ListView")
end

function UIShop:onShow(...)
    local time = kod.util.Time.now()
    local date = os.date("*t", time)
    local dateKey = date.month .. "," .. date.day;
    for i=1, 3 do
        self._btnBoxes[i]:setEnabled(true)
    end

    -- 非ios and android 给一个默认值
    local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
    local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
    if Macro.assertTrue(SHOP_TYPE_COST == nil) then
        return
    end
    -- 统计可用购买
    local activeType = {}
    for i=1, #SHOP_TYPE_COST.items do
        table.insert(activeType, i)
    end

    local activeCount = #activeType
    -- 非审核验证限购
     if GameMain.getInstance():isReviewVersion() == false then
        -- 查找当天可用的支付
        local globalSetting = game.service.GlobalSetting.getInstance()
        if globalSetting.hasShoppedType.dateKey == dateKey then
            for i, type in ipairs(globalSetting.hasShoppedType.data) do
                if self._btnBoxes[type] ~= nil then
                    self._btnBoxes[type].setEnabled(false)
                end

                activeType[type] = nil
            end
        else
            globalSetting.hasShoppedType = { dateKey = dateKey, data = {} }
            globalSetting:saveSetting();
        end
	end

    local j = 1
    for i=1, activeCount do
        if activeType[i] ~= nil then
            activeType[j] = activeType[i]
            j = j + 1
        end
    end

    for k=j, activeCount do
        activeCount[k] = nil
    end

    if not game.service.IAPService.getInstance():isInitialized() then
        game.service.IAPService.getInstance():initialize()
    end

    -- 更新代理信息，跟提示代理的处理相同
    local params = {...}
    local data = params[1]
    local agentInfo = {}
    if data.content ~= nil and data.content ~= "" then
        table.insert(agentInfo, {"text", data.content})
    end
    if data.weiXins ~= nil and #data.weiXins > 0 then
        for i = 1, #data.weiXins do
            table.insert(agentInfo, {"account", data.weiXins[i]})
        end
    end
    self:_showAgentInfo(agentInfo)
end

-- 显示当前的代理相关信息
-- 计算当前显示的总长度，然后再居中对齐
function UIShop:_showAgentInfo(agentInfo)
    -- 提审不显示
    if GameMain.getInstance():isReviewVersion() then
        self._agentList:setVisible(false)
        return
    end
    self._agentList:setVisible(true)
    -- 代理提示的内容
    local agentTitle_bg = seekNodeByName(self._agentList, "Panel_1_Agent", "ccui.Layout")
    local agentTitle_text = seekNodeByName(agentTitle_bg, "Text_agent_title", "ccui.Text")

    -- ListView 显示的状态如下，从第二个代理信息开始，需要clone控件
    -- [提示的前缀] [第一个代理信息+复制按钮] [第二个代理信息+复制按钮] ...
    -- 开始填充代理数据
    local agentNumber = 0
    local listItems = self._agentList:getItems()
    local listWidth = 0
    local agentBaseWidget = seekNodeByName(self._agentList, "Panel_2_Agent", "ccui.Layout")
    for i = 1, #agentInfo do
        if agentInfo[i][1] == "account" then
            agentNumber = agentNumber + 1
            -- 代理帐号
            local agentWidget = listItems[agentNumber + 1]
            if agentWidget == nil then
                agentWidget = agentBaseWidget:clone()
                self._agentList:addChild(agentWidget)
            end
            -- 重新计算显示的大小
            -- 设置代理名字，并重置大小
            local nameWidget = seekNodeByName(agentWidget, "Text_agent_name", "ccui.Text")
            nameWidget:setString(agentInfo[i][2])
            local width = nameWidget:getVirtualRendererSize().width
            -- 重新调整复制按钮的位置
            local nameCopy = seekNodeByName(agentWidget, "Button_copy_shop", "ccui.Button")
            local x,y = nameCopy:getPosition()
            nameCopy:setPosition(cc.p(width + 15, y))
            width = width + nameCopy:getBoundingBox().width
            -- 重新调整底图的大小
            agentWidget:setContentSize(cc.size(width + 15, agentWidget:getContentSize().height))
            -- 绑定复制事件
            bindEventCallBack(nameCopy, function()
                if game.plugin.Runtime.setClipboard(agentInfo[i][2]) == true then
                    game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
                end
            end, ccui.TouchEventType.ended)
            listWidth = listWidth + self._agentList:getItemsMargin() + width+10
        else
            -- 代理提示前缀，设置完成并调整显示的大小
            agentTitle_text:setString(agentInfo[i][2])
            local vSize = agentTitle_text:getVirtualRendererSize()
            agentTitle_text:setContentSize(vSize)
            agentTitle_bg:setContentSize(cc.size(vSize.width + 10, agentTitle_bg:getContentSize().height))
            listWidth = listWidth + vSize.width + 10
        end
    end

    -- 如果一个都没有
    listItems = self._agentList:getItems()
    while #listItems > #agentInfo do
        self._agentList:removeLastItem()
        listItems = self._agentList:getItems()
    end

    -- 最后的收尾工作
	self._agentList:setScrollBarEnabled(false)
    -- 将listview显示的内容居中对齐
    self._agentList:requestDoLayout()
    self._agentList:doLayout()
    local parentSize = self._agentList:getParent():getContentSize()
    local listViewWidth = self._agentList:getContentSize().width
    listWidth = listWidth <= listViewWidth and listWidth or listViewWidth
    local x,y = self._agentList:getPosition()
    x = (parentSize.width - listWidth)/2
    x = x >= 0 and x or 0
    self._agentList:setPosition(cc.p(x,y))    
end

function UIShop:needBlackMask()
	return true;
end

function UIShop:closeWhenClickMask()
	return false
end

function UIShop:_onClose()
    UIManager:getInstance():destroy("UIShop")
end

function UIShop:_onBuy()
    -- 4.1.6版本以下不支持新版内购
    if not game.service.IAPService.getInstance():isSupported() and device.platform ~= "android"then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请更新为最新版本")
        return
    end

    local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
    local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
    if Macro.assertTrue(SHOP_TYPE_COST == nil) then
        return
    end 
    local shopData = SHOP_TYPE_COST.items[self._currentType]
    game.service.PaymentService:getInstance():reqProductId(SHOP_TYPE_COST.payType, SHOP_TYPE_COST.osType,shopData.cost, shopData.productId)
    self:_onClose()
end

-- 选择购买类型
function UIShop:_onSelectBuytype(sender)
    local index = sender and sender:getTag() or -1
    self._currentType = index
    if index == -1 then
    else
        local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
        local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
        if Macro.assertTrue(SHOP_TYPE_COST == nil) then
            return
        end

        self:_onBuy()
    end
end

return UIShop