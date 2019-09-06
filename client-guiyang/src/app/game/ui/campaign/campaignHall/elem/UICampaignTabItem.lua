-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UICampaignTabItem = class("UICampaignTabItem")

function UICampaignTabItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UICampaignTabItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UICampaignTabItem:_initialize()
    self._checkbox = seekNodeByName(self, "CheckBoxBean", "ccui.CheckBox")
    self._text = seekNodeByName(self, "BitmapFontLabel_2_0", "ccui.TextBMFont")
    self._mask = nil

    bindEventCallBack(self._checkbox, handler(self, self._onClickTab), ccui.TouchEventType.begin)
end

function UICampaignTabItem:getData()
    return self._data
end

function UICampaignTabItem:getKey()
    return self._data.key
end

function UICampaignTabItem:getName()
    return self._data.name
end

function UICampaignTabItem:setData( applicationInfo )
    self._data = applicationInfo
    self._text:setString(applicationInfo.name)
    local x,y = self:getPosition()

    game.service.CampaignService.getInstance():addEventListener("ON_SELECT_CAMPAIGN_TAB", handler(self, self._onSelect), self)
end

function UICampaignTabItem:_onSelect(event)
    if self._data == nil or event.key == nil then
        return
    end
    if self._data.key == event.key then
        self._checkbox:setSelected(true)
        game.service.CampaignService.getInstance():dispatchEvent({name ="EVENT_CAMPAIGN_SELECT_TAB",key = self._data.key})
        game.service.DataEyeService.getInstance():onEvent("EVENT_CAMPAIGN_TAB_" .. self._data.name)
    else
        self._checkbox:setSelected(false)
    end
end

function UICampaignTabItem:_hidelackMask()

end

function UICampaignTabItem:_onClickTab()
    game.service.CampaignService.getInstance():dispatchEvent({name ="ON_SELECT_CAMPAIGN_TAB",key = self._data.key})
end

function UICampaignTabItem:dispose()
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)    
end

return UICampaignTabItem