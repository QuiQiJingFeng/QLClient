local csbPath = "ui/csb/Club/UIClubGroupImportList.csb"
local super = require("app.game.ui.UIBase")

local UIClubGroupImportList = class("UIClubGroupImportList", super, function() return kod.LoadCSBNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    组长的导入列表
]]

function UIClubGroupImportList:ctor()
    self._importClubId = nil
    self._importRoleList = nil
end

function UIClubGroupImportList:init()
    self._textName = seekNodeByName(self, "Text_name", "ccui.Text")
    self._textId = seekNodeByName(self, "Text_id", "ccui.Text")
    self._textplayerCount = seekNodeByName(self, "Text_playerCount", "ccui.Text")
    self._textplayerItle = seekNodeByName(self, "BitmapFontLabel_itle", "ccui.TextBMFont")
    self._panelTips = seekNodeByName(self, "Panel_tips", "ccui.Layout")
    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
    self._textImportPlayerCount = seekNodeByName(self, "Text_importPlayerCount", "ccui.Text")

    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._btnImport = seekNodeByName(self, "Button_import", "ccui.Button")

    self._listClubs = ListFactory.get(
        seekNodeByName(self, "ListView_clubList", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnImport, handler(self, self._onClickImport), ccui.TouchEventType.ended)
end

function UIClubGroupImportList:_onListViewInit(listItem)
    listItem.clubName = seekNodeByName(listItem, "Text_clubName", "ccui.Text")
    listItem.clubId = seekNodeByName(listItem, "Text_clubId", "ccui.Text")
    listItem.clubPlayCount = seekNodeByName(listItem, "Text_clubPlayCount", "ccui.Text")
    listItem.status = seekNodeByName(listItem, "Image_status", "ccui.ImageView")
    listItem.importPlayerCount = seekNodeByName(listItem, "Text_clubImportPlayerCount", "ccui.Text")
end

function UIClubGroupImportList:_onListViewSetData(listItem, data)
    listItem.clubName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.clubName, 12))
    listItem.clubId:setString(data.clubId)
    listItem.clubPlayCount:setString(data.clubMemberCount)
    listItem.status:setVisible(data.isVisible)
    listItem.importPlayerCount:setString(#data.importRoleList)

    bindEventCallBack(listItem, function()
        self:_updateItem(false)
        self._importClubId = data.clubId
        self._importRoleList = data.importRoleList
        self:_updateItem(true)
    end, ccui.TouchEventType.ended)
end

-- 更新item
function UIClubGroupImportList:_updateItem(isVisible)
    local index, item = self:_indexOfItem(self._importClubId, self._importRoleList)
    if index then
        item.isVisible = isVisible
        self._listClubs:updateItem(index, item)
    end
end

function UIClubGroupImportList:onShow(clubId, leagueId)
    self._clubId = clubId or 0
    self._leagueId = leagueId or 0
    self._listClubs:deleteAllItems()
    -- 修改UI名称,防止合并潮汕内蒙是显示不同
    self._textName:setString(string.format("%s名称", config.STRING.COMMON))
    self._textId:setString(string.format("%sID", config.STRING.COMMON))
    self._textplayerCount:setString(string.format("%s人数", config.STRING.COMMON))
    self._textplayerItle:setString(string.format("%s导入", config.STRING.COMMON))
    self._textTips:setString(string.format("只支持从你创建的%s导入\n你暂时没有创建%s", config.STRING.COMMON, config.STRING.COMMON))
    self._textImportPlayerCount:setString(string.format("%s可导入人数", config.STRING.COMMON))


    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener("EVENT_CLUB_GROUP_IMPORT_LIST_INFO", handler(self, self._initClubInfo), self)
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLQueryImportClubInfoREQ(self._clubId, roleId, self._leagueId)
end

function UIClubGroupImportList:_initClubInfo(event)
    self._listClubs:deleteAllItems()
    self._panelTips:setVisible(true)
    if #event.importClubInfos < 1 then
        return
    end
    self._panelTips:setVisible(false)
    for _, data in ipairs(event.importClubInfos) do
        data.isVisible = false
        self._listClubs:pushBackItem(data)
    end
end

-- 获取item数据
function UIClubGroupImportList:_indexOfItem(clubId, importRoleList)
    for idx, item in ipairs(self._listClubs:getItemDatas()) do
        if item.clubId == clubId and item.importRoleList == importRoleList then
            return idx, item
        end
    end

    return false;
end

function UIClubGroupImportList:_onClickClose()
    UIManager:getInstance():destroy("UIClubGroupImportList")
end

function UIClubGroupImportList:_onClickImport()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Group_Import)

    if self._importClubId ~= nil and self._importRoleList ~= nil then
        local groupId =  game.service.club.ClubService.getInstance():getGroupId(self._clubId)
        game.service.club.ClubService.getInstance():getClubGroupService():sendCCLImportGroupMemberREQ(groupId, self._leagueId, self._clubId, self._importClubId, self._importRoleList)
        self:_onClickClose()
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(string.format("请选择你要导入的%s", config.STRING.COMMON))
    end
end

function UIClubGroupImportList:onHide()
    self._listClubs:deleteAllItems()
    self._importClubId = nil
    self._importRoleList = nil
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)
end

function UIClubGroupImportList:needBlackMask()
	return true
end

function UIClubGroupImportList:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubGroupImportList:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubGroupImportList