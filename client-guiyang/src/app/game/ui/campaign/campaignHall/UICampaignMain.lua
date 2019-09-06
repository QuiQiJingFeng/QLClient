--[[
比赛主界面
--]]
local UIElemCampaignListPage = require("app.game.ui.campaign.campaignHall.elem.UIElemCampaignListPage")
local UIElemCampaignHistoryPage = require("app.game.ui.campaign.campaignHall.elem.UIElemCampaignHistoryPage")

local csbPath = "ui/csb/Campaign/campaignHall/UIBattleScene.csb"
local super = require("app.game.ui.UIBase")

-- 货币工具
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local UICampaignMain = class("UICampaignMain", super, function() return kod.LoadCSBNode(csbPath) end)

function  UICampaignMain:ctor()
    super.ctor(self);
    self._btnBack = nil;                -- 返回
    self._btnRewards = nil;             -- 奖品
    self._roomCardText = nil;           -- 房卡数量
    self._nodeSubUIAnchor = nil         -- 子页面锚点
    self._title = nil                   -- 标题

    self._elemCampaignList = nil;          -- 比赛列表
    self._elemCampaignDetail = nil         -- 比赛详情
    self._elemCampaignHistory = nil

    self._shareImgPath = ""             -- 分享图片路径

    self._uiStack={}                    -- 界面上所显示的UI 用于控制返回按钮时关闭界面的顺序

    -- TODO：想把子界面都直接放进uistack中管理算了。。但是那样会造成反复创建。。也可以把它们改成UImananger一样的管理类，暂时先这样吧
end

function UICampaignMain:init()
    self._btnBack = seekNodeByName(self, "Button_2_BattleScene", "ccui.Button")
    self._btnRewards = seekNodeByName(self, "Button_hjjl_top_BattleScene", "ccui.Button")
    self._ticketBackpack = seekNodeByName(self, "Button_mp_top_BattleScene", "ccui.Button")
    self._roomCardText = seekNodeByName(self, "BitmapFontLabel_sz_top_BattleScene", "ccui.TextBMFont")
    self._compVoucherText = seekNodeByName(self, "BitmapFontLabel_sz_top_BattleScene_0", "ccui.TextBMFont")
    self._title = seekNodeByName(self, "BitmapFontLabel_30", "ccui.TextBMFont")
    self._campaignReceiveRedPoint = seekNodeByName(self, "Image_red", "ccui.ImageView")

    self._nodeSubUIAnchor = seekNodeByName(self, "Node_t_BattleScene", "cc.Node")
    self._addCard = seekNodeByName(self, "Image_AddCard", "ccui.ImageView")
    self._addTicket = seekNodeByName(self, "Image_AddTicket", "ccui.ImageView")
    self._addBean = seekNodeByName(self, "Panel_Main_Bean", "ccui.Layout")

    -- 绑定按钮事件
    bindEventCallBack(self._btnBack, handler(self, self._onClickBackBtn), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRewards, handler(self, self._onClickBtnRewareds), ccui.TouchEventType.ended)
    bindEventCallBack(self._addCard, handler(self, self._onClickAddCard), ccui.TouchEventType.ended)
    bindEventCallBack(self._addTicket, handler(self, self._onClickAddTicket), ccui.TouchEventType.ended)
    bindEventCallBack(self._ticketBackpack, handler(self, self._onClickTicketBackpack), ccui.TouchEventType.ended)
end

function UICampaignMain:onShow(tabId)
    self._tabId = tabId
    cc.bind(self, "event");
    self:_showCampaignListPage(true)
    self._campaignReceiveRedPoint:setVisible(false)

    local campaignService = game.service.CampaignService.getInstance();
    campaignService:addEventListener("EVENT_CAMPAIGN_HISTORY_RECEIVED",    handler(self, self._showCampaignHistory), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_RECEIVE_FLAG",     handler(self, self._onCampaignReceiveRefrash), self)

    self._bindKeys = {
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.CARD, self._addCard),
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET, self._addTicket),
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.BEAN, self._addBean),
    }

    local localPlayerService = game.service.LocalPlayerService.getInstance();
    game.service.LoginService.getInstance():addEventListener("USER_DATA_RETRIVED", handler(self, self._onUserDataRefreshed), self);

    -- 统计每日进入【比赛场】页面次数
    local isNewPlayer = localPlayerService:getIsNewPlayer()
    game.service.DataEyeService.getInstance():onEvent(string.format("Campaign_Main%s", isNewPlayer and "_New" or ""));
end

function UICampaignMain:onHide()
    -- 取消子界面事件监听
    for idx,item in ipairs(self._uiStack) do
        item[1]:hide()
    end
    cc.unbind(self, "event");

    self._uiStack={}   

    -- 取消事件监听
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService.getInstance():removeEventListenersByTag(self);

    for _, key in ipairs(self._bindKeys or {}) do
        CurrencyHelper.getInstance():getBinder():unbind(key)
    end
    self._bindKeys = {}
end

----------------------------------------------------------------------
-- 显示比赛列表
function UICampaignMain:_showCampaignListPage()
    -- 如果没有UIElemCampaignListPage, 加载
    if self._elemCampaignList == nil then 
        self._elemCampaignList = UIElemCampaignListPage.new(self)
        self._nodeSubUIAnchor:addChild(self._elemCampaignList)
    end

    self._nodeSubUIAnchor:setPositionY(324)

    self:_addPages({self._elemCampaignList})          
    
    self:_hideAllPages()
    self._elemCampaignList:show(self._tabId)
end

----------------------------------------------------------------------
-- 显示获奖记录
function UICampaignMain:_showCampaignHistory(event)
    local info = event.data
    -- 如果没有UIElemCampaignDetailPage, 加载
    if self._elemCampaignHistory == nil then 
        self._elemCampaignHistory = UIElemCampaignHistoryPage.new(self)
        self._nodeSubUIAnchor:addChild(self._elemCampaignHistory)
    end

    self._nodeSubUIAnchor:setPositionY(270)

    self:_addPages({self._elemCampaignHistory})     
    
    self:_hideAllPages()
    
    self._elemCampaignHistory:show(info)    
end

----------------------------------------------------------------------
-- 隐藏所有UI
function UICampaignMain:_hideAllPages()
    for idx,item in ipairs(self._uiStack) do
        item[1]:setVisible(false)
    end
end

----------------------------------------------------------------------
-- stack中添加UI
function UICampaignMain:_addPages(page)
    local hasUi = false
    for idx,item in ipairs(self._uiStack) do
        if item[1] == page[1] then
            hasUi = true
        end
    end

    if hasUi == false then
        table.insert(self._uiStack, page)  
    end
end

----------------------------------------------------------------------
-- 查看历史战绩
function UICampaignMain:_onClickBtnRewareds()
    game.service.CampaignService.getInstance():getCampaignFunctionService():onCCACampaignHistoryREQ(0)
    self._nodeSubUIAnchor:setPositionY(270)
     -- 统计点击比赛场比赛历史记录的次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_HistoryRecord);
end

function UICampaignMain:_onClickAddCard()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_AddCard_Hall);
end

function UICampaignMain:_onClickAddTicket()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_AddTicket_Hall);
end

function UICampaignMain:_onClickTicketBackpack()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Ticket_BackPack)
    UIManager:getInstance():show("UIMallCampaignTicket")
    game.service.MallService:getInstance():queryRoleTicket()
end

-- 点击返回按钮从uiStack中取顶层元素，调用hide
function UICampaignMain:_onClickBackBtn()
    if #self._uiStack > 1 then
        self._uiStack[#self._uiStack][1]:hide()
        self._uiStack[#self._uiStack-1][1]:setVisible(true)
        table.remove(self._uiStack,#self._uiStack)
        self._nodeSubUIAnchor:setPositionY(324)
    else
        GameFSM.getInstance():enterState("GameState_Lobby");
        game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.STOP_WATCH_CAMPAIGN_LIST)
    end
end

-- 刷新有奖励待领取推送
function UICampaignMain:_onCampaignReceiveRefrash(event)
    self._campaignReceiveRedPoint:setVisible(event.receiveFlag == true)
end

-- 当断线重连回来时
function UICampaignMain:_onUserDataRefreshed()
	game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
end

return UICampaignMain