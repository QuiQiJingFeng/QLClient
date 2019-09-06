--[[0
    用做麻将牌桌皮肤切换，这里去处理某些事件去改变牌桌样式
    但是这里不判断 A 功能与 B 功能互斥的逻辑。

    1、牌桌切换，包含桌布、麻将牌背
    2、3d 2d 模式切换
    3、经典模式切换
]]
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local M = UtilsFunctions.singleton(class("MahjongTableSkinHandler"))

function M:ctor()
    self.service = game.service.LocalPlayerSettingService.getInstance()
end

function M:getUIRoom()
    return gameMode.mahjong.Context.getInstance():getGameService():getRoomUI()
end

function M:handle(type, value)
    if type == 'table_skin' then
        self:_onSettingTableSkinChanged(value)
    elseif type == 'mahjong_bg_skin' then
        self:_onSettingMahjongBGSkinChanged(value)
    elseif type == 'play_mode' then
        self:_onSettingPlayModeChanged(value)
    elseif type == 'classic_mode' then
        self:_onSettingClassicModeChanged(value)
    else
        Macro.assertFalse(false, 'unhandled type ' .. tostring(type))
    end
end

function M:_onSettingTableSkinChanged(value)
end

function M:_onSettingMahjongBGSkinChanged(value)
end

function M:_onSettingPlayModeChanged(value)
end

function M:_onSettingClassicModeChanged(value)
end

return M