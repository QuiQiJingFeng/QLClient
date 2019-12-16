local csbPath = "ui/csb/mengya/battle/UIBattlePlayerTwo.csb"
local super = import("views.UIBattleBase")
local Util = game.Util
local UITableViewEx = game.UITableViewEx
local UIBattleDiscardBottomItem = import("items.UIBattleDiscardBottomItem")
local UIBattleDiscardTopItem = import("items.UIBattleDiscardTopItem")
local PlaceProcessor = import("logic.PlaceProcessor")
local UIBattleTwo = class("UIBattleTwo", super, function () return Util:loadCSBNode(csbPath) end)

function UIBattleTwo:ctor(...)
    super.ctor(self,...)
    --底部出牌区域
    local discardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._discardListBottom = UITableViewEx.extend(discardBottom,UIBattleDiscardBottomItem)
    self._discardListBottom:perUnitNums(23)
    
    --顶部出牌区域
    local discardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    self._discardListTop = UITableViewEx.extend(discardTop,UIBattleDiscardTopItem)
    self._discardListTop:perUnitNums(23)

    self._places = {}
    local directions = {"Top","Down"}
    for _, name in ipairs(directions) do
        local processor = PlaceProcessor.new()
        processor:setHandList(self["_handList"..name])
        processor:setDiscardList(self["_discardList"..name])
        processor:setPlayer(self["_player"..name])
        table.insert(self._places,processor)
    end
end

function UIBattleTwo:needBlackMask()
    return false
end

function UIBattleTwo:isFullScreen()
    return true
end

function UIBattleTwo:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIBattleTwo:onShow()

end

return UIBattleTwo