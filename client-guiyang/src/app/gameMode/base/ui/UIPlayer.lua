local csbPath = "ui/csb/Poker/PlayerIcon.csb"
local UIPlayer = class("UIPlayer", function() return cc.CSLoader:createNode(csbPath) end)

--[[
    evnets = {
        UIPLAYER_EXAMPLE -- 测试
    }
]]

function UIPlayer:ctor(cPos, playerInfo, uiContainer)
    self._cPos = cPos
    self._uiContainer = uiContainer
    self._playerInfo = playerInfo
end

function UIPlayer:init()
end

function UIPlayer:dispose()
    self:removeFromParent()
    self = nil
end

function UIPlayer:_eventExample()
    Logger.debug("example in uiplayer")
end

function UIPlayer:updatePlayerInfo(newPlayerInfo)
    self._playerInfo = newPlayerInfo
end

function UIPlayer:_updateDialogFrame(effects)
    
end

function UIPlayer:getPlayerInfo()
    return self._playerInfo
end

function UIPlayer:onAddInParent()
end

function UIPlayer:getEvents()
    return {
        -- ["UIPLAYER_EXAMPLE"] = handler(self, self._eventExample),
    }
end

return UIPlayer