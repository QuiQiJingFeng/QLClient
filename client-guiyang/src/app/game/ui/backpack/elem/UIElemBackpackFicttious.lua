--[[
背包虚拟奖励页面
--]]
local csbPath = "ui/csb/Backpack/UIBackpack_Ficttious.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local BackpackItem = require("app.game.service.prop.BackpackItem");
local super = require("app.game.ui.UIBase")
----------------------------------------------------------------------

-- 单条背包显示
----------------------------------------------------------------------
local UIElemBackpackFictiousItem = class("UIElemBackpackFictiousItem")

function UIElemBackpackFictiousItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemBackpackFictiousItem)
    self:_initialize()
    return self
end

function UIElemBackpackFictiousItem:_initialize()
    -- 实际上这条list显示的是一行有4个item，每个item在setdata的时候进行处理
    self.elem = {}
    self.elem[1] =  seekNodeByName(self, "Panel_fictitious", "ccui.Layout")
    self.elem[2] =  seekNodeByName(self, "Panel_fictitious_0", "ccui.Layout")
    self.elem[3] =  seekNodeByName(self, "Panel_fictitious_1", "ccui.Layout")
    self.elem[4] =  seekNodeByName(self, "Panel_fictitious_2", "ccui.Layout")
end

function UIElemBackpackFictiousItem:getData()
    return self._data
end

-- 整体设置数据
function UIElemBackpackFictiousItem:setData (applicationInfo)
    self._data = applicationInfo
    -- 先全部隐藏起来
    table.foreach(self.elem, function(key, val)
        val:setVisible(false)
    end)

    -- -- 将其显示出来 关联按钮事件
    for i = 1 , #applicationInfo do
        self:setItem( self.elem[i], applicationInfo[i].prop, applicationInfo[i].num)
    end
end

function UIElemBackpackFictiousItem:setItem( ui, data, number)
    -- 暂时先用reader
    local name = ui:getChildByName("Text_Title")
    local button = ui:getChildByName("Button_See")
    local Icon = ui:getChildByName("Image_Goods")
    local num = ui:getChildByName("BitmapFontLabel_1")
    name:setString(data:getName())
    ui:setVisible(true)
    Icon:loadTexture(data:getIcon())
    num:setVisible(#data:getExternal() == 0)
    num:setString(number)
    
    bindEventCallBack(button,   function (self)
        data:excute()
    end,    ccui.TouchEventType.ended)
end

----------------------------------------------------------------------
--list
local UIElemBackpackFicttious = class("UIElemBackpackFicttious", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemBackpackFicttious:ctor(parent)
    self._parent = parent;
    self._reusedFictiousList = nil;

    self._reusedFictiousList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_fictitious1", "ccui.ListView"), UIElemBackpackFictiousItem)
    self._imgnone = seekNodeByName(self, "Image_No_0", "ccui.ImageView")
    self._reusedFictiousList:setScrollBarEnabled(false)
end

function UIElemBackpackFicttious:show(data)
    self:setVisible(true)
    self._imgnone:setVisible(#data == 0)
    -- 注册事件
    -- game.service.BackpackService:getInstance():addEventListener("EVENT_REFRESH_BACKPACK_FICTTIOUS", handler(self, self._onListChanged), self)
    -- 排序
    table.sort(data,function (a,b)
        if a.prop.extend ~= nil and b.prop.extend ~= nil then
            return a.prop.extend.createTime > b.prop.extend.createTime
        end

        return false
    end)

    self._reusedFictiousList:deleteAllItems()
    -- 给每个data分组
    local afterSlicing = {}
    local group = (#data - 1)/ 4 + 1
    for i = 1, group do
        for j = 1,4 do
            if data[(i-1) * 4 + j] then
                if afterSlicing[i] == nil then
                    afterSlicing[i] = {}
                end
                table.insert(afterSlicing[i],data[(i-1) * 4 + j])
            end
        end
    end
    for idx,member in ipairs(afterSlicing) do
        self._reusedFictiousList:pushBackItem(member)
    end
end

function UIElemBackpackFicttious:hide()
    self:setVisible(false)
end

-- 刷新列表
function UIElemBackpackFicttious:_onListChanged()
end

return UIElemBackpackFicttious;