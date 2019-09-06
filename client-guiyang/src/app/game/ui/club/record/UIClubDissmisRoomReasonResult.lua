local csbPath = "ui/csb/Club/UIClubDissmisRoomReasonResult.csb"
local super = require("app.game.ui.UIBase")

local UIClubDissmisRoomReasonResult = class("UIClubDissmisRoomReasonResult", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    解散房间的结果
]]

local ROOM_DESTROY_REASON =
{
  VOTE = 2, -- 投票解散
  GMT = 4, -- 
  EXCEPTION = 5, -- 发生异常，解散房间
  CLUB_MANAGER_DESTROY = 6, -- 俱乐部经理强制解散
  LEAGUE_DESTROY = 10, -- 联盟强制解散
  LEAGUE_LEADER_DESTROY = 11, --联盟盟主强制解散
  LEAGUE_LOW_MEN_KAN_DESTROY = 14, --联盟分数低于门槛解散 
  TRUSTEESHIP_DESTROY = 15,         -- 托管解散
}

local ROOM_DESTROY_REASON_STR =
{
    [ROOM_DESTROY_REASON.VOTE] = "投票解散",
    [ROOM_DESTROY_REASON.GMT] = "官方解散",
    [ROOM_DESTROY_REASON.EXCEPTION] = "发生异常,解散房间",
    [ROOM_DESTROY_REASON.CLUB_MANAGER_DESTROY] = "经理/管理员强制解散",
    [ROOM_DESTROY_REASON.LEAGUE_DESTROY] = "玩家负分解散",
    [ROOM_DESTROY_REASON.LEAGUE_LOW_MEN_KAN_DESTROY] = "玩家负分解散",
    [ROOM_DESTROY_REASON.LEAGUE_LEADER_DESTROY] = "联盟盟主强制解散",
    [ROOM_DESTROY_REASON.TRUSTEESHIP_DESTROY] = "托管解散",
}

function UIClubDissmisRoomReasonResult:ctor()
end

function UIClubDissmisRoomReasonResult:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._btnOk = seekNodeByName(self, "Button_ok", "ccui.Button")
    self._textPlayInfo = seekNodeByName(self, "Text_playInfo", "ccui.Text")
    self._textReason = seekNodeByName(self, "Text_reason", "ccui.Text")

    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
end

function UIClubDissmisRoomReasonResult:onShow(destroyInfo)
    self:_onRommDestroyInfo(destroyInfo)
end

function UIClubDissmisRoomReasonResult:_onRommDestroyInfo(destroyInfo)
    -- 解散方式
    local season = destroyInfo.destroyReason
    if season ~= ROOM_DESTROY_REASON.LEAGUE_DESTROY and season ~= ROOM_DESTROY_REASON.LEAGUE_LOW_MEN_KAN_DESTROY and season ~= ROOM_DESTROY_REASON.TRUSTEESHIP_DESTROY then
        local info = string.format("%s(%s)%s",
                game.service.club.ClubService.getInstance():getInterceptString(destroyInfo.destroyerName, 8),
                destroyInfo.destroyerId,
                ROOM_DESTROY_REASON_STR[season])
        self._textPlayInfo:setString(info)
    else
        self._textPlayInfo:setString(ROOM_DESTROY_REASON_STR[season])
    end

    -- 解散原因
    if not destroyInfo.destroyDescription then
        self._textReason:setString(ROOM_DESTROY_REASON_STR[season]) 
        return 
    end 
    
    if season == ROOM_DESTROY_REASON.TRUSTEESHIP_DESTROY then 
        self:_onTrustShipReson(destroyInfo)
        return 
    elseif season == ROOM_DESTROY_REASON.LEAGUE_LOW_MEN_KAN_DESTROY then 
        self:_onLeagueLowReson(destroyInfo)
        return 
    end 

    local reason = ""
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local reasonForm = MultiArea.getReasonForm(areaId)
    Macro.assertTrue(#reasonForm == 0, "Dissolution reason configuration table error")

    -- 做一下排序
    local reasons = destroyInfo.destroyDescription.vote_reasons
    table.sort(reasons, function(a, b)
        return a < b
    end)

    for _, v in ipairs(reasons) do
        for _, j in ipairs(reasonForm) do
            if v == j.id then
                reason = reason .. j.name .. "\n"
                break
            end
        end
    end
    if reason == "" then
        reason = ROOM_DESTROY_REASON_STR[destroyInfo.destroyReason]
    end
    self._textReason:setString(reason)
end

-- 托管解散相关
function UIClubDissmisRoomReasonResult:_onTrustShipReson(destroyInfo)
    local season = destroyInfo.destroyReason
    local ruleDatas = destroyInfo.destroyDescription.trusteeship_roles
    if not ruleDatas then 
        self._textReason:setString(ROOM_DESTROY_REASON_STR[season])
        return 
    end 

    local str = ""
    for i, data in pairs(ruleDatas) do 
        str = str .. string.format("玩家:%s(ID:%d),", data.role_name, data.role_id)
    end 
    local reason = string.format("由于%s在本局结束时未取消托管，房间自动解散", str or "玩家")
    self._textReason:setString(reason)
end 

-- 玩家负分解散相关
function UIClubDissmisRoomReasonResult:_onLeagueLowReson(destroyInfo)
    local season = destroyInfo.destroyReason
    local datas = destroyInfo.destroyDescription.losers
    if not datas then 
        self._textReason:setString(ROOM_DESTROY_REASON_STR[season])
        return 
    end 

    local str = ""
    for _, roleId in pairs(datas) do 
        str = str .. string.format("玩家ID:%d ", roleId)
    end 
    local reason = string.format("由于%s负分解散",str)
    self._textReason:setString(reason)
end 

function UIClubDissmisRoomReasonResult:_onCloseClick()
    UIManager:getInstance():destroy("UIClubDissmisRoomReasonResult")
end


function UIClubDissmisRoomReasonResult:onHide()
end

function UIClubDissmisRoomReasonResult:needBlackMask()
	return true
end

function UIClubDissmisRoomReasonResult:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubDissmisRoomReasonResult:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubDissmisRoomReasonResult