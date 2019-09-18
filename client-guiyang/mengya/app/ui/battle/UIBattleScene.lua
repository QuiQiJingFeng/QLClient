local csbPath = app.UIBattleSceneCsb
local super = app.UIBase
local Util = app.Util
local UITableViewEx2 = app.UITableViewEx2
local UITableViewEx = app.UITableViewEx

local UIBattleScene = class("UIBattleScene", super, function() return app.Util:loadCSBNode(csbPath) end)
 
function UIBattleScene:init()
    local tableViewList = Util:seekNodeByName(self,"tableViewListBottom","ccui.ScrollView")
    local tableViewBottom = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleBottomItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListRight","ccui.ScrollView")
    local tableViewRight = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleRightItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListTop","ccui.ScrollView")
    local tableViewTop = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleTopItem)

    local tableViewList = Util:seekNodeByName(self,"tableViewListLeft","ccui.ScrollView")
    local tableViewLeft = app.UITableViewEx2.extend(tableViewList,app.UIBattleHandleLeftItem)


    local playerBottom = Util:seekNodeByName(self,"playerBottom","ccui.Layout")
    local playerRight = Util:seekNodeByName(self,"playerRight","ccui.Layout")
    local playerTop = Util:seekNodeByName(self,"playerTop","ccui.Layout")
    local playerLeft = Util:seekNodeByName(self,"playerLeft","ccui.Layout")

    self._players = {}
    self._players["LEFT"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerLeft,tableViewLeft)
    self._players["BOTTOM"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerBottom,tableViewBottom)
    self._players["RIGHT"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerRight,tableViewRight)
    self._players["TOP"] = require("mengya.app.ui.battle.players.PlayerBase").new(playerTop,tableViewTop)
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

    self._players["LEFT"]:setHandCardDatas(datas)
    self._players["BOTTOM"]:setHandCardDatas(datas)
    self._players["RIGHT"]:setHandCardDatas(datas)
    self._players["TOP"]:setHandCardDatas(datas)


    local datas = {
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        {cardValue = 2},
        
    }

    self._players["LEFT"]:setDisCardDatas(datas)
    self._players["BOTTOM"]:setDisCardDatas(datas)
    self._players["RIGHT"]:setDisCardDatas(datas)
    self._players["TOP"]:setDisCardDatas(datas)
end

 
return UIBattleScene