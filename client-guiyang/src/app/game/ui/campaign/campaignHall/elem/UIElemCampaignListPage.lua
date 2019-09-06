--[[
比赛列表子界面
--]]
local csbPath = "ui/csb/Campaign/campaignHall/elem/UIBattlelist.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UICampaignInfoItem = require("app.game.ui.campaign.campaignHall.elem.UICampaignInfoItem")
local UICampaignTabItem = require("app.game.ui.campaign.campaignHall.elem.UICampaignTabItem")

local super = require("app.game.ui.UIBase")

----------------------------------------------------------------------
--比赛场比赛list
local UIElemCampaignListPage = class("UIElemCampaignListPage", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemCampaignListPage:ctor(parent)
    self._parent = parent;
    self._reusedCampaignList = nil;
    self._currentTabs = 1
                         
    self._reusedCampaignList = UIItemReusedListView.extend(seekNodeByName(self, "ListView", "ccui.ListView"), UICampaignInfoItem)
    self._reusedCampaignTab = UIItemReusedListView.extend(seekNodeByName(self, "ListView_6", "ccui.ListView"), UICampaignTabItem)
    self._reusedCampaignList:setScrollBarEnabled(false)
    self._reusedCampaignTab:setScrollBarEnabled(false)
    self._noneText = seekNodeByName(self, "noneTxt", "ccui.Text")
end

function UIElemCampaignListPage:show(tabId)
    self._tabId = tabId
    local campaignService = game.service.CampaignService.getInstance();
    self._currentTabs = campaignService:getCampaignFunctionService():getCurrentTab()
    -- 同步时间
    game.service.TimeService:getInstance():updateTimeFromServer()
    self:setVisible(true)
    self:showGuide()

    campaignService:addEventListener("EVENT_CAMPAIGN_DATA_RECEIVED",    handler(self, self._onCampaignDataReceived), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_DATA_CHANGED",     handler(self, self._onCampaignMemberChanged), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_START_WATCHLIST",     handler(self, self._onCampaignRefrash), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_SELECT_TAB",     handler(self, self.showSelectPage), self)
    
    -- 分享回调
    game.service.WeChatService.getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self._onShareCampaign), self);
end

function UIElemCampaignListPage:hide()
    -- body
    self:setVisible(false)
    -- 取消关注列表
    local campaignService = game.service.CampaignService.getInstance();
    
    campaignService:removeEventListenersByTag(self);
    game.service.WeChatService.getInstance():removeEventListenersByTag(self);
end

-- 获取到了比赛数据整体更新,刷新左侧，以及右侧当前选择的切页
function UIElemCampaignListPage:_onCampaignDataReceived( event )
    local tabs = event.data:getCampaignTabs()
    self._reusedCampaignTab:deleteAllItems()
    for idx,member in ipairs(tabs) do
        self._reusedCampaignTab:pushBackItem(member)
    end

    -- 使用默认的
    local tab = tabs[self._tabId > #tabs and 1 or self._tabId]

    if tab ~= nil then
        self._currentTabs = tab.key
    end

    game.service.CampaignService.getInstance():dispatchEvent({name ="ON_SELECT_CAMPAIGN_TAB",key = self._currentTabs})
    game.service.CampaignService.getInstance():dispatchEvent({name ="EVENT_CAMPAIGN_SELECT_TAB",key = self._currentTabs})
end

function UIElemCampaignListPage:showGuide()
    if game.service.CampaignService.getInstance():getLocalStorage():getNotPopCampaignGuide() == false then
        UIManager:getInstance():show("UICampaignGuideEntry", {target = self._reusedCampaignTab, swallow = true})
    end
end

-- 显示当前tab对应的页面
function UIElemCampaignListPage:showSelectPage( event)
    local campaignService = game.service.CampaignService.getInstance()
    local data = campaignService:getCampaignList():getCampaignsByTag(event.key)
    self._currentTabs = event.key
    campaignService:getCampaignFunctionService():setCurrentTab(self._currentTabs)

    -- 如果是已报名 则sort改为-1(要排前面)
    table.foreach(data, function (k,v)
        if v.signUp == true then
            v.sort = -1
        end
    end)

    -- 排序 在ab都为after时按照sort排序
    table.sort(data,function ( a,b )
        if a.status == config.CampaignConfig.CampaignStatus.AFTER and b.status == config.CampaignConfig.CampaignStatus.AFTER then
            return a.sort < b.sort
        end
        if a.status == config.CampaignConfig.CampaignStatus.AFTER then
            return false
        elseif b.status == config.CampaignConfig.CampaignStatus.AFTER then
            return true
        end

        return a.sort < b.sort
    end)

    -- 添加数据
    self._noneText:getParent():setVisible(#data == 0)

    local deleteNums = #data - #self._reusedCampaignList:getItemDatas()

    for i=#self._reusedCampaignList:getItemDatas(),#data+1,-1 do
        self._reusedCampaignList:deleteItem(i)
    end

    for idx,member in ipairs(data) do
        if #self._reusedCampaignList:getItemDatas()>= idx then
            self._reusedCampaignList:updateItem(idx,member)
        else
            self._reusedCampaignList:pushBackItem(member)
        end
    end

    self:reArrangeItems()
end

-- 改变zorder排序
function UIElemCampaignListPage:reArrangeItems()
    local spawnItems = self._reusedCampaignList:getItems()
	local positions = {}
	for itemId, spawned in ipairs(spawnItems) do
		positions[itemId] = spawned:getPositionY()
	end
    for itemId, spawned in pairs(spawnItems) do
        spawned:setLocalZOrder(positions[itemId])	
    end
end

-- 比赛列表变化通知
function UIElemCampaignListPage:_onCampaignMemberChanged( event )
    local data = event.data:getCampaignsByTag(self._currentTabs)
    -- 删除数据
    self._noneText:getParent():setVisible(#data == 0)

    table.sort(data,function ( a,b )
        if a.status == config.CampaignConfig.CampaignStatus.AFTER and b.status == config.CampaignConfig.CampaignStatus.AFTER then
            return a.sort < b.sort
        end
        if a.status == config.CampaignConfig.CampaignStatus.AFTER then
            return false
        elseif b.status == config.CampaignConfig.CampaignStatus.AFTER then
            return true
        end

        return a.sort < b.sort
    end)
    
    
    local deleteNums = #data - #self._reusedCampaignList:getItemDatas()

    for i=#self._reusedCampaignList:getItemDatas(),#data+1,-1 do
        self._reusedCampaignList:deleteItem(i)
    end
    -- 更新数据
    for idx,member in ipairs(data) do
        if #self._reusedCampaignList:getItemDatas()>= idx then
            self._reusedCampaignList:updateItem(idx,member)
        else
            self._reusedCampaignList:pushBackItem(member)
        end
    end

    self:reArrangeItems()
end

-- 请求刷新列表
function UIElemCampaignListPage:_onCampaignRefrash()
    local campaignService = game.service.CampaignService.getInstance();
    campaignService:sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
end

-- 分享回调
function UIElemCampaignListPage:_onShareCampaign(event)
    Macro.assetFalse(event.name == "EVENT_SEND_RESP")
    local campaignService = game.service.CampaignService.getInstance();
    if event.errCode ~= 0 then return end
    -- 显示免费次数
    campaignService:addCampaignShareFreeRecord(campaignService:getShareCampaignId())
    campaignService:setShareCampaignId(0)

    -- 更新数据
    for idx,member in ipairs(self._reusedCampaignList:getItemDatas()) do
        self._reusedCampaignList:updateItem(idx,member)
    end
end


function UIElemCampaignListPage:dispose()
    unscheduleOnce(self._scheduleRefrashCd)
end

return UIElemCampaignListPage;
