local csbPath = app.UICreateRoomCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UICreateRoomLeftItem = app.UICreateRoomLeftItem
local ConfigManager = app.ConfigManager
local UIRoomSetting = app.UIRoomSetting

local UICreateRoom = class("UICreateRoom", super, function() return app.Util:loadCSBNode(csbPath) end)

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
    app.RoomService:getInstance():sendCreaterRoomREQ(settings)
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
    local datas = {
        {
            id = 65537,
            name = "贵阳麻将"
        },
        {
            id = 65547,
            name = "两房麻将"
        },
        {
            id = 65548,
            name = "两丁一房"
        },
        {
            id = 65546,
            name = "铜仁麻将"
        },
        {
            id = 589825,
            name = "闷胡流血"
        },
        {
            id = 65538,
            name = "遵义麻将"
        },
        {
            id = 65539,
            name = "安顺麻将"
        },
        {
            id = 65545,
            name = "跑得快"
        }
    }

    self._scrollListLeft:updateDatas(datas)

    local selectIdx = 1
    local item = self._scrollListLeft:getCellByIndex(selectIdx)
    self:_onItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UICreateRoom:onHide()
 
end

return UICreateRoom