local super = require "app.gameMode.paodekuai.processor.PlayerProcessor_Other"
local CardList_Paodekuai = require "app.gameMode.paodekuai.ui.CardList_Paodekuai"
local UITableOptions_Paodekuai = require "app.gameMode.paodekuai.ui.UITableOptions_Paodekuai"
local CardFactory = require "app.gameMode.paodekuai.core.CardFactory_Paodekuai"
local CardDefines = require "app.gameMode.paodekuai.core.CardDefines_Paodekuai"

local PlayerProcessor_Local = class("PlayerProcessor_Local", super)
function PlayerProcessor_Local:ctor(cPos, playerInfo, uiPlayer)
    super.ctor(self, cPos, playerInfo, uiPlayer)

    local gameScene = UIManager:getInstance():getUI("UIGameScene_Paodekuai")
    local container = gameScene:getCardContainer()
    local nodeTableOptions = gameScene:getNodeTableOptions()

    self._cardList = CardList_Paodekuai.new(container)
    self._uiTableOptions = UITableOptions_Paodekuai.new(nodeTableOptions, self._cardList, self)
    self._uiTableOptions:setTipsHandler(handler(self._cardList, self._cardList.onTips))

    local stateName = GameFSM:getInstance():getCurrentState().class.__cname
    local isReplay = string.match(string.lower(stateName), "replay") == 'replay'
    local isWatcher = game.service.LocalPlayerService:getInstance():isWatcher()
    self._cardList:setEnable(false)
    self._cardList:setTouchEnable(not isReplay and not isWatcher)
    self._uiTableOptions:setEnable(not isReplay and not isWatcher)

    self._isWatcher = isWatcher

    -- test code
    -- self._cardList:setEnable(true)
    -- self._cardList:setValues({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18})
    -- self._uiTableOptions:setEnable(true)
    -- self._uiTableOptions:addValue('discard') 
    -- self._uiTableOptions:addValue('tips')
    -- self._uiTableOptions:addValue('pass')
    -- test end
end

-- @override
function PlayerProcessor_Local:onGameStarted(playerInfo, isRecover)
    self.super.onGameStarted(self, playerInfo, isRecover)
    self._cardList:setEnable(true)
    local cards = CardFactory:convert(playerInfo.handCards)
    Logger.debug("====onGameStarted")
    Logger.debug("roleId = " .. playerInfo.roleId)
    Logger.debug("card = " .. table.concat(cards, "|"))
    self._cardList:setValues(CardDefines.sort(cards))
    self._uiTableOptions:cleanUp()
end

-- overwrite
function PlayerProcessor_Local:prepareForNextRound()
    self.super.prepareForNextRound(self)
    if self._cardList then
        self._cardList:prepareForNextRound()
    end

    if self._uiTableOptions then
        self._uiTableOptions:prepareForNextRound()
    end
end

function PlayerProcessor_Local:getCardList()
    return self._cardList
end

function PlayerProcessor_Local:getUITableOptions()
    return self._uiTableOptions
end

function PlayerProcessor_Local:onDiscard(cards)
    if Macro.assertFalse(cards, "card cannot equal nil") then
        self.super.onDiscard(self, cards)

        -- 观战模式下把传递给CardList的牌给赋值成255，方可正常删除手牌
        if self._isWatcher then
            local newCards = {}
            for i = 1, #cards do
                newCards[#newCards + 1] = 255
            end
            cards = newCards
        end
        self._cardList:onDiscard(cards)
    end
end

function PlayerProcessor_Local:cleanUpOperation()
    PlayerProcessor_Local.super.cleanUpOperation(self)
    self._uiTableOptions:cleanUp()
end

function PlayerProcessor_Local:autoPass()
    self._uiTableOptions:_onBtnPassClicked()
end

-- @override
function PlayerProcessor_Local:dispose()
    if self._cardList then
        self._cardList:dispose()
    end
    if self._uiTableOptions then
        self._uiTableOptions:dispose()
    end
    PlayerProcessor_Local.super.dispose(self)
end

return PlayerProcessor_Local