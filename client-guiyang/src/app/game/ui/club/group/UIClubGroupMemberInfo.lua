local csbPath = "ui/csb/Club/UIClubGroupMemberInfo.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local M = class("UIClubGroupMemberInfo", super, function() return kod.LoadCSBNode(csbPath) end)

local SORT_ORDER =
{
    positive = 1, -- 正序
    inverted = 2, -- 倒序
}

local TIME_TYPE =
{
    {name = "active_all"},
    {name = "active_today"},
    {name = "active_yesterday"},
    {name = "active_week"},
}

local SORT_TYPE =
{
    {name = "active_identity", sort = 1},
    {name = "active_cardCount", sort = 0},
    {name = "active_winCount", sort = 0},
}

local timeType = {name = "active_all"}

local FILE_TYPE = "playericon"
local _pendingHeadIconTasks = {}

local remoteFileMgr = manager.RemoteFileManager.getInstance()
local function _addLoadingHeadIconTask(imageNode, iconUrl, downloaded)
    imageNode:setTexture("club4/img_frame96.png")
    if iconUrl == nil or iconUrl == "" then
        imageNode.iconUrl = nil
        return
    end
    imageNode.iconUrl = iconUrl
    if downloaded then
        local fileName = remoteFileMgr:getFilePath(FILE_TYPE, iconUrl)
        if cc.FileUtils:getInstance():isFileExist(fileName) then
            table.insert(_pendingHeadIconTasks, { imageNode = imageNode, fileName = fileName, iconUrl = iconUrl })
        else
            imageNode.iconUrl = nil
        end
    else
        remoteFileMgr:getRemoteFile(FILE_TYPE, iconUrl, function(tf, fileType, fileName)            
            if tf then
                local filePath = remoteFileMgr:getFilePath(FILE_TYPE, fileName)
                table.insert(_pendingHeadIconTasks, { imageNode = imageNode, fileName = filePath, iconUrl = iconUrl })
            end
        end)
    end
end

function M:_onListViewInit(listItem)
    listItem._img = seekNodeByName(listItem, "Image_tx_k", "ccui.ImageView")
    listItem._imgHead = seekNodeByName(listItem, "Image_Head", "ccui.ImageView") -- 头像
    listItem._frame = seekNodeByName(listItem, "frame", "ccui.Layout") 
    local spr = cc.Sprite:create()
    local x, y = listItem._imgHead:getPosition()
    listItem._imgHead:removeFromParent()
    listItem._img:addChild(spr, -1)
    spr:setPosition(x, y)
    spr:setScale(0.6)
    listItem._imgHead = spr


    listItem._textName = seekNodeByName(listItem, "Text_Name", "ccui.Text") -- 玩家昵称
    listItem._textId = seekNodeByName(listItem, "Text_Id", "ccui.Text") -- 玩家Id
    listItem._textIdentity = seekNodeByName(listItem, "Text_Identity", "ccui.Text") -- 玩家身份
    listItem._textCardCount = seekNodeByName(listItem, "Text_CardCount", "ccui.Text") -- 牌局数
    listItem._textWinCount = seekNodeByName(listItem, "Text_WinCount", "ccui.Text") -- 大赢家次数
    listItem._btnUntied = seekNodeByName(listItem, "Button_untied", "ccui.Button") -- 解绑按钮
end

function M:_onListViewSetData(listItem, val)
     _addLoadingHeadIconTask(listItem._imgHead, val.roleIcon, val.hasHeadDownload)

    if val.hasHeadDownload == false then 
        val.hasHeadDownload = true
    end

    -- game.util.PlayerHeadIconUtil.setIconFrame(listItem._frame,PropReader.getIconById(val.headFrameId),0.60)

    local name = game.service.club.ClubService.getInstance():getInterceptString(val.roleName, 8)
    listItem._textName:setString(name)
    listItem._textId:setString(val.roleId)
    listItem._textIdentity:setString(val.isLeader and ClubConstant:getClubTitle(ClubConstant:getClubPosition().PARTNER) or ClubConstant:getClubTitle(val.title))
    listItem._btnUntied:setVisible(not val.isLeader)

    -- 全部
    if timeType.name == TIME_TYPE[1].name then
        listItem._textCardCount:setString(val.totalRoomCount)
        listItem._textWinCount:setString(val.totalWinCount)
    -- 今天
    elseif timeType.name == TIME_TYPE[2].name then
        listItem._textCardCount:setString(val.todayRoomCount)
        listItem._textWinCount:setString(val.todayWinCount)
    -- 昨天
    elseif timeType.name == TIME_TYPE[3].name then
        listItem._textCardCount:setString(val.yesterdayRoomCount)
        listItem._textWinCount:setString(val.yesterdayWinCount)
    --七日
    elseif timeType.name == TIME_TYPE[4].name then
        listItem._textCardCount:setString(val.sevenDayRoomCount)
        listItem._textWinCount:setString(val.sevenDayWinCount)
    end

    bindEventCallBack(listItem._btnUntied, function()
        game.service.club.ClubService.getInstance():getClubGroupService():sendCCLModifyGroupMemberREQ(self._clubId, 2, val.roleId, self._groupId)
    end, ccui.TouchEventType.ended)
end

function M:ctor()
    self._checkBoxSort = {}
    self._clubMembers = {}
    self._checkBoxTime = {}
end

function M:init()
    self._btnQuit = seekNodeByName(self, "Button_Quit", "ccui.Button")
    self._btnAddMember = seekNodeByName(self, "Button_add", "ccui.Button")

    self._reusedListMemberInfo = ListFactory.get(
        seekNodeByName(self, "ListView_Group_Member", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListMemberInfo:setScrollBarEnabled(false)
    
    for index, data in ipairs(SORT_TYPE) do
        local node = seekNodeByName(self, "Button_" .. data.name, "ccui.Button")
        self._checkBoxSort[data.name] = node
        if data.name == SORT_TYPE[1].name then
            node:setVisible(false)
        end
    end

    local textureCache = cc.Director:getInstance():getTextureCache()
    self:scheduleUpdateWithPriorityLua(function(dt)
        -- for delay loading texture
        while #_pendingHeadIconTasks > 0 do
            local task = table.remove(_pendingHeadIconTasks)
            local node = task.imageNode
            if node.iconUrl == task.iconUrl and not tolua.isnull(node) then
                node.iconUrl = nil
                textureCache:addImageAsync(task.fileName, function(tex)
                    if tex and not tolua.isnull(node) then
                        node:setTexture(tex)
                    end
                end)
                -- 同帧只进行1次loadTexture
                break 
            end
        end
    end, 0)

    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnAddMember, handler(self, self._onClickAddMember), ccui.TouchEventType.ended)
end

function M:_onClickQuit()
    UIManager:getInstance():show("UIClubGroupMain", self._clubId)
    UIManager:getInstance():hide("UIClubGroupMemberInfo")
end

function M:_onClickAddMember()
    UIManager:getInstance():show("UIClubGroupChoice", self._clubId, "add", self._groupId, self._groupName, function ()
        local clubGroupService = game.service.club.ClubService.getInstance():getClubGroupService()
        clubGroupService:sendCCLQueryGroupMembersREQ(self._clubId, self._groupId, 0, 0)
    end)
end

function M:onShow(clubId, groupId, groupName)
    self._clubId = clubId
    self._groupId = groupId
    self._groupName = groupName
    local clubGroupService = game.service.club.ClubService.getInstance():getClubGroupService()
    clubGroupService:addEventListener("EVENT_CLUB_GROUP_PLAYER_INFO_CHAGE", handler(self, self._initPlayerInfo), self)
    clubGroupService:addEventListener("EVENT_CLUB_GROUP_MEMBER_INFO_CHANGE", handler(self, self._onClubPlayerInfoChange), self)

    clubGroupService:sendCCLQueryGroupMembersREQ(self._clubId, self._groupId, 0, 0)
end

-- 初始化排序UI
function M:_initSort(clubMembers)
    for index, data in ipairs(SORT_TYPE) do
        bindEventCallBack(self._checkBoxSort[data.name], function()
            self:_onClickButton(clubMembers, data, true)
        end, ccui.TouchEventType.ended)
    end
end

function M:_onClickButton(clubMembers, data, isSort)
    -- 修改排序顺序 0 不排序  1为正序 2为倒序
    for k, v in ipairs(SORT_TYPE) do
        local img = seekNodeByName(self._checkBoxSort[v.name], "Image_img", "ccui.ImageView")
        if isSort then
            if v.name == data.name then
                v.sort = (v.sort + 1) % 2 == 0 and SORT_ORDER.inverted or SORT_ORDER.positive
            else
                v.sort = 0
            end
        end

        -- 排序
        if v.name == data.name then
            self:_setMemberSort(clubMembers, v.name, v.sort)
        end
        -- 修改按钮图片显示信息
        img:loadTexture(string.format("club4/btn_fy%d.png", v.sort))
        -- 大赢家的图片需要重新设置一下九宫格信息
        if v.name == SORT_TYPE[3].name then
            img:setCapInsets(cc.rect(14, 14, 25, 47))
        end
    end
end

-- 分类排序
function M:_setMemberSort(clubMembers, sortName, sortType)
    -- 按职位排序
    if sortName == SORT_TYPE[1].name then
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "right", sortType, false)
    -- 牌局数排序
    elseif sortName == SORT_TYPE[2].name then
        -- 全部
        if timeType.name == TIME_TYPE[1].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "totalRoomCount", sortType, false)
        -- 今天
        elseif timeType.name == TIME_TYPE[2].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "todayRoomCount", sortType, false)
        -- 昨天
        elseif timeType.name == TIME_TYPE[3].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "yesterdayRoomCount", sortType, false)
        -- 七日
        elseif timeType.name == TIME_TYPE[4].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevendayRoomCount", sortType, false)
        end
    -- 大赢家排序
    elseif sortName == SORT_TYPE[3].name then
        -- 全部
        if timeType.name == TIME_TYPE[1].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "totalWinCount", sortType, false)
        -- 今天
        elseif timeType.name == TIME_TYPE[2].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "todayWinCount", sortType, false)
        -- 昨天
        elseif timeType.name == TIME_TYPE[3].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "yesterdayWinCount", sortType, false)
        -- 七日
        elseif timeType.name == TIME_TYPE[4].name then
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevendayWinCount", sortType, false)
        end
    end

    -- 清空数据
    self._reusedListMemberInfo:deleteAllItems()

    for _, member in ipairs(clubMembers) do
        self._reusedListMemberInfo:pushBackItem(member)
    end

    if #self._reusedListMemberInfo:getItemDatas() == 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("该时间内成员无牌局")
    end
end

-- 排序函数
function M:_tableSort(loaclTable, type, type2, array, isFilter) 
    -- 筛选成员列表显示该时间内牌局数大于0的用户
    if isFilter then
        local clubMembers = {}
        for _, data in ipairs(loaclTable) do
            if data[type2] ~= 0 then
                table.insert(clubMembers, data)
            end
        end
        loaclTable = clone(clubMembers)
    end

    table.sort(loaclTable, function(a, b)
        -- 第一个类型相同的情况下按第二个类型排序
        if a[type2] == b[type2] then
            return a[type] < b[type]
        end
        -- 正序
        if array == SORT_ORDER.positive then
            return a[type2] > b[type2]
        -- 倒序
        elseif array == SORT_ORDER.inverted then
            return a[type2] < b[type2]
        end
    end)

    return loaclTable
end

function M:_initPlayerInfo(event)
    self._clubMembers = clone(event.playerInfo.memberInfos)
    
    -- 初始化一下玩家数据
    for _, clubMember in ipairs(self._clubMembers) do
        -- 有的图片不是96*96的
        if string.find(clubMember.roleIcon, "/0", -2) then
            clubMember.roleIcon = string.sub(clubMember.roleIcon, 1, -3) .. "/96"
        end
        clubMember.clubId = self._clubId
        clubMember.hasHeadDownload = false
    end

    for index, data in ipairs(TIME_TYPE) do
        local node = seekNodeByName(self, "CheckBox_" .. data.name, "ccui.CheckBox")

        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                self:_onClickCheckBox(self._clubMembers, data)
                game.service.DataEyeService.getInstance():onEvent(data.name)
            elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)

        self._checkBoxTime[data.name] = node
    end

    self:_onClickCheckBox(self._clubMembers, timeType)
end

-- 刷新成员信息
function M:_onClickCheckBox(clubMembers, data)
    for k,v in pairs(self._checkBoxTime) do
        if k == data.name then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    -- 保存一下时间类型
    timeType.name = data.name

    -- 对今日、昨日、七日成员列表显示该时间内牌局数大于0的用户进行筛选
    if timeType.name == TIME_TYPE[2].name then
        -- 今天
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "todayRoomCount", sortType, true)
    elseif timeType.name == TIME_TYPE[3].name then
        -- 昨天
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "yesterdayRoomCount", sortType, true)
    elseif timeType.name == TIME_TYPE[4].name then
        -- 七日
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevendayRoomCount", sortType, true)
    end

    -- 是否有排序
    self:_initSort(clubMembers)
    -- 切换时间时判断当前排序类型
    for k, v in ipairs(SORT_TYPE) do
        if v.sort ~= 0 then
            self:_onClickButton(clubMembers, v, false)
            return
        end
    end
end

function M:_onClubPlayerInfoChange(event)
    if event.opType == 2 then
        local itemIdx, data = self:_indexOfInvitation(event.roleId)
        if Macro.assertFalse(itemIdx ~= false) then
            self._reusedListMemberInfo:deleteItem(itemIdx)
            for i, data in ipairs(self._clubMembers) do
                if data.roleId == event.roleId then
                    table.remove(self._clubMembers, i)
                    return
                end
            end
        end
    end
end

-- 查找item
function M:_indexOfInvitation(roleId)
    for idx,item in ipairs(self._reusedListMemberInfo:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

function M:onHide()
    self._clubMembers = {}
    self._checkBoxTime = {}
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)
end

function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M