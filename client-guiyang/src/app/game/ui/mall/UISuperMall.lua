--[[0
    create date:
        2018/07/23
    简介：
        1、此UI只做 ListView 和 货币控件 的显示隐藏管理
        2、货币数据从此入口进入，然后放到 各个 对应的 ListViewHandler 中处理
        参见 AbstractListViewHandler 与 ListViewHandlerProvider
]]
local MallUserDataSender = require("app.game.ui.mall.MallUserDataSender")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ListViewHandlerProvider = require("app.game.ui.mall.listViewHandler.ListViewHandlerProvider")
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Mall/UISuperMall.csb'
local UISuperMall = class("UISuperMall", super, function() return kod.LoadCSBNode(csbPath) end)

function UISuperMall:ctor()
    -- 这个 map 用与 UI 命名相关连的
    self._categoryKeyMap = {
        Card = CurrencyHelper.CURRENCY_TYPE.CARD,
        Bean = CurrencyHelper.CURRENCY_TYPE.BEAN,
        Gold = CurrencyHelper.CURRENCY_TYPE.GOLD,
        Props = "PROPS",

        Match_Ticket = CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET,
        Gift_Ticket = CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET,

        -- card = CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET_HELP,
    }
    self._showCurrencyTypeList = {
        self._categoryKeyMap.Card,
        self._categoryKeyMap.Bean,
        self._categoryKeyMap.Gold,
        -- 铜仁关闭赛券,礼券道具
        --self._categoryKeyMap.Match_Ticket,
        --self._categoryKeyMap.Gift_Ticket,
        --self._categoryKeyMap.Props
    }
    self._categoryCNMap = {
        [self._categoryKeyMap.Card] = "房卡",
        [self._categoryKeyMap.Bean] = "金豆",
        [self._categoryKeyMap.Gold] = "金币",
        [self._categoryKeyMap.Match_Ticket] = "赛券",
        [self._categoryKeyMap.Gift_Ticket] = "礼券",
        [self._categoryKeyMap.Props] = "道具"
    }
end

function UISuperMall:onShow(currencyType, listViewData)
    if self._listViewHandlerMap[currencyType] ~= nil then
        local listViewHandler = self._listViewHandlerMap[currencyType]
        if listViewHandler then
            listViewHandler:setListViewData(listViewData)
        end
        local index = table.indexof(self._showCurrencyTypeList, currencyType)
        self._cboxGroup:setSelectedIndexWithoutCallback(index)
        self:_changeCategoryWidgetVisible(currencyType)
    end

    MallUserDataSender.send(MallUserDataSender.ACTION_ENUM.ENTERED)
end


function UISuperMall:init()
    local imgTop = seekNodeByName(self, "ImageView_Top", "ccui.ImageView")
    self._categoryLayoutMap = self:_initCurrencyCategoryLayoutMap(imgTop)
    self._categoryLayoutMap = self:_initCategoryItems(self._categoryLayoutMap)
    self._bindKeys = self:_bindCurrency()

    local cboxContainerTemplate = seekNodeByName(seekNodeByName(self, "ListView_Category", "ccui.ListView"), "Template", "ccui.Layout")
    self._cboxGroup = CheckBoxGroup.new(self:_initCheckBoxes(self._showCurrencyTypeList, cboxContainerTemplate), handler(self, self._onCBoxGroupClick))

    self._listViewHandlerMap = self:_initListViewHandlers(self._showCurrencyTypeList)

    self._bottomLayout = seekNodeByName(self, "ImageView_Bottom", "ccui.ImageView")
    local agentListView = seekNodeByName(self._bottomLayout, "ListView_Agent", "ccui.ListView")
    self._agentListViewHandler = ListViewHandlerProvider.getHandlerClass("KEY_MALL_AGENT_LIST_VIEW").new(agentListView)

    -- 这里要保证AgentListView在最上面
    self._bottomLayout:setLocalZOrder(65535)

    self._btnBack = seekNodeByName(self, "Button_Back", "ccui.Button")
    self:_registerListener()
end

function UISuperMall:_initCheckBoxes(typeList, cboxContainerTemplate)
    local cboxes = {}
    local parent = cboxContainerTemplate:getParent()
    for index, currencyType in ipairs(typeList) do
        local clonedObject = cboxContainerTemplate:clone()
        local text = seekNodeByName(clonedObject, "BMFont", "ccui.TextBMFont")
        local cbox = seekNodeByName(clonedObject, "CheckBox", "ccui.CheckBox")
        text:setString(self._categoryCNMap[currencyType])
        parent:addChild(clonedObject)
        table.insert(cboxes, cbox)
    end
    cboxContainerTemplate:removeFromParent()
    cboxContainerTemplate = nil
    return cboxes
end

function UISuperMall:_initListViewHandlers(typeList)
    local handlerMap = {}
    -- 以后可能每一个专门用一个listView，现在是都放在一起了
    local templateListView = seekNodeByName(self, "ListView_Items", "ccui.ListView")
    for index, currencyType in ipairs(typeList) do
        local clonedListView = templateListView:clone()
        templateListView:getParent():addChild(clonedListView)
        clonedListView:setScrollBarEnabled(false)
        clonedListView:setClippingEnabled(true)
        local handlerClass = ListViewHandlerProvider.getHandlerClass(currencyType)
        if handlerClass then
            handlerMap[currencyType] = handlerClass.new(clonedListView)
        end
    end
    templateListView:setVisible(false)
    return handlerMap
end

function UISuperMall:_initCurrencyCategoryLayoutMap(container)
    local layoutMap = {}
    for categoryKey, _ in pairs(self._categoryKeyMap) do
        local layout = seekNodeByName(container, "Layout_Category_" .. categoryKey, "ccui.Layout")
        if Macro.assertFalse(layout, 'cannot find categoryKey ' .. tostring(categoryKey) .. ', layout') then
            layoutMap[categoryKey] = layout
        end
    end
    return layoutMap
end

function UISuperMall:_initCategoryItems(categoryLayoutMap)
    for key, layout in pairs(categoryLayoutMap) do
        layout.categoryItems = {}
        for categoryKey, _ in pairs(self._categoryKeyMap) do
            local categoryNode = seekNodeByName(layout, 'Category_' .. categoryKey, "ccui.ImageView")
            if categoryNode then
                layout.categoryItems[categoryKey] = categoryNode
            end
        end
        -- 找一下'兑换记录'按钮，并且记录位置
        if self._categoryKeyMap[key] == self._categoryKeyMap.Gift_Ticket then
            layout.btnExchangeHistory = seekNodeByName(layout, "Button_Exchange_History", "ccui.Button")
            bindEventCallBack(layout.btnExchangeHistory, handler(self, self._onBtnExchangeHistoryClick), ccui.TouchEventType.ended)
            self._categoryLayoutBasePosition = cc.p(layout:getPosition())
        end
    end
    return categoryLayoutMap
end

function UISuperMall:_registerListener()
    game.service.MallService:getInstance():addEventListener("EVENT_MALL_BILL_RES", handler(self, self._onEventMallBillRES), self)
    bindEventCallBack(self._btnBack, handler(self, self._onBtnBackClick), ccui.TouchEventType.ended)
end

function UISuperMall:_bindCurrency()
    local bindKeys = {}
    for _, layout in pairs(self._categoryLayoutMap) do
        for categoryKey, item in pairs(layout.categoryItems) do
            local currencyType = self._categoryKeyMap[categoryKey]
            local bindKey = CurrencyHelper.getInstance():getBinder():bind(currencyType, item)
            table.insert(bindKeys, bindKey)

            -- 特殊处理下商城中的礼券加号
            if CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET == currencyType then
                bindEventCallBack(seekNodeByName(item, "Button_Add", "ccui.Button"), handler(self, self._onAddGiftTicketClick), ccui.TouchEventType.ended)
            end
        end
    end
    return bindKeys
end

function UISuperMall:_unbindCurrency(bindKeys)
    for _, key in ipairs(bindKeys) do
        CurrencyHelper.getInstance():getBinder():unbind(key)
    end
end

function UISuperMall:_onAddGiftTicketClick(sender)
    if config.UIGIFT_TICKET_STRING_100 ~= "" then
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UIGIFT_TICKET_STRING_100, { config.STRING.UIGIFT_TICKET_STRING_101, config.STRING.UIGIFT_TICKET_STRING_102 }, function()
            GameFSM.getInstance():enterState("GameState_Gold")
        end,
        function()
            game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
            UIManager:getInstance():destroy("UISuperMall")
        end)
    end
    return false
end

function UISuperMall:_onBtnBackClick(sender)
    UIManager:getInstance():destroy(self.class.__cname)
end

function UISuperMall:_onBtnExchangeHistoryClick(sender)
    game.service.MallService:getInstance():queryBill()
end

function UISuperMall:_onCBoxGroupClick(group, index)
    local currencyType = self._showCurrencyTypeList[index]
    self:_changeCategoryWidgetVisible(currencyType)
    CurrencyHelper.getInstance():queryCurrency(currencyType)
end

function UISuperMall:_changeCategoryWidgetVisible(currencyType)
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    for categoryKey, layout in pairs(self._categoryLayoutMap) do
        local type = self._categoryKeyMap[categoryKey]
        layout:setVisible(type == currencyType)
        layout:setPosition(self._categoryLayoutBasePosition)

        -- 铜仁隐藏每个子项中金币的显示
        if areaId == 10006 then 
            if type == self._categoryKeyMap.Card or type == self._categoryKeyMap.Bean then 
                local item = layout.categoryItems["Match_Ticket"]
                if item ~= nil then 
                    local itemSize = item:getContentSize()
                    layout:setPositionX(self._categoryLayoutBasePosition.x + itemSize.width)
                    item:setVisible(false)
                end 
            end 
        end 
    end

    -- 改变listview的显示与隐藏
    for type, listViewHandler in pairs(self._listViewHandlerMap) do
        listViewHandler:setVisible(type == currencyType)
    end
    local isShowAgentList = currencyType == CurrencyHelper.CURRENCY_TYPE.CARD
    self._bottomLayout:setVisible(isShowAgentList)
end

function UISuperMall:_onEventMallBillRES(event)
    UIManager:getInstance():show("UIMallBill", event.data)
end

-- 当UI销毁时
function UISuperMall:destroy()
    game.service.MallService:getInstance():removeEventListenersByTag(self)
    CurrencyHelper.getInstance():resetCurrentQueryType()
    self:_unbindCurrency(self._bindKeys or {})
    for type, listViewHandler in pairs(self._listViewHandlerMap) do
        listViewHandler:dispose()
    end
    self._agentListViewHandler:dispose()
end

function UISuperMall:needBlackMask()
    return true
end

function UISuperMall:getGradeLayerId() 
    return config.UIConstants.UI_LAYER_ID.Top 
end

function UISuperMall:getUIRecordLevel()
	return config.UIRecordLevel.MainLayer
end
return UISuperMall