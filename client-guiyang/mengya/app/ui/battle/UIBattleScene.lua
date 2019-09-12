local csbPath = app.UIBattleSceneCsb
local super = app.UIBase
local Util = app.Util
local UITableViewEx2 = app.UITableViewEx2

local UIBattleScene = class("UIBattleScene", super, function() return app.Util:loadCSBNode(csbPath) end)
 
function UIBattleScene:ctor()
    local tableViewList = Util:seekNodeByName(self,"tableViewListBottom","ccui.ScrollView")
    self._tableViewBottom = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleBottomItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListRight","ccui.ScrollView")
    self._tableViewRight = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleRightItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListTop","ccui.ScrollView")
    self._tableViewTop = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleTopItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListLeft","ccui.ScrollView")
    self._tableViewLeft = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleLeftItem)
end

function UIBattleScene:getGradeLayerId()
    return 2
end

function UIBattleScene:isFullScreen()
    return true
end

function UIBattleScene:onShow()
    local datas = {
        {type = "gang",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
        {type = "handCard",value = 24},
    }
    self._tableViewBottom:updateDatas(datas)


    local datas = {
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
    }
    self._tableViewRight:updateDatas(datas)


    local datas = {
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
    }
    self._tableViewTop:updateDatas(datas)

    local datas = {
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
        {type = "handCard",value = 255},
    }
    self._tableViewLeft:updateDatas(datas)
end

 
return UIBattleScene