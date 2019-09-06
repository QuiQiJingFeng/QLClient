local csbPath = "ui/csb/HeadFrame/UIHeadframe.csb"
local super = require("app.game.ui.UIBase")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local HeadType = {
    Boutique = 1, -- 精选
    Limited  = 2, -- 限定
    Achieve  = 3, -- 成就
}
-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIHeadMallItem = class("UIHeadMallItem")

function UIHeadMallItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIHeadMallItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UIHeadMallItem:_initialize()
    -- 实际上这条list显示的是一行有4个item，每个item在setdata的时候进行处理
    self.elem = {}
    self.elem[1] =  seekNodeByName(self, "Panel_headframe1", "ccui.Layout")
    self.elem[2] =  seekNodeByName(self, "Panel_headframe2", "ccui.Layout")
    self.elem[3] =  seekNodeByName(self, "Panel_headframe3", "ccui.Layout")
    self.elem[4] =  seekNodeByName(self, "Panel_headframe4", "ccui.Layout")
    self.elem[5] =  seekNodeByName(self, "Panel_headframe5", "ccui.Layout")

    game.service.HeadFrameService:getInstance():removeEventListenersByEvent("EVENT_SELECT_HEAD")
    game.service.HeadFrameService:getInstance():removeEventListenersByEvent("EVENT_USE_HEAD")
end

function UIHeadMallItem:getData()
    return self._data
end

function UIHeadMallItem:setData( applicationInfo )
    -- items用的事件
    game.service.HeadFrameService:getInstance():addEventListener("EVENT_SELECT_HEAD", handler(self, self._onSelect), self)
    game.service.HeadFrameService:getInstance():addEventListener("EVENT_USE_HEAD", handler(self, self._onUse), self)
    self._data = applicationInfo
    -- 先全部隐藏起来
    table.foreach(self.elem, function(key, val)
        val:setVisible(false)
        -- 添加id属性，以便对选中时进行监听处理
    end)

    -- 将其显示出来 关联按钮事件
    for i = 1 , #applicationInfo do
        self.elem[i]:setVisible(true)
        -- 添加id属性，以便对选中时进行监听处理
        self.elem[i].id = applicationInfo[i].id
        self:setItem( self.elem[i], applicationInfo[i])
    end
end

function UIHeadMallItem:setItem( ui, info)
    -- 暂时先用reader
    local select = ui:getChildByName("Image_23")
    local locked = ui:getChildByName("Image_14_0_0")
    local icon = ui:getChildByName("Image_14")
    local using = ui:getChildByName("using")
    local own = ui:getChildByName("own")

    -- 如果当前是第一行第一个则设为true
    select:setVisible(info.isSelect)
    locked:setVisible(info.isLock and not info.isOwn)
    using:setVisible(info.id == game.service.LocalPlayerService.getInstance():getHeadFrameId())
    own:setVisible(info.isOwn and not info.isOwnHide)

    game.util.PlayerHeadIconUtil.setIconFrame(icon,PropReader.getIconById(info.id),0.7)
    
    bindEventCallBack(ui,   function ()
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_HEAD", data = info}); 
    end,    ccui.TouchEventType.ended)
end

function UIHeadMallItem:_onSelect( event)
    if self.elem == nil then return end
    table.foreach(self.elem, function(key, val)
        val:getChildByName("Image_23"):setVisible(val.id == event.data.id)        
        if val.id == event.data.id then
            game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_HEAD_FOCUSON", data = event.data});     
        end    
    end)
end

function UIHeadMallItem:_onUse( event)
    if self.elem == nil then return end
    table.foreach(self.elem, function(key, val)
        local icon = val:getChildByName("Image_14")
        val:getChildByName("using"):setVisible(val.id == event.data)
    end)
end
-------------------------------------------------------------------------------------
local UIHeadMall = class("UIHeadMall", super, function () return kod.LoadCSBNode(csbPath) end)

function UIHeadMall:ctor()
    self._btnClose = nil
    self._reusedHeadList = nil;
    self._currentSelect = {}
    self._ownerList = {}
    self._boutiqueList = {}
    self._limitedList = {}
    self._achieveList = {}

    -- 标签页
    self._listPannel = seekNodeByName(self, "ListView_2", "ccui.ListView")
    self._ownerCB = seekNodeByName(self, "Checkbox_myframe", "ccui.CheckBox")          -- 已拥有
    self._boutiqueCB = seekNodeByName(self, "CheckBox_boutique", "ccui.CheckBox")        -- 精品
    self._limitedCB = seekNodeByName(self, "CheckBox_limited", "ccui.CheckBox")       -- 限定
    self._achieveCB = seekNodeByName(self, "CheckBox_achieve", "ccui.CheckBox")        -- 成就
    self._checkboxGroup = {}

    -- 当前选中头像展示相关的一些ui
    self.headName = seekNodeByName(self, "Text_8", "ccui.Text")                         -- 玩家名称
    self.headIcon = seekNodeByName(self, "Image_head", "ccui.ImageView")                -- 玩家头像
    self.icon = seekNodeByName(self, "Image_11_2_0_2", "ccui.ImageView")
    self.desc = seekNodeByName(self, "Text_8_0", "ccui.Text")
    self.obtainWay = seekNodeByName(self, "Text_8_0_0", "ccui.Text")
    self.waiting = seekNodeByName(self, "Text_8_0_0_0", "ccui.Text")
    self._btnBuy = seekNodeByName(self, "Button_buy", "ccui.Button")
    self._btnUse = seekNodeByName(self, "Button_use", "ccui.Button")
    self._existDays = seekNodeByName(self, "Text_8_0_1", "ccui.Text")    

    self._reusedHeadList = UIItemReusedListView.extend(seekNodeByName(self, "pannelList", "ccui.ListView"), UIHeadMallItem)
    self._btnClose = seekNodeByName(self, "Button_back",  "ccui.Button");
    self._listPannel:setScrollBarEnabled(false)
    self._reusedHeadList:setScrollBarEnabled(false)
end

function UIHeadMall:init()
    self:_registerCallback()
    -- 先隐藏其他的
    self._achieveCB:setVisible(false)
    -- self._limitedCB:setVisible(false)
    -- self._achieveCB:setVisible(false)

    self._checkboxGroup = CheckBoxGroup.new({
        self._ownerCB,
        self._boutiqueCB,
        self._limitedCB,
        -- self._achieveCB
    },handler(self,self._onCheckBoxGroupClick))
end

function UIHeadMall:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBuy, handler(self, self._onBuy), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnUse, handler(self, self._onUse), ccui.TouchEventType.ended)
end

function UIHeadMall:onShow( data )
    game.service.HeadFrameService:getInstance():addEventListener("EVENT_HEAD_FOCUSON", handler(self, self._onFocous), self)
    game.service.HeadFrameService:getInstance():addEventListener("EVENT_HEADLIST_REFRASH", handler(self, self._onRefrashList), self)
    
    self:_updateMyData(data)    
    game.util.PlayerHeadIconUtil.setIcon(self.headIcon, game.service.LocalPlayerService.getInstance():getIconUrl());

    -- 默认选中第一个
    self:refrashList(self._ownerList ,true)

    self._bindKeys = {
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.CARD, seekNodeByName(self, "Panel_Card", "ccui.Layout")),
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.BEAN, seekNodeByName(self, "Panel_Bean", "ccui.Layout")),
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.GOLD, seekNodeByName(self, "Panel_Gold", "ccui.Layout")),
    }
end

function UIHeadMall:_onRefrashList(event)
    local data = event.data
    self:_updateMyData(data)
    
    -- 跳回已拥有
    self:refrashList(self._ownerList ,true)
    self._checkboxGroup:setSelectedIndex(1)

    -- 获取数据
    local tmpData = {}
    table.foreach(data,function (k,v)
        if v.id == event.select then
            tmpData = v
        end
    end)

    -- 默认选中
    if event.select ~= 0 then
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_HEAD", data = tmpData});  
    end
end

function UIHeadMall:_updateMyData(data)
    -- 将列表按照类别分好,先清空已有的
    self._ownerList = {}
    self._boutiqueList = {}
    self._limitedList = {}
    self._achieveList = {}
    table.foreach(data,function (k,v)
        -- 添加当前是否选中
        v.isSelect = false
        -- 挑出已拥有的
        if v.isOwn then
            table.insert(self._ownerList, v)
        end
         -- 挑出精品的
         if v.type == HeadType.Boutique then
            table.insert(self._boutiqueList, v)
        end
         -- 挑出限定的
         if v.type == HeadType.Limited then
            table.insert(self._limitedList, v)
        end
         -- 挑出成就的
         if v.type == HeadType.Achieve then
            table.insert(self._achieveList, v)
        end
    end)
end

function UIHeadMall:_onCheckBoxGroupClick(group, index)
    -- 只有已拥有的显示使用按钮
    self._btnUse:setVisible(group[index] == self._ownerCB)
    self._btnBuy:setVisible(group[index] ~= self._ownerCB)
    if group[index] == self._ownerCB then
        -- 已拥有
        self:refrashList(self._ownerList, true)        
    elseif group[index] == self._boutiqueCB then
        -- 精品
        self:refrashList(self._boutiqueList, false)
    elseif group[index] == self._limitedCB then
        -- 限量
        self:refrashList(self._limitedList, false)
    elseif group[index] == self._achieveCB then
        -- 成就
        self:refrashList(self._achieveList, false)
    end
end

-- 当选中头像时左侧显示信息
function UIHeadMall:_onFocous(event)
    self._currentSelect = event.data
    self.headName:setString(self._currentSelect.name)
    game.util.PlayerHeadIconUtil.setIconFrame(self.icon,PropReader.getIconById(self._currentSelect.id),0.7)

    self.desc:setString(self._currentSelect.desc)
    self.obtainWay:setVisible(false)
    self._btnBuy:setVisible(not self._currentSelect.isLock and not self._currentSelect.isOwn)
    self.waiting:setVisible(self._currentSelect.isLock)

    if self._currentSelect.isOwn == true and self._currentSelect.endTime ~= nil then
        self._existDays:setVisible(true)
        self.waiting:setVisible(false)
        self._existDays:setString(self:calcExistsDays(self._currentSelect.startTime,self._currentSelect.endTime))
    else
        self._existDays:setVisible(false)
    end
end

function UIHeadMall:calcExistsDays(createTime, endTime)
    local result = ""
    local now = game.service.TimeService:getInstance():getCurrentTime()*1000
    local day = math.floor((endTime- now)/ 86400000)
    local hour = math.floor(((endTime- now)% 86400000)/3600000)
    local min = math.floor(((endTime- now)% 3600000)/60000)

    result = day .. "天" .. hour .."小时"    
    if day == 0 then
        result = hour .. "小时" .. min .."分钟"  
    end
    if endTime == 0 then
        result = "永久"
    end
    return result
end

function UIHeadMall:_onBuy()
    if self._currentSelect == {} then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("请先选择一个头像框")   
        return
    end
    UIManager:getInstance():show("UIBuyHeadSelect", self._currentSelect)
end

function UIHeadMall:_onUse()
    if self._currentSelect == {} then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("请先选择一个头像框")   
        return 
    elseif self._currentSelect.id == game.service.LocalPlayerService.getInstance():getHeadFrameId() then
        game.ui.UIMessageTipsMgr.getInstance():showTips("您正在使用该头像")   
        return 
    end
    if self._currentSelect.id ~= nil and self._currentSelect.id ~= 0 then
        game.service.HeadFrameService:getInstance():querySwitchHeadFrame(self._currentSelect.id)
    end
end

-- 刷新头像列表
function UIHeadMall:refrashList(list, isOwnHide)
    self._reusedHeadList:deleteAllItems()
    -- 给list分组      
    local afterSlicing = {}
    local num = 0
    local group = (#list - 1)/ 5 + 1
    for i = 1, group do
        for j = 1,5 do
            if list[(i-1) * 5 + j] then
                if afterSlicing[i] == nil then
                    afterSlicing[i] = {}
                end
                list[(i-1) * 5 + j].isOwnHide = isOwnHide      
                table.insert(afterSlicing[i],list[(i-1) * 5 + j])
            end
        end
    end
    for idx,member in ipairs(afterSlicing) do
        self._reusedHeadList:pushBackItem(member)
    end

    -- -- 默认选中第一个
    -- if #list > 0 then
    --     game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_HEAD", data = list[1]});    
    -- end
    
    -- 选择当前带着的 -- 马驰骋modify
    local tmpData = {}
    table.foreach(list,function (k,v)
        if v.id == game.service.LocalPlayerService.getInstance():getHeadFrameId() then
            tmpData = v
        end
    end)
    if tmpData.id == nil then
        if #list == 0 then 
            self._btnBuy:setVisible(false)
            return 
        end
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_HEAD", data = list[1]});    
    else
        game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_HEAD", data = tmpData});  
    end
end

function UIHeadMall:onHide()
    game.service.HeadFrameService:getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)

    for _, key in ipairs(self._bindKeys or {}) do
        CurrencyHelper.getInstance():getBinder():unbind(key)
    end
    self._bindKeys = {}
end

function UIHeadMall:_onClose()
    UIManager:getInstance():destroy("UIHeadMall")
end

function UIHeadMall:needBlackMask()
	return true;
end

function UIHeadMall:closeWhenClickMask()
	return false
end

return UIHeadMall