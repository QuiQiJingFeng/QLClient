local csbPath = "ui/csb/mengya/battle/UIBattlePlayerMore.csb"
local super = import("views.UIBattleBase")
local Util = game.Util
local UITableViewEx = game.UITableViewEx
local UIBattleDiscardBottomItem = import("items.UIBattleDiscardBottomItem")
local UIBattleDiscardLeftItem = import("items.UIBattleDiscardLeftItem")
local UIBattleDiscardRightItem = import("items.UIBattleDiscardRightItem")
local PlaceProcessor = import("logic.PlaceProcessor")
local UIBattleTree = class("UIBattleTree", super, function () return Util:loadCSBNode(csbPath) end)

function UIBattleTree:ctor(...)
    super.ctor(self,...)
    local CONVERT_TO_OBJECT = game.CardFactory:getInstance():getConvertObjList()
    local CARD_TYPE = game.CardFactory:getInstance():getCardType()
    --出牌区域
    --底部出牌区域
    local discardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._discardListBottom = UITableViewEx.extend(discardBottom,CONVERT_TO_OBJECT[CARD_TYPE.DISCARD])
    self._discardListBottom:perUnitNums(12)
    --左边出牌区域
    local discardLeft = Util:seekNodeByName(self,"tableViewDiscardLeft","ccui.ScrollView")
    self._discardListLeft = UITableViewEx.extend(discardLeft,CONVERT_TO_OBJECT[CARD_TYPE.DISCARD])
    self._discardListLeft:perUnitNums(9)
    self._discardListLeft:enabledZOrder(true)

    --右边出牌区域
    local discardRight = Util:seekNodeByName(self,"tableViewDiscardRight","ccui.ScrollView")
    self._discardListRight = UITableViewEx.extend(discardRight,CONVERT_TO_OBJECT[CARD_TYPE.DISCARD])
    self._discardListRight:perUnitNums(9)

    --顶部出牌区域
    local discardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    Util:hide(discardTop)

    self._places = {}
    local directions = {"Left","Bottom","Right"}
    for _, name in ipairs(directions) do
        local processor = PlaceProcessor.new(name)
        processor:setHandList(self["_handList"..name])
        processor:setDiscardList(self["_discardList"..name])
        processor:setPlayer(self["_player"..name])
        table.insert(self._places,processor)
    end
    Util:show(self._handListBottom,self._handListRight,self._handListLeft)
end

function UIBattleTree:needBlackMask()
    return false
end

function UIBattleTree:isFullScreen()
    return true
end

function UIBattleTree:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIBattleTree:onShow()
    local data = {roomId = 99988547,descript = "房间规则描述啊啊啊",isCreator = true}
    super.onShow(self,data)
end

return UIBattleTree