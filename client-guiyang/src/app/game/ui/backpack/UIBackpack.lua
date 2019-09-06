local csbPath = "ui/csb/Backpack/UIBag.csb"
local super = require("app.game.ui.UIBase")

local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")

----------------------------------------------------------------------

-- 单条背包显示
----------------------------------------------------------------------
local UIElemBackpackItem = class("UIElemBackpackItem")

function UIElemBackpackItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemBackpackItem)
    self:_initialize()
    return self
end

function UIElemBackpackItem:_initialize()
     -- 实际上这条list显示的是一行有4个item，每个item在setdata的时候进行处理
     self.elem = {}
     self.elem[1] =  seekNodeByName(self, "item1", "ccui.Layout")
     self.elem[2] =  seekNodeByName(self, "item2", "ccui.Layout")
     self.elem[3] =  seekNodeByName(self, "item3", "ccui.Layout")
     self.elem[4] =  seekNodeByName(self, "item4", "ccui.Layout")
end

function UIElemBackpackItem:getData()
    return self._data
end

function UIElemBackpackItem:setData(applicationInfo)
    self._data = applicationInfo
    table.foreach(self.elem, function(key, val)
        val:setVisible(false)
    end)

    -- -- 将其显示出来 关联按钮事件
    for i = 1 , #applicationInfo do
        if applicationInfo[i].goodUID == nil then
            self:setItemProp( self.elem[i], applicationInfo[i].prop, applicationInfo[i].num)
        else
            self:setItemSubstance( self.elem[i], applicationInfo[i])
        end
    end
end

function UIElemBackpackItem:setItemProp( ui, data, number)
    local Icon = ui:getChildByName("Image_8")
    local num = ui:getChildByName("BitmapFontLabel_17")
    local tag = ui:getChildByName("Image_106")
    local lock = ui:getChildByName("Image_lock")
    local name = ui:getChildByName("Text_name")
    local outDate = ui:getChildByName("Image_2")
    local isUsing = ui:getChildByName("Image_23")
    ui:setVisible(true)    

    --如果是实物则用另一种方式显示
    Icon:setAnchorPoint(cc.p(0.5,0.5))
    Icon:loadTexture("art/function/img_none.png")
    PropReader.setIconForNode(Icon,PropReader.getIconById(data:getId()))
    outDate:setVisible(false)
    isUsing:setVisible(false)
    local numString = ""
    if PropReader.getTypeById(data:getId()) ==  "ConsumableTimeLimite" then
        num:setVisible(false)
        if data:getExternal().status == true then
            isUsing:setVisible(true)
        end
    end

    if numString== "" and #data:getExternal() == 0 then
        numString = "X" .. number
        num:setColor(cc.c3b(185, 56, 4))
    end

    num:setString(numString)
    name:setString(data:getName())
    tag:setVisible(false)

    if data:getExternal().content == "lock" then
        lock:setVisible(true)
        bindEventCallBack(ui, handler(self, function ()
            game.ui.UIMessageBoxMgr.getInstance():show("客官再等等，明天才能开启礼包呢，开启即有机会获得iphoneX等大奖！", {"确认"})
        end),ccui.TouchEventType.ended);
    else
        lock:setVisible(false)
        bindEventCallBack(ui, handler(self, function ()
            data:excute({num = number})
        end),ccui.TouchEventType.ended);
    end
end

function UIElemBackpackItem:setItemSubstance(ui ,data)
    local Icon = ui:getChildByName("Image_8")
    local num = ui:getChildByName("BitmapFontLabel_17")
    local tag = ui:getChildByName("Image_106")
    local lock = ui:getChildByName("Image_lock")
    local name = ui:getChildByName("Text_name")
    local isUsing = ui:getChildByName("Image_23")
    local outDate = ui:getChildByName("Image_2")

    ui:setVisible(true) 
    Icon:setAnchorPoint(cc.p(0.5,0.5))
    Icon:loadTexture("art/function/img_none.png")
    PropReader.setIconForNode(Icon,data.image or "")
    name:setString(data.goods)
    num:setVisible(false)
    tag:setVisible(false)
    lock:setVisible(false)
    isUsing:setVisible(false)
    outDate:setVisible(false)
    bindEventCallBack(ui, handler(self, function ()
        if data.status ~= 0 then
            UIManager:getInstance():show("UIGiftDetail", data.name, data.phone, data.address, data.logistics, data.order)
        else
            UIManager:getInstance():show("UIGiftTextField", data.goods, data.goodUID)
        end
    end),ccui.TouchEventType.ended);
end

local UIBackpack = class("UIBackpack", super, function () return kod.LoadCSBNode(csbPath) end)

function UIBackpack:ctor()
    self._checkboxGroup = {}
end

function UIBackpack:init()
    -- body
    self._btnBack  = seekNodeByName(self, "Button_Back",  "ccui.Button");
    self._listContent = seekNodeByName(self, "ListView_content",  "ccui.ListView");
    self._listTab = seekNodeByName(self, "ListView_Tab", "ccui.ListView") 
    self._propCb = seekNodeByName(self, "tabProp", "ccui.CheckBox")
    self._substanceCb = seekNodeByName(self, "tabSubstance", "ccui.CheckBox")
    self._textNone = seekNodeByName(self, "Text_none", "ccui.Text")
    self._imgNone = seekNodeByName(self, "Image_53", "ccui.ImageView")

    self._reuseContentListView = UIItemReusedListView.extend(seekNodeByName(self, "ListView_content", "ccui.ListView"), UIElemBackpackItem)

    self._listTab:setScrollBarEnabled(false)
    self._listContent:setScrollBarEnabled(false)

    self._checkboxGroup = CheckBoxGroup.new({
        self._propCb,
        self._substanceCb,
    },handler(self,self._onCheckBoxGroupClick))

    bindEventCallBack(self._btnBack, handler(self, self.onBtnBack),ccui.TouchEventType.ended);

    game.service.BackpackService:getInstance():addEventListener("EVENT_BACKPACK_FICTITIOUS", handler(self, self._refrashRightProp), self)
    game.service.BackpackService:getInstance():addEventListener("EVENT_BACKPACK_PRACTICAL", handler(self, self._refrashRightSubstance), self)
end

function UIBackpack:onShow( ... )
    local args = {...}
end

-- 初始化左侧list
function UIBackpack:_onCheckBoxGroupClick(group, index)
    if group[index] == self._propCb then
        game.service.BackpackService.getInstance():queryBackpack()
    elseif group[index] == self._substanceCb then
        game.service.GiftService.getInstance():queryGoods()
    end
end

-- 刷新右侧道具
function UIBackpack:_refrashRightProp(datas)
    local data = datas.data
    if #data == 0 then
        self._textNone:setString("暂时没有道具，敬请期待")
    else
        self._textNone:setString("")
    end
    self._textNone:getParent():setVisible(#data == 0)
    self._imgNone:setVisible(#data == 0)

    table.sort(data,function (a,b)
        if a.prop.extend ~= nil and b.prop.extend ~= nil then
            return a.prop.extend.createTime > b.prop.extend.createTime
        end

        return false
    end)

    self._listContent:deleteAllItems()

    -- 4个一组分割
    local afterSlicing = ReusedListViewFactory.splitTable(data, 4)
    for idx,member in ipairs(afterSlicing) do
        self._reuseContentListView:pushBackItem(member)
    end
end

-- 刷新右侧实物奖励
function UIBackpack:_refrashRightSubstance(datas)
    self._listContent:deleteAllItems()

    local data = datas.protocol.goodsList

    if #data == 0 then
        self._textNone:setString("暂时没有实物奖励")
    else
        self._textNone:setString("")
    end
    self._imgNone:setVisible(#data == 0)

    -- 4个一组分割
    local afterSlicing = ReusedListViewFactory.splitTable(data, 4)
    for idx,member in ipairs(afterSlicing) do
        self._reuseContentListView:pushBackItem(member)
    end
end

function UIBackpack:onBtnBack()
    UIManager:getInstance():destroy("UIBackpack");
end

function UIBackpack:needBlackMask()
	return true;
end

function UIBackpack:closeWhenClickMask()
	return false
end

function UIBackpack:onHide()
    -- 取消事件监听
    game.service.BackpackService.getInstance():removeEventListenersByTag(self)
end

function UIBackpack:onClose()
    UIManager:getInstance():destroy("UIBackpack")
end

-- 校验当前是否在该道具销毁时间之前
function UIBackpack:isBeforeDestoryTime( v)
    local cTime = game.service.TimeService:getInstance():getCurrentTime()
    -- 将时间字符串分割。。。
	local result = {}
	for k,v in string.gmatch( v:getDestoryTime(),"%d+" ) do
		table.insert(result,k)
    end
    -- 生成时间戳。。。默认dtime比ctime大，这样如果没有解析出来则默认会显示
    local dTime = cTime+1
    if #result == 6 then
        local dTime = os.time{year = result[1], month = result[2], day = result[3], hour = result[4], min = result[5], sec = result[6]}        
    end    

--[[
    如果有单个道具属性，则判断获取时间+duration(天)当前是否到期，若到期则不显示。如果有拓展属性，则默认返回false，
    用extension里的时间判断，如无则display返回true默认显示，使用dtime去判断是否显示
--]]
    local display = #v:getExternal() == 0 
    if v:getExternal().destroyTime > cTime then
        display = true
    end
    return dTime > cTime and display
end

-- 校验当前是否在该道具销毁时间之前
function UIBackpack:isDisplayInBackpack( v)
    return v:getStorageFlag() == "true" or v:getStorageFlag() == "TRUE"
end

return UIBackpack