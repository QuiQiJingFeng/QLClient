local csbPath = app.UIReverseRoomCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UIReverseRoomLeftItem = app.UIReverseRoomLeftItem
local ConfigManager = app.ConfigManager
local UIReverseSetting = app.UIReverseSetting

local UIReverseRoom = class("UIReverseRoom", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIReverseRoom:init()
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIReverseRoomLeftItem,handler(self,self._onItemClick))
    local scrollGamePlay = Util:seekNodeByName(self,"scrollGamePlay","ccui.ScrollView")

    self._scrollGamePlay = UIReverseSetting.new(scrollGamePlay)
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))
end

function UIReverseRoom:_onBtnBackClick()
    UIManager:getInstance():hide("UIReverseRoom")
end

function UIReverseRoom:_onItemClick(item,data,eventType)
    self._scrollGamePlay:parseConfig(data.id,{})
end

function UIReverseRoom:getGradeLayerId()
    return 2
end

function UIReverseRoom:isFullScreen()
    return true
end

function UIReverseRoom:onShow()
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

function UIReverseRoom:onHide()
 
end

return UIReverseRoom