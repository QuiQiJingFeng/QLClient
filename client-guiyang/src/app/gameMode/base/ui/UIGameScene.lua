local csbPath = "ui/csb/Poker/Table.csb"
local super = require("app.game.ui.UIBase")
local UIGameScene = class("UIGameScene", super, function() return kod.LoadCSBNode(csbPath) end)
local UIPlayer = require("app.gameMode.base.ui.UIPlayer")
local MAX_PLAYER_COUNT = 6

function UIGameScene:ctor()
    super.ctor(self)

    self._uiplayers = {}
end

-- called by UIManger
function UIGameScene:init()
    cc.bind(self, "event")
end

function UIGameScene:dispose()
    cc.unbind(self, "event")
end

-- 根据player的中服务器传来的位置，把uiplayer添加到客户端应该显示的容器中
-- 各个游戏按需重载次方法
function UIGameScene:addPlayer( player, cPos )
    -- 1.找到对应的容器
    local container = self:_findPlayerContainer(cPos)
    -- 2.如果需要加载不同的(我和其他)由各游戏自己区分
    local playerUIObj = self:_createPlayerUI(cPos, player)
    -- 3.生成ui，并添加到对应容器
    self:addUIComponent(playerUIObj, container)
    -- 4.插入uiplayers
    self._uiplayers[cPos] = playerUIObj -- ??? table.insert( self._uiplayers, cPos, playerUIObj ) 
    -- 5.返回ui，用于上层和processor绑定
    return playerUIObj
end

-- 删除所有player的ui节点
function UIGameScene:removeAllPlayers()
    for _, uiobj in pairs(self._uiplayers) do
        uiobj:dispose() -- 自己里面实现removeFromParent
    end

    self._uiplayers = {}
end

-- 删除某个player
function UIGameScene:removePlayer(cPos)
    local uiobj = self._uiplayers[cPos]
    uiobj:dispose()
    self._uiplayers[cPos] = nil
end

-- update某个player
function UIGameScene:updatePlayer(player, cPos)
    local uiobj = self._uiplayers[cPos]
    uiobj:updatePlayerInfo(player)
end

-- 添加控件的同时，注册控件的events
function UIGameScene:addUIComponent(uiobj, contianer)
    -- addchild
    contianer:addChild(uiobj)
    uiobj:onAddInParent()

    -- 添加component的监听事件
    local events = uiobj:getEvents()
    for k, v in pairs(events) do
        -- todo 检查
        self:addEventListener(k, v, self)
    end
end

-- 传入客户端位置，找到对应的玩家的container，由各个游戏自己具体实现
function UIGameScene:_findPlayerContainer(pos)
    Macro.assert(false, "you must override the function")
end

-- 根据客户端位置和玩家数据生成玩家uiobj，由各个游戏自己具体实现
function UIGameScene:_createPlayerUI( pos, player )
    Macro.assert(false, "you must override the function")
end

function UIGameScene:prepareForNextRound()
    Macro.assert(false, "you must override the function")
end

function UIGameScene:onGameStarted()
    Macro.assert(false, "you must override the function")
end

function UIGameScene:destroy()
	-- 检查是不是还有没有解除引用的card
	CardFactory:getInstance():releaseAllCards()
end

return UIGameScene; 