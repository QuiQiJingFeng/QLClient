local csbPath = "ui/csb/UIOfflineRoomInfo.csb"
local ScrollText = require("app.game.util.ScrollText")
local room = require("app.game.ui.RoomSettingHelper")

local UIOfflineRoomInfo = class("UIOfflineRoomInfo", function () return cc.CSLoader:createNode(csbPath) end )

function UIOfflineRoomInfo:ctor()
    self._textHomeowner = seekNodeByName(self, "Text_Homeowner", "ccui.Text")
    self._textRoomInfo = seekNodeByName(self, "Text_RoomInfo", "ccui.Text")
    self._textRoomRules = seekNodeByName(self, "Text_RoomRules", "ccui.Text")
    self._panelNode = seekNodeByName(self, "Panel_Node", "ccui.Layout")
end

function UIOfflineRoomInfo:init()

end

function UIOfflineRoomInfo:onShow()
    self._textHomeowner:setString(kod.util.String.getMaxLenString(game.service.LocalPlayerService.getInstance():getName(), 12))
    local roomService = game.service.RoomService:getInstance()
    local clubNmae = ""
    if roomService:getRoomClubId() ~= 0 then
        clubNmae = string.format("%s:%s  ", config.STRING.COMMON, game.service.club.ClubService:getInstance():getInterceptString(game.service.club.ClubService:getInstance():getClubName(roomService:getRoomClubId()), 8))
    end
    self._textRoomInfo:setString(string.format("%s房间ID:%s", clubNmae, roomService:getRoomId()))
    local rules = table.concat(room.RoomSettingHelper.getOptionsDescs(roomService:getRoomSettings()._gameType, roomService:getRoomSettings()._ruleMap[roomService:getRoomSettings()._gameType]), "、");
    self._textRoomRules:setString(rules)
end

function UIOfflineRoomInfo:getSharePannel()
    return self._panelNode
end

function UIOfflineRoomInfo:onHide()

end

--返回界面层级
function UIOfflineRoomInfo:getUILayer()
    return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIOfflineRoomInfo:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIOfflineRoomInfo:needBlackMask()
    return false;
end

--关闭时操作
function UIOfflineRoomInfo:closeWhenClickMask()
    return false
end

-- 标记为Persistent的UI不会destroy
function UIOfflineRoomInfo:isPersistent()
    return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIOfflineRoomInfo:isFullScreen()
    return false;
end

return UIOfflineRoomInfo