local super = require("mengya.app.ui.battle.UIBattleScene")
local Util = app.Util
local UIBattleSceneThree = class("UIBattleSceneThree", super)
 
function UIBattleSceneThree:init()
    self.super.init(self)
    local nodeDiscardAnchor = Util:seekNodeByName(self,"nodeDiscardAnchor","cc.Node")
    local discardPanels = app.Util:loadCSBNode("csb/mengya/battle/UIBattlePlayerMore.csb")
    nodeDiscardAnchor:addChild(discardPanels)

    local tableViewDiscardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._players["BOTTOM"]:setPlayerDiscardList(tableViewDiscardBottom,"BOTTOM",12)
    local tableViewDiscardLeft = Util:seekNodeByName(self,"tableViewDiscardLeft","ccui.ScrollView")
    self._players["LEFT"]:setPlayerDiscardList(tableViewDiscardLeft,"LEFT",9)
    local tableViewDiscardRight = Util:seekNodeByName(self,"tableViewDiscardRight","ccui.ScrollView")
    self._players["RIGHT"]:setPlayerDiscardList(tableViewDiscardRight,"RIGHT",9)


    local tableViewDiscardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    self._players["TOP"]:setPlayerDiscardList(tableViewDiscardTop,"TOP",12)
    self._players["TOP"]:setVisible(false)
    self._players["TOP"] = nil
end

 
return UIBattleSceneThree