local csbPath = "ui/csb/Club/UIClubGroupChoice.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")

local UIClubGroupChoice = class("UIClubGroupChoice", super, function() return kod.LoadCSBNode(csbPath) end)


function UIClubGroupChoice:_onListViewInit(listItem)
    listItem.textName = seekNodeByName(listItem, "Text_Name", "ccui.Text") -- 昵称
    listItem.textId = seekNodeByName(listItem, "Text_Id", "ccui.Text") -- id
    listItem.panelFrame = seekNodeByName(listItem, "frame", "ccui.Layout") -- 头像框
    listItem.imgHead = seekNodeByName(listItem, "Image_Head", "ccui.ImageView") -- 头像
    listItem.textStatus = seekNodeByName(listItem, "Text_status", "ccui.Text") -- 状态
    listItem.btnOperating = seekNodeByName(listItem, "Button_operating", "ccui.Button") -- 操作按钮
    listItem.textBtnName = seekNodeByName(listItem, "BitmapFontLabel_btnName", "ccui.TextBMFont") -- 按钮上的文字
end

function UIClubGroupChoice:_onListViewSetData(listItem, data)
    listItem.textId:setString(data.roleId)
    listItem.textName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    game.util.PlayerHeadIconUtil.setIcon(listItem.imgHead, data.roleIcon)
    listItem.textBtnName:setString(self._type == "create" and "设为搭档" or "设为该搭档成员")
    listItem.textBtnName:setScale(self._type == "create" and 1 or 0.8)
    -- game.util.PlayerHeadIconUtil.setIconFrame(listItem.panelFrame, data., 0.60)
    if data.groupId == nil or data.groupId == "" then
        listItem.btnOperating:setVisible(true)
        listItem.textStatus:setVisible(false)
    else
        listItem.btnOperating:setVisible(false)
        listItem.textStatus:setVisible(true)
        if data.isGroupLeader then
            listItem.textStatus:setString("搭档")
        else
            listItem.textStatus:setString(string.format("已绑定%s", data.groupName))
        end
    end
    
    bindEventCallBack(listItem.btnOperating, function()
        if self._type == "create" then
            self._roleId = data.roleId
            UIManager:getInstance():hide("UIClubGroupChoice")
        elseif self._type == "add" then
            game.service.club.ClubService.getInstance():getClubGroupService():sendCCLModifyGroupMemberREQ(self._clubId, 1, data.roleId, self._groupId)
        end
    end, ccui.TouchEventType.ended)
end

function UIClubGroupChoice:ctor()
    self._players = {}
    self._findPlayers = {}
    self._roleId = ""
end

function UIClubGroupChoice:init()
    self._textTitle = seekNodeByName(self, "BitmapFontLabel_title", "ccui.TextBMFont") --标题
    self._inputId = seekNodeByName(self, "TextField_playerId", "ccui.TextField") -- 输入玩家id
    self._btnEmpty = seekNodeByName(self, "Button_empty", "ccui.Button") -- 清空玩家输入的id
    self._btnFind = seekNodeByName(self, "Button_find", "ccui.Button") -- 搜索
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    

    self._listChoicePlayer = ListFactory.get(
        seekNodeByName(self, "ListView_GroupChoice", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEmpty, handler(self, self._onClickEmpty), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFind, handler(self, self._onClickFind), ccui.TouchEventType.ended)
end

function UIClubGroupChoice:_onClickClose()
    UIManager:getInstance():hide("UIClubGroupChoice")
end

function UIClubGroupChoice:_onClickEmpty()
    self._inputId:setString("")
    if #self._findPlayers == 0 then
        return
    end
    self._listChoicePlayer:deleteAllItems()
    for _, playerInfo in ipairs(self._players) do
        self._listChoicePlayer:pushBackItem(playerInfo)
    end
end

function UIClubGroupChoice:_onClickFind()
    local str = self._inputId:getString()
    if str == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入成员昵称或Id")
        return
    end

    self._findPlayers = {}

    for _, data in ipairs(self._players) do
        if string.find(data.roleName, str) ~= nil or string.find(data.roleId, str) then
            table.insert(self._findPlayers, data)
        end
    end

    if #self._findPlayers == 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("未找到该玩家")
        return
    end

    self._listChoicePlayer:deleteAllItems()
    for _, playerInfo in ipairs(self._findPlayers) do
        self._listChoicePlayer:pushBackItem(playerInfo)
    end
end

-- type:表示从那个UI进来的  create  创建   add  添加
function UIClubGroupChoice:onShow(clubId, type, groupId, groupName, fun)
    self._clubId = clubId
    self._type = type
    self._fun = fun
    self._groupId = groupId
    self._groupName = groupName
    self._listChoicePlayer:deleteAllItems()
    self._inputId:setTextColor(cc.c4b(151, 86, 31, 255))
    self._inputId:setString("")

    self._textTitle:setString(self._type == "create" and "选择搭档" or "添加搭档成员")

    local clubGroupService = game.service.club.ClubService.getInstance():getClubGroupService()
    clubGroupService:addEventListener("EVENT_CLUB_GROUP_MEMBER_INFO", handler(self, self._initClubPlayerInfoList), self)
    clubGroupService:addEventListener("EVENT_CLUB_GROUP_MEMBER_INFO_CHANGE", handler(self, self._onClubPlayerInfoChange), self)
    clubGroupService:sendCCLQueryMemberInfosForGroupREQ(self._clubId)
end

function UIClubGroupChoice:_initClubPlayerInfoList(event)
    self._listChoicePlayer:deleteAllItems()
    if event.memberInfos == nil or #event.memberInfos == 0 then
        return
    end

    self._players = event.memberInfos

    for _, playerInfo in ipairs(event.memberInfos) do
        self._listChoicePlayer:pushBackItem(playerInfo)
    end
end

function UIClubGroupChoice:_onClubPlayerInfoChange(event)
    local itemIdx, data = self:_indexOfInvitation(event.roleId)
    if Macro.assertFalse(itemIdx ~= false) then
        data.groupId = event.groupId
        data.groupName = self._groupName
        self._listChoicePlayer:updateItem(itemIdx, data)

        -- 更新本地数据
        for _, player in ipairs(self._players) do
            if player.roleId == event.roleId then
                player.groupId = event.groupId
                player.groupName = self._groupName
                break
            end
        end
    end
end

-- 查找item
function UIClubGroupChoice:_indexOfInvitation(roleId)
    for idx,item in ipairs(self._listChoicePlayer:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

function UIClubGroupChoice:onHide()
    self._fun(self._roleId)
    self._players = {}
    self._findPlayers = {}
    self._roleId = ""
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubGroupChoice:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

function UIClubGroupChoice:needBlackMask()
    return true
end

function UIClubGroupChoice:closeWhenClickMask()
    return false
end

return UIClubGroupChoice