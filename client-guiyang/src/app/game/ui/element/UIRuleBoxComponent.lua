--[[	房间规则组件，
	通过构造函数将csbNode加入到指定的root上
    普通打牌和回放获取数据的方式不同
--]]
local csbPath = "ui/csb/ui_component/UIRuleBoxComponent.csb"
local UIRuleBoxComponent = class("UIRuleBoxComponent", function() return kod.LoadCSBNode(csbPath) end)
local Constants = require("app.gameMode.mahjong.core.Constants")
local UtilsFunctions = require("app.game.util.UtilsFunctions")

function UIRuleBoxComponent:ctor(root)

    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    if MultiArea.getIsShowRuleBox(areaId) ~= true then
        self:setVisible(false)
    end

    root:addChild(self)
    self:setPosition(0, 0)

    self._btnRoomRule = UtilsFunctions.seekButton(self, "Button_Room_Rule", handler(self, self._onBtnRoomRuleClick), game.globalConst.StatisticNames.Button_Room_Rule)

    -- 用于回放
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if gameService ~= nil then
        gameService:addEventListener("EVENT_RULE_CHANGE", function(event) self._event = event end, self)
    end
end

function UIRuleBoxComponent:setEnable(tf)
    self._btnRoomRule:setVisible(tf)
end

function UIRuleBoxComponent:_onBtnRoomRuleClick()

    local roomService = game.service.RoomService.getInstance();
    if roomService ~= nil and roomService._roomId ~= 0 then
        UIManager:getInstance():show(
        "UIRuleBox",
        roomService:getRoomSettings(),
        roomService:getHostPlayer():getId(),
        roomService:getHostPlayer():getName(),
        roomService:getHostPlayer():getHeadIconUrl())
    elseif self._event ~= nil then -- in replay 
        local hostInfo = nil
        for _, v in pairs(self._event.players) do
            if bit.band(v.status, Constants.PlayerStatus.HOST) ~= 0 then
                hostInfo = v
                break
            end
        end

        UIManager:getInstance():show(
        "UIRuleBox",
        self._event.roomRule,
        hostInfo.id,
        hostInfo.name,
        hostInfo.headIconUrl)
    end
end

function UIRuleBoxComponent:dispose()
    self:removeFromParent(true)
end

return UIRuleBoxComponent