local super = require("mengya.app.ui.battle.UIBattleScene")
local Util = app.Util
local UIBattleSceneTwo = class("UIBattleSceneTwo", super)
 
function UIBattleSceneTwo:init()
    self.super.init(self)
    local nodeDiscardAnchor = Util:seekNodeByName(self,"nodeDiscardAnchor","cc.Node")
    local discardPanels = app.Util:loadCSBNode("csb/mengya/battle/UIBattlePlayerTwo.csb")
    nodeDiscardAnchor:addChild(discardPanels)
    local tableViewDiscardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._players["BOTTOM"]:setPlayerDiscardList(tableViewDiscardBottom,"BOTTOM",24)
    local tableViewDiscardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    self._players["TOP"]:setPlayerDiscardList(tableViewDiscardTop,"TOP",24)
end
 
return UIBattleSceneTwo