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
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }
    self._tableViewBottom:updateDatas(datas)

    local datas = {
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }
    self._tableViewRight:updateDatas(datas)

    local datas = {
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }
    self._tableViewTop:updateDatas(datas)

    local datas = {
        {type = "gang",cardValue = 24,from = 1},
        {type = "angang",cardValue = 22,from = 2},
        {type = "peng",cardValue = 35,from = 3},
        {type = "handCard",cardValue = 2,output = true},
        {type = "handCard",cardValue = 3,output = true},
        {type = "handCard",cardValue = 4},
        {type = "handCard",cardValue = 9},
        {type = "handCard",cardValue = 255,isLastCard = true},
    }
    self._tableViewLeft:updateDatas(datas)
end

 
return UIBattleScene