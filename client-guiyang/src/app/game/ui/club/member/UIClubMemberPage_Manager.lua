local csbPath = "ui/csb/Club/UIClubMemberPage_Manager.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIClubMemberPage_Manager = class("UIClubMemberPage_Manager", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    群主看见的成员列表
]]
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

function UIClubMemberPage_Manager:_onListViewInit(listItem)
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
    listItem._textNote = seekNodeByName(listItem, "Text_Note", "ccui.Text") -- 备注
    listItem._btnOp = seekNodeByName(listItem, "Button_Op", "ccui.Button") -- 操作按钮
    listItem._panelSearch = seekNodeByName(listItem, "Panel_search", "ccui.Layout") --搜索框父节点
    listItem._imgStatus = seekNodeByName(listItem, "Image_status", "ccui.ImageView") -- 在线状态
end

function UIClubMemberPage_Manager:_onListViewSetData(listItem, val)
     _addLoadingHeadIconTask(listItem._imgHead, val.roleIcon, val.hasHeadDownload)

    if val.hasHeadDownload == false then 
        val.hasHeadDownload = true
    end

    game.util.PlayerHeadIconUtil.setIconFrame(listItem._frame,PropReader.getIconById(val.headFrameId),0.60)


    local name = game.service.club.ClubService.getInstance():getInterceptString(val.roleName, 8)
    listItem._textName:setString(name)
    listItem._textId:setString(val.roleId)
    listItem._textIdentity:setString(val.isLeader and ClubConstant:getClubTitle(ClubConstant:getClubPosition().PARTNER) or ClubConstant:getClubTitle(val.title))
    local statusIcon = ClubConstant:getOnlineStatusIcon("member", val.status)
    listItem._imgStatus:loadTexture(statusIcon)

    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local club = game.service.club.ClubService.getInstance():getClub(val.clubId)
	if club:isManager(localRoleId) then
        listItem._btnOp:setVisible(val.roleId ~= localRoleId)
    else
        listItem._btnOp:setVisible(val.roleId == localRoleId or (val.title ~= ClubConstant:getClubPosition().MANAFER and val.title ~= ClubConstant:getClubPosition().ASSISTANT))
    end
    
    listItem._textNote:setString(val.remark == "" and "无" or val.remark)

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

    bindEventCallBack(listItem._btnOp, function()
        -- 根据item的位置改变setting界面显示位置
        local x, y = listItem._btnOp:getPosition()
        local pos = listItem._btnOp:getParent():convertToWorldSpace(cc.p(x, y))
        UIManager:getInstance():show("UIClubMemberSetting", val, pos)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listItem._img, function()
        UIManager:getInstance():show("UIClubMemberInfo", val, true)
    end, ccui.TouchEventType.ended)
end

function UIClubMemberPage_Manager:ctor(parent)
    self._parent = parent
end

function UIClubMemberPage_Manager:show()
    self:setVisible(true)
    self._clubId = self._parent.clubId

    self._checkBoxTime = {}

    self._clubMembers = {}

    self._checkBoxSort = {}

    self._searchMembers = {}

    self._reusedListManager = ListFactory.get(
        seekNodeByName(self, "ListView_members", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
	self._reusedListManager:setScrollBarEnabled(false)

    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button") -- 邀请
    self._btnSearch = seekNodeByName(self, "Button_search", "ccui.Button") -- 搜索

    self._panelTimeType = seekNodeByName(self, "Panel_timeType", "ccui.Layout")
    self._panelSearch = seekNodeByName(self, "Panel_search", "ccui.Layout")
    self._beginPosY = self._panelSearch:getPositionY()
    self._panelTimeType:setVisible(true)
    self._panelSearch:setVisible(false)

    self._btnSearch1 = seekNodeByName(self, "Button_search1", "ccui.Button")
    self._textFieldSearch = seekNodeByName(self, "TextField_search", "ccui.TextField") -- 搜索输入框
    self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button") -- 取消

    self._panelDisplay = seekNodeByName(self, "pannel_display", "ccui.Layout")
    self._panelDisplay:setTouchEnabled(false)

    -- self._textIdentity = seekNodeByName(self, "Text_identity", "ccui.Text")
    
    --读取颜色值
	local CList = GainLabelColorUtil.new(self , 1 , 1) 
    -- 设置输入框颜色
    self._textFieldSearch:setPlaceHolderColor(config.ColorConfig.InputField.White.InputHolder)
    self._textFieldSearch:setTextColor(config.ColorConfig.InputField.White.inputTextColor)

    bindEventCallBack(self._btnInvite, handler(self, self._onClickClubInvite), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSearch, handler(self, self._onClickSearch), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSearch1, handler(self, self._onClickSearch1), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    self._textFieldSearch:addEventListener(handler(self, self._onEventSearch))

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
end

-- 初始化排序UI
function UIClubMemberPage_Manager:_initSort(clubMembers)
    for index, data in ipairs(SORT_TYPE) do
        bindEventCallBack(self._checkBoxSort[data.name], function()
            self:_onClickButton(clubMembers, data, true)
        end, ccui.TouchEventType.ended)  
    end
end

function UIClubMemberPage_Manager:_onClickButton(clubMembers, data, isSort)
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
function UIClubMemberPage_Manager:_setMemberSort(clubMembers, sortName, sortType)
    -- 按职位排序
    if sortName == SORT_TYPE[1].name then
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "memberRight", sortType, false)
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
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevenDayRoomCount", sortType, false)
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
            clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevenDayWinCount", sortType, false)
        end
    end

    -- 统计排序次数
    game.service.DataEyeService.getInstance():onEvent(string.format("%s_%s_%d", timeType.name, sortName, sortType))

    -- 清空数据
    self._reusedListManager:deleteAllItems()

    for _, member in ipairs(clubMembers) do
        self._reusedListManager:pushBackItem(member)
    end

    if #self._reusedListManager:getItemDatas() == 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("该时间内成员无牌局")
    end
end

-- 排序函数
function UIClubMemberPage_Manager:_tableSort(loaclTable, type, type2, array, isFilter) 
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
        -- 特殊处理一下，身份时先按在线状态排序
        if type2 == "memberRight" then
            if a.status ~= b.status then
                return a.status < b.status
            end
        end
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

-- 成员信息列表
function UIClubMemberPage_Manager:onClubMemberRetrived(members)
    self._clubMembers = clone(members)
    
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
function UIClubMemberPage_Manager:_onClickCheckBox(clubMembers, data)
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
        clubMembers = self:_tableSort(clubMembers, "joinTimestamp", "sevenDayRoomCount", sortType, true)
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

-- 更新玩家权限
function UIClubMemberPage_Manager:onClubManagerChanged(event)
    local itemIdx, data = self:_indexOfInvitation(event.playerInfo.clubId, event.playerInfo.memberId)
    if Macro.assertFalse(itemIdx ~= false) then
        data.title = event.playerInfo.title
        self._reusedListManager:updateItem(itemIdx, data)
    end
end

-- 删除被踢的玩家
function UIClubMemberPage_Manager:onClubMemberChanged(event)
    local itemIdx = self:_indexOfInvitation(event.clubId, event.memberId)
    if Macro.assertFalse(itemIdx ~= false) then
        self._reusedListManager:deleteItem(itemIdx)
    end
end

-- 玩家备注发生变化
function UIClubMemberPage_Manager:onClubRemarkChange(event)
    local itemIdx, data = self:_indexOfInvitation(event.clubId, event.roleId)
    if Macro.assertFalse(itemIdx ~= false) then
        data.remark = event.remark
        self._reusedListManager:updateItem(itemIdx, data)
    end
end

-- 查找item
function UIClubMemberPage_Manager:_indexOfInvitation(clubId, roleId)
    for idx,item in ipairs(self._reusedListManager:getItemDatas()) do
        if item.clubId == clubId and item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

-- 邀请
function UIClubMemberPage_Manager:_onClickClubInvite()
    -- 统计亲友圈成员列表邀请的加号点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite);

    -- show邀请界面
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    local idx = clubList:indexOfClub(self._clubId)
    UIManager:getInstance():show("UIClubWeChatInvited", clubList.clubs[idx], true)    
end

-- 搜索
function UIClubMemberPage_Manager:_onClickSearch()
    self._textFieldSearch:setPlaceHolderColor(cc.c4b(255, 255, 255, 255))
    self._textFieldSearch:setTextColor(cc.c4b(255, 255, 255, 255))
    
    self._panelTimeType:setVisible(false)
    self._panelSearch:setVisible(true)
end

function UIClubMemberPage_Manager:_onClickSearch1()
    -- 统计亲友圈成员列表【搜索】按钮点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_sousuo);

    local name = self._textFieldSearch:getString()
    if name == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入成员昵称或Id")
        return
    end

    self._searchMembers = {}

    for _, data in ipairs(self._clubMembers) do
        if string.find(data.roleName, name) ~= nil or string.find(data.roleId, name) then
            table.insert(self._searchMembers, data)
        end
    end

    if #self._searchMembers == 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("未找到该玩家")
        return
    end

    self:_onClickCheckBox(self._searchMembers, timeType)
end

function UIClubMemberPage_Manager:_onClickCancel()
    self._panelTimeType:setVisible(true)
    self._panelSearch:setVisible(false)

    if #self._searchMembers > 0 then
        self:_onClickCheckBox(self._clubMembers, timeType)
    end
end

function UIClubMemberPage_Manager:hide()
    self._checkBoxSort = {}
    self._checkBoxTime = {}
    self._searchMembers = {}
    -- 保证每次进来都是按照身份排序
    for i, data in ipairs(SORT_TYPE) do
        data.sort = i == 1 and 1 or 0
    end
    self:setVisible(false)
end

--改变输入框位置
function UIClubMemberPage_Manager:_onEventSearch(sender, event)
    local platForm = cc.Application:getInstance():getTargetPlatform()
    if platForm ~= cc.PLATFORM_OS_ANDROID then
        if event == ccui.TextFiledEventType.attach_with_ime then
            self._panelSearch:setPositionY(self._beginPosY + display.height * 0.5)
            -- 提高一下层级
            self._panelSearch:setLocalZOrder(2)
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            self._panelSearch:setPositionY(self._beginPosY)
            self._panelSearch:setLocalZOrder(0)
        end
    end
end


return UIClubMemberPage_Manager