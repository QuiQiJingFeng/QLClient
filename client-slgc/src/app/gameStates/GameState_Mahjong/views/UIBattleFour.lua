local csbPath = "ui/csb/mengya/battle/UIBattlePlayerTwo.csb"
local super = import("views.UIBattleBase")
local Util = game.Util
local UITableViewEx = game.UITableViewEx
local UIBattleDiscardBottomItem = import("items.UIBattleDiscardBottomItem")
local UIBattleDiscardLeftItem = import("items.UIBattleDiscardLeftItem")
local UIBattleDiscardRightItem = import("items.UIBattleDiscardRightItem")
local UIBattleDiscardTopItem = import("items.UIBattleDiscardTopItem")
local PlaceProcessor = import("logic.PlaceProcessor")

local UIBattleFour = class("UIBattleFour", super, function () return Util:loadCSBNode(csbPath) end)

function UIBattleFour:ctor(...)
    super.ctor(self,...)

    --出牌区域
    --底部出牌区域
    local discardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._discardListBottom = UITableViewEx.extend(discardBottom,UIBattleDiscardBottomItem)
    self._discardListBottom:perUnitNums(12)

    --左边出牌区域
    local discardLeft = Util:seekNodeByName(self,"tableViewDiscardLeft","ccui.ScrollView")
    self._discardListTop = UITableViewEx.extend(discardLeft,UIBattleDiscardLeftItem)
    self._discardListTop:perUnitNums(9)

    --右边出牌区域
    local discardRight = Util:seekNodeByName(self,"tableViewDiscardRight","ccui.ScrollView")
    self._discardListBottom = UITableViewEx.extend(discardRight,UIBattleDiscardRightItem)
    self._discardListBottom:perUnitNums(9)

    --顶部出牌区域
    local discardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    self._discardListTop = UITableViewEx.extend(discardTop,UIBattleDiscardTopItem)
    self._discardListTop:perUnitNums(9)

    self._places = {}
    local directions = {"Left","Down","Right","Top"}
    for _, name in ipairs(directions) do
        local processor = PlaceProcessor.new()
        processor:setHandList(self["_handList"..name])
        processor:setDiscardList(self["_discardList"..name])
        processor:setPlayer(self["_player"..name])
        table.insert(self._places,processor)
    end
end

function UIBattleFour:needBlackMask()
    return false
end

function UIBattleFour:isFullScreen()
    return true
end

function UIBattleFour:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIBattleFour:onShow()

end

return UIBattleFour