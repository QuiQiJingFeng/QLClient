local csbPath = app.UIHelpCsb
local super = app.UIBase
local Util = app.Util
local UITableView = app.UITableView
local UIHelpLeftItem = app.UIHelpLeftItem

local UIHelp = class("UIHelp", super, function() return app.Util:loadCSBNode(csbPath) end)
 
function UIHelp:ctor()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIHelpLeftItem,handler(self,self._onItemClick))
end

function UIHelp:_onItemClick(item,data)
    
end

function UIHelp:_onBtnBackClick()
    UIManager:getInstance():hide("UIHelp")
end

function UIHelp:getGradeLayerId()
    return 2
end

function UIHelp:isFullScreen()
    return true
end

function UIHelp:onShow()
    local datas = {
        {name = "贵阳麻将"},
        {name = "两房麻将"},
        {name = "两丁一房"},
        {name = "铜仁麻将"},
        {name = "闷胡血流"},
        {name = "遵义麻将"},
        {name = "安顺麻将"},
        {name = "跑得快"}
    }
    self._scrollListLeft:updateDatas(datas)
end

 
return UIHelp