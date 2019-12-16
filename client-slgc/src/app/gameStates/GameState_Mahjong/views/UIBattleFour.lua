local csbPath = "ui/csb/mengya/battle/UIBattlePlayerMore.csb"
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

function UIBattleFour:onShow(data)
    local data = {roomId = 99988547,descript = "房间规则描述啊啊啊",isCreator = true}
    super.onShow(self,data)

    local data = {
        {
            pos = 1,
            handList = {
                {type = "gang",cardValue = 24,from = 1},
                {type = "angang",cardValue = 22,from = 2},
                {type = "peng",cardValue = 35,from = 3},
                {type = "handCard",cardValue = 2,output = true},
                {type = "handCard",cardValue = 3,output = true},
                {type = "handCard",cardValue = 4},
                {type = "handCard",cardValue = 9},
                {type = "handCard",cardValue = 255,isLastCard = true},
            },
            discardList = {
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
        },
        {
            pos = 2,
            handList = {
                {type = "gang",cardValue = 24,from = 1},
                {type = "angang",cardValue = 22,from = 2},
                {type = "peng",cardValue = 35,from = 3},
                {type = "handCard",cardValue = 2,output = true},
                {type = "handCard",cardValue = 3,output = true},
                {type = "handCard",cardValue = 4},
                {type = "handCard",cardValue = 9},
                {type = "handCard",cardValue = 255,isLastCard = true},
            },
            discardList = {
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
        },
        {
            pos = 3,
            handList = {
                {type = "gang",cardValue = 24,from = 1},
                {type = "angang",cardValue = 22,from = 2},
                {type = "peng",cardValue = 35,from = 3},
                {type = "handCard",cardValue = 2,output = true},
                {type = "handCard",cardValue = 3,output = true},
                {type = "handCard",cardValue = 4},
                {type = "handCard",cardValue = 9},
                {type = "handCard",cardValue = 255,isLastCard = true},
            },
            discardList = {
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
        },
        {
            pos = 4,
            handList = {
                {type = "gang",cardValue = 24,from = 1},
                {type = "angang",cardValue = 22,from = 2},
                {type = "peng",cardValue = 35,from = 3},
                {type = "handCard",cardValue = 2,output = true},
                {type = "handCard",cardValue = 3,output = true},
                {type = "handCard",cardValue = 4},
                {type = "handCard",cardValue = 9},
                {type = "handCard",cardValue = 255,isLastCard = true},
            },
            discardList = {
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
        },
    }
    for idx, place in ipairs(self._places) do
        place:getHandList():updateDatas(data[idx].handList)
        place:getDiscardList():updateDatas(data[idx].discardList)
    end
end

return UIBattleFour