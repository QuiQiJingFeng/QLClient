local csbPath = "ui/csb/Mail/UIOperationRecord.csb"
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UIElemRecordItem = class("UIElemRecordItem")
local UIOperationRecord = class("UIOperationRecord", function() return cc.CSLoader:createNode(csbPath) end)
--[[
    管理操作记录页面
]]

local CLUB_ACTIONS = {
    KICK_OFF = 1, -- 踢出亲友圈
    AGREE_APPLICANT = 2, -- 同意申请
    REFUSE_APPLICANT = 3, -- 拒绝申请
    REMOVE_ROOM = 4, -- 解散房间
    MODIFY_CLUB_INFO = 5, -- 修改亲友圈信息
    SEND_NOTICE = 6, -- 发送通知
    MODIFY_MEMBER_TITLE_ASSISANT = 7, -- 成员头衔变动
    MODIFY_PRESET_GAMEPLAY = 25, -- 设置一键开房
    SWITCH_CLUB_FROZEN = 29, -- 冻结亲友圈
    QUIT_CLUB = 35, -- 玩家退出俱乐部
}

function UIElemRecordItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemRecordItem)
    self:_initialize()
    return self
end

function UIElemRecordItem:_initialize()
    self._textTime      = seekNodeByName(self, "Text_xt_1_nr_sr_ClubHis",   "ccui.Text")
    self._textRecord    = seekNodeByName(self, "Text_z_1_nr_sr_ClubHis",    "ccui.Text")
end

function UIElemRecordItem:setData(val)
    if self._data == val then
        return
    end

    self._data = val
    self._textTime:setString(os.date("%Y-%m-%d %H:%M", self._data.timestamp/1000))
    local managerName = game.service.club.ClubService.getInstance():getInterceptString(self._data.name, 8)
    local switch = {
        [CLUB_ACTIONS.KICK_OFF] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_100, ClubConstant:getClubTitle(self._data.title), managerName, game.service.club.ClubService.getInstance():getInterceptString(self._data.content, 8))
        end,
        [CLUB_ACTIONS.AGREE_APPLICANT] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_101,  ClubConstant:getClubTitle(self._data.title), managerName, game.service.club.ClubService.getInstance():getInterceptString(self._data.content, 8))
        end,
        [CLUB_ACTIONS.REFUSE_APPLICANT] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_102,  ClubConstant:getClubTitle(self._data.title), managerName, game.service.club.ClubService.getInstance():getInterceptString(self._data.content, 8))
        end,
        [CLUB_ACTIONS.REMOVE_ROOM] = function()
            return string.format("%s:%s解散了房号为%s的房间",  ClubConstant:getClubTitle(self._data.title), managerName, self._data.content)
        end,
        [CLUB_ACTIONS.MODIFY_CLUB_INFO] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_103,  ClubConstant:getClubTitle(self._data.title), managerName)
        end,
        [CLUB_ACTIONS.SEND_NOTICE] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_104,  ClubConstant:getClubTitle(self._data.title), managerName)
        end,
        [CLUB_ACTIONS.MODIFY_MEMBER_TITLE_ASSISANT] = function()
            local info = json.decode(self._data.content)
            local memberName = game.service.club.ClubService.getInstance():getInterceptString(info.member_name, 8)
            return string.format("%s:%s将玩家%s由%s改为%s", ClubConstant:getClubTitle(self._data.title), managerName, memberName, ClubConstant:getClubTitle(info.old_title), ClubConstant:getClubTitle(info.new_title))
        end,
        [CLUB_ACTIONS.MODIFY_PRESET_GAMEPLAY] = function()
            local info =
            {
                op_type = "",
                index = 0,
            }
            if tonumber(self._data.content) then
                info.op_type = self._data.content
            else
                info = json.decode(self._data.content)
            end
            local str = (tonumber(info.op_type) == ClubConstant:getOperationType().add or tonumber(info.op_type) == ClubConstant:getOperationType().alter) and "设置" or "删除"
            return string.format("%s:%s%s了一键开房玩法%d", ClubConstant:getClubTitle(self._data.title), managerName, str, tonumber(info.index) + 1)
        end,
        [CLUB_ACTIONS.SWITCH_CLUB_FROZEN] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_105,  ClubConstant:getClubTitle(self._data.title), managerName, self._data.content == "true" and "开启" or "解除")
        end,
        [CLUB_ACTIONS.QUIT_CLUB] = function()
            return string.format(config.STRING.UICLUBOPERATIONRECORD_STRING_106,  ClubConstant:getClubTitle(self._data.title), managerName)
        end
    }

    self._textRecord:setString(switch[self._data.type]())
end

function UIOperationRecord:ctor(parent)
    self._parent = parent
    self:setPosition(0, 0)

    self._reusedListRecord = UIItemReusedListView.extend(seekNodeByName(self, "ListView_nr_sr_ClubHis", "ccui.ListView"), UIElemRecordItem) -- 操作记录都list
    self._textPrompt = seekNodeByName(self, "Text_tiao", "ccui.Text") -- 提示框
end

function UIOperationRecord:show()
    self:setVisible(true)
    self._clubId = self._parent:getClubId()
    local clubManagerService = game.service.club.ClubService.getInstance():getClubManagerService()
    clubManagerService:sendCCLQueryOperationRecordREQ(self._clubId)

    clubManagerService:addEventListener("EVENT_CLUB_ADMINISTEATOR_OPERATION_CHANGED",     handler(self, self._onUpdatalubOperationRecord), self)
end

function UIOperationRecord:_onUpdatalubOperationRecord(event)
    if event.clubId ~= self._clubId then
        return
    end

    self._reusedListRecord:deleteAllItems()

    -- 按时间排一次序
    table.sort(event.recordList, function(a, b)
        return a.timestamp > b.timestamp
    end)

    for _, data in ipairs(event.recordList) do
        self._reusedListRecord:pushBackItem(data)
    end

    self._textPrompt:setVisible(not (#event.recordList > 0)) 
end

function UIOperationRecord:hide()
    -- 清空列表
    self._reusedListRecord:deleteAllItems()

    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIOperationRecord
