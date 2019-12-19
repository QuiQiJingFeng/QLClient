local csbPath = "ui/csb/mengya/battle/UIBattlePlayerTwo.csb"
local super = import("views.UIBattleBase")
local Util = game.Util
local UITableViewEx = game.UITableViewEx
local PlaceProcessor = import("logic.PlaceProcessor")
local UIBattleTwo = class("UIBattleTwo", super, function () return Util:loadCSBNode(csbPath) end)

function UIBattleTwo:ctor(...)
    super.ctor(self,...)
    local CONVERT_TO_OBJECT = game.CardFactory:getInstance():getConvertObjList()
    local CARD_TYPE = game.CardFactory:getInstance():getCardType()
    --出牌区域
    --底部出牌区域
    local discardBottom = Util:seekNodeByName(self,"tableViewDiscardBottom","ccui.ScrollView")
    self._discardListBottom = UITableViewEx.extend(discardBottom,CONVERT_TO_OBJECT[CARD_TYPE.DISCARD])
    self._discardListBottom:perUnitNums(23)

    --顶部出牌区域
    local discardTop = Util:seekNodeByName(self,"tableViewDiscardTop","ccui.ScrollView")
    self._discardListTop = UITableViewEx.extend(discardTop,CONVERT_TO_OBJECT[CARD_TYPE.DISCARD])
    self._discardListTop:perUnitNums(23)
    self._places = {}
    local directions = {"Top","Bottom"}
    for _, name in ipairs(directions) do
        local processor = PlaceProcessor.new(name)
        processor:setHandList(self["_handList"..name])
        processor:setDiscardList(self["_discardList"..name])
        processor:setPlayer(self["_player"..name])
        table.insert(self._places,processor)
    end
    Util:show(self._handListBottom,self._handListTop)
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
    local data = {roomId = 99988547,descript = "房间规则描述啊啊啊",isCreator = true}
    super.onShow(self,data)
end

return UIBattleTwo