local csbPath = "ui/csb/mengya/UICreateRoom.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UICreateRoomLeftItem = require("app.ui.items.UICreateRoomLeftItem")
local UIRoomSetting = require("app.ui.views.UIRoomSetting")

local UICreateRoom = class("UICreateRoom", super, function() return game.Util:loadCSBNode(csbPath) end)

function UICreateRoom:init()
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UICreateRoomLeftItem,handler(self,self._onItemClick))
    local scrollGamePlay = Util:seekNodeByName(self,"scrollGamePlay","ccui.ScrollView")
    self._scrollGamePlay = UIRoomSetting.new(scrollGamePlay)
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    self._btnCreateRoom = Util:seekNodeByName(self,"btnCreateRoom","ccui.Button")
    Util:bindTouchEvent(self._btnCreateRoom,handler(self,self._onBtnCreateRoomClick))
end

function UICreateRoom:_onBtnCreateRoomClick()
    local settings = self._scrollGamePlay:getCurrentSettings()
    print("settings = ",table.concat(settings,","))
end

function UICreateRoom:_onBtnBackClick()
    UIManager:getInstance():hide("UICreateRoom")
end

function UICreateRoom:_onItemClick(item,data,eventType)
    self._scrollGamePlay:parseConfig(data.id,{})
end

function UICreateRoom:getGradeLayerId()
    return 2
end

function UICreateRoom:isFullScreen()
    return true
end

function UICreateRoom:onShow()
    local datas = game.UIConstant.GAME_TYPES

    self._scrollListLeft:updateDatas(datas)

    local selectIdx = 1
    local item = self._scrollListLeft:getCellByIndex(selectIdx)
    self:_onItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UICreateRoom:onHide()
 
end

return UICreateRoom