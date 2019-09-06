local room = require("app.game.ui.RoomSettingHelper")
local csbPath = "ui/csb/Paodekuai/Table_Paodekuai.csb"
local super = require "app.gameMode.base.ui.UIGameScene"
local UIPlayer_Paodekuai = require "app.gameMode.paodekuai.ui.UIPlayer_Paodekuai"
local UIGameScene_PanelWating = require "app.gameMode.base.ui.UIGameScene_PanelWating"

local MAX_PLAYER_NUM = 4 -- 配合麻将的写法。。。
local UIGameScene_Paodekuai = class("UIGameScene_Paodekuai", super, function() return kod.LoadCSBNode(csbPath) end)
---@overwrite
function UIGameScene_Paodekuai:ctor()
    self.super.ctor(self)
    self._iconNodes = {}
end

---@overwrite
function UIGameScene_Paodekuai:init()
    self.super.init(self)
    for i = 1, MAX_PLAYER_NUM do
        local nodePlayer = seekNodeByName(self, "Node_Head_Icon_" .. i, "cc.Node")
        self._iconNodes[i] = nodePlayer
    end

    self._waitingPanel = UIGameScene_PanelWating.new(self)
    self._waitingPanel:setEnable(true)

    self._nodeTableOptions = seekNodeByName(self, "Node_Table_Options", "cc.Node")
    self._nodeTableOptions:setVisible(false)
    self._cardContainer = seekNodeByName(self, "Layout_Poker_Container", "ccui.Layout")
    self._listRules = seekNodeByName(self, "Text_Rule", "ccui.Text")

    self._textRoundInfo = seekNodeByName(self, "Text_RoundCount_Info", "ccui.Text")
    self:_attachElementUI()
end

---@overwrite
function UIGameScene_Paodekuai:_findPlayerContainer(pos)
    return self._iconNodes[pos]
end

---@overwrite
function UIGameScene_Paodekuai:_createPlayerUI(pos, playerInfo)
    local uiContainer = self:_findPlayerContainer(pos)
    local uiPlayer = UIPlayer_Paodekuai.new(pos, playerInfo, uiContainer)
    uiPlayer:setEnable(true)
    return uiPlayer
end

function UIGameScene_Paodekuai:onShow(...)
    self:setRoomId(game.service.RoomService:getInstance():getRoomId())
end

function UIGameScene_Paodekuai:setRoomId(roomId)
    self._textRoomId:setString("房间号:" .. roomId or 0)
end


---@desc 添加牌桌左上角的控件
function UIGameScene_Paodekuai:_attachElementUI()
    local topLeftElemUI = seekNodeByName(self, "Panel_Top_Left", "ccui.Layout")
    self._uiElemBattery = require("app.game.ui.element.UIElemBattery").new(topLeftElemUI)
    self._uiElemTime = require("app.game.ui.element.UIElemTime").new(topLeftElemUI)
    self._uiElemNetwork = require("app.game.ui.element.UIElemNetwork").new(topLeftElemUI)
    self._textRoomId = seekNodeByName(topLeftElemUI, "Text_roomnumber_Scene", "ccui.Text")
end

function UIGameScene_Paodekuai:setRoundCount(now, total)
    local str = string.format("第%s/%s局", now, total)
    self._textRoundInfo:setString(str)
    self._waitingPanel:onRoundCountChanged(now)
end

-- @overwrite
function UIGameScene_Paodekuai:prepareForNextRound()
end

function UIGameScene_Paodekuai:onGameStarted(battlePlayers, isRecover)
    self._waitingPanel:onGameStarted()
end

---@overwrite
function UIGameScene_Paodekuai:dispose()

    if self._uiTableOptions ~= nil then
        self._uiTableOptions:dispose()
    end

    if self._uiElemBattery ~= nil then
        self._uiElemBattery:dispose()
    end

    if self._uiElemTime ~= nil then
        self._uiElemTime:dispose()
    end

    if self._uiElemNetwork ~= nil then
        self._uiElemNetwork:dispose()
    end

    if self._waitingPanel ~= nil then
        self._waitingPanel:dispose()
    end

    UIGameScene_Paodekuai.super.dispose(self)
end

function UIGameScene_Paodekuai:destroy()
    self:dispose()
end

function UIGameScene_Paodekuai:getCardContainer()
    return self._cardContainer
end

function UIGameScene_Paodekuai:getNodeTableOptions()
    return self._nodeTableOptions
end

function UIGameScene_Paodekuai:showRoomRules(settings)
    self._roomSettings = settings;
    local res = room.RoomSettingHelper.manageRuleLabels(settings)
    
    for i = 1, #res do
        local lineStr = res[i]
        self._listRules:setString(lineStr)
    end
end

return UIGameScene_Paodekuai