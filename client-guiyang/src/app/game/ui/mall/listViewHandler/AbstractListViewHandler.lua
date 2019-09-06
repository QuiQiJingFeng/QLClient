--[[0
    create date:
        2018/07/23
    features:
        1、统一管理了ListView的常用接口，并且把常用接口暴露出来，子类重写实现他们
    changelog:
        18/08/17：
            1、增加 setVisible 与 onListViewVisibleChanged 接口
            2、删除 getListView 接口
            3、增加一个 empty text 的自动创建
        
]]
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local AbstractListViewHandler = class("AbstractListViewHandler")

function AbstractListViewHandler:ctor(rawListView)
    if Macro.assertFalse(AbstractListViewHandler.__cname ~= self.class, 'this is a abstract class !') then
        self.listView = ListFactory.get(rawListView, handler(self, self.onListViewItemInit), handler(self, self.onListViewItemSetData))
        self.listView:setTouchEnabled(true)
        UtilsFunctions.createListViewEmptyText(self.listView)
        self.listView.emptyText:setColor(UtilsFunctions.convert2CCColor("#97561F", 0xFF))
        self.listView.emptyText:setFontSize(35)
        self.listView.emptyText:setVisible(false)
        self.listView.emptyText:setString("")
    end

    self.currentSetDataLineNumber = 0
    self.rawData = nil
end

function AbstractListViewHandler:getRawData()
    return self.rawData
end

function AbstractListViewHandler:getRawDataItemByIndex(index)
    return self.rawData[index]
end

function AbstractListViewHandler:onListViewItemInit(listItem)
    listItem.layouts = {}
    for oneLineIndex = 1, self:getListViewOneLineCount() do
        local layout = seekNodeByName(listItem, "Layout_Item_" .. oneLineIndex, "ccui.Layout")
        layout.name = seekNodeByName(layout, "BMFont_Name", "ccui.TextBMFont")
        layout.icon = seekNodeByName(layout, "ImageView_Icon", "ccui.ImageView")
        layout.soldout = seekNodeByName(layout, "ImageView_Sold_Out", "ccui.ImageView")
        layout.connerTag = seekNodeByName(layout, "ImageView_Conner_Tag", "ccui.ImageView")

        layout.normalPriceLayout = seekNodeByName(layout, "Layout_Normal", "ccui.Layout")
        layout.normalPriceLayout.price = seekNodeByName(layout.normalPriceLayout, "BMFont_Price", "ccui.TextBMFont")


        layout.activityPriceLayout = seekNodeByName(layout, "Layout_Activty", "ccui.Layout")
        layout.activityPriceLayout.originPrice = seekNodeByName(layout.activityPriceLayout, "BMFont_Original_Price", "ccui.TextBMFont")
        layout.activityPriceLayout.postPrice = seekNodeByName(layout.activityPriceLayout, "BMFont_Post_Price", "ccui.TextBMFont")

        layout.normalPriceLayout:setTouchEnabled(false)
        layout.activityPriceLayout:setTouchEnabled(false)

        -- 初始化一下大小，有的子节点会不一样大
        layout.icon:setContentSize(cc.size(170,143))

        local lineNum = self:getCurrentSetDataLineNumber()
        bindEventCallBack(layout, function()
            self:onListViewItemSelected(lineNum, oneLineIndex)
        end, ccui.TouchEventType.ended)

        table.insert(listItem.layouts, layout)
    end
end

function AbstractListViewHandler:onListViewItemSetData(listItem, data)
    -- Macro.assertFalse(false, 'the function must overwrite in sub class')
    assert(false)
end

function AbstractListViewHandler:onListViewItemSelected(lineNum, oneLineIndex)
    -- print(lineNum, oneLineIndex)
end

function AbstractListViewHandler:getListViewOneLineCount()
    return 4
end

function AbstractListViewHandler:getListViewOneLineDefaultValue()
    return nil
end

function AbstractListViewHandler:onListViewPushDataStart()
    self.currentSetDataLineNumber = 0
    self.listView:deleteAllItems()
    self.listView:beginUpdateItemDatas()
end

function AbstractListViewHandler:onListViewPushDataEnd()
    self.listView:endUpdateItemDatas()
end


function AbstractListViewHandler:getCurrentSetDataLineNumber()
    return self.currentSetDataLineNumber
end

function AbstractListViewHandler:dispose()
    UtilsFunctions.destroyListViewEmptyText(self.listView)
    self.rawData = nil
end


function AbstractListViewHandler:setListViewData(rawData)
    self.rawData = rawData
    local oneLineCount = self:getListViewOneLineCount()
    local defaultValue = self:getListViewOneLineDefaultValue()
    local data = ListFactory.splitTable(rawData, oneLineCount, defaultValue)
    self:onListViewPushDataStart()
    for lineNum, oneLineData in ipairs(data) do
        self.currentSetDataLineNumber = self.currentSetDataLineNumber + 1
        self.listView:pushBackItem(oneLineData)
    end
    self:onListViewPushDataEnd()
end

function AbstractListViewHandler:setVisible(value)
    self.listView:setVisible(value)
    self:onListViewVisibleChanged(value)
end

function AbstractListViewHandler:onListViewVisibleChanged(isVisible)
    local value = isVisible and #(self.rawData or {}) == 0
    self.listView.emptyText:setVisible(value)
end

return AbstractListViewHandler