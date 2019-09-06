local csbPath = "ui/csb/Club/UIClubMemberPage_Member.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")

--[[
    成员看见的成员列表
]]
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

local UIClubMemberPage_Member = class("UIClubMemberPage_Member", super, function() return cc.CSLoader:createNode(csbPath) end)

local UIElemMemberItem = class("UIElemMemberItem")

function UIElemMemberItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemMemberItem)
    self:_initialize()
    return self
end

function UIElemMemberItem:_initialize()
    self._img = seekNodeByName(self, "Image_tx_k", "ccui.ImageView")
    self._imgHead = seekNodeByName(self, "Image_Head", "ccui.ImageView") -- 头像
    self._frame = seekNodeByName(self, "frame", "ccui.Layout") 
    local spr = cc.Sprite:create()
    local x, y = self._imgHead:getPosition()
    self._imgHead:removeFromParent()
    self._img:addChild(spr, -1)
    spr:setPosition(x, y)
    spr:setScale(0.6)
    self._imgHead = spr

    self._textName = seekNodeByName(self, "Text_Name", "ccui.Text") -- 玩家昵称
    self._textId = seekNodeByName(self, "Text_Id", "ccui.Text") -- 玩家Id
    self._textIdentity = seekNodeByName(self, "Text_Identity", "ccui.Text") -- 玩家身份
    self._textTodayRoomCount = seekNodeByName(self, "Text_todayRoomCount", "ccui.Text") -- 今日牌局数
    self._textYesterdayRoomCount = seekNodeByName(self, "Text_yesterdayRoomCount", "ccui.Text") -- 昨日牌局数
    self._textSevenDayRoomCount = seekNodeByName(self, "Text_sevenDayRoomCount", "ccui.Text") -- 七日牌局数
    self._panelSearch = seekNodeByName(self, "Panel_search", "ccui.Layout") -- 搜索父节点
    self._imgStatus = seekNodeByName(self, "Image_status", "ccui.ImageView") -- 在线状态
end

function UIElemMemberItem:setData(val)
    self._data = val

     _addLoadingHeadIconTask(self._imgHead, val.roleIcon, val.hasHeadDownload)

    if val.hasHeadDownload == false then 
        val.hasHeadDownload = true
    end

    -- 头像框
    game.util.PlayerHeadIconUtil.setIconFrame(self._frame,PropReader.getIconById(val.headFrameId),0.60)
    
    local name = game.service.club.ClubService.getInstance():getInterceptString(val.roleName, 8)
    self._textName:setString(name)
    self._textId:setString(val.roleId)
    self._textIdentity:setString(val.isLeader and ClubConstant:getClubTitle(ClubConstant:getClubPosition().PARTNER) or ClubConstant:getClubTitle(val.title))

    self._textTodayRoomCount:setString(val.todayRoomCount)
    self._textYesterdayRoomCount:setString(val.yesterdayRoomCount)
    self._textSevenDayRoomCount:setString(val.sevenDayRoomCount)
    local statusIcon = ClubConstant:getOnlineStatusIcon("member", val.status)
    self._imgStatus:loadTexture(statusIcon)

    bindEventCallBack(self._img, function()
        UIManager:getInstance():show("UIClubMemberInfo", self._data, false)
    end, ccui.TouchEventType.ended)
end


function UIClubMemberPage_Member:ctor(parent)
    self._parent = parent
end

function UIClubMemberPage_Member:show()
    self:setVisible(true)

     self._clubId = self._parent.clubId

     self._searchMembers = {}

    self._reusedListManager = UIItemReusedListView.extend(seekNodeByName(self, "ListView_members", "ccui.ListView"), UIElemMemberItem)
    -- 不显示滚动条, 无法在编辑器设置
	self._reusedListManager:setScrollBarEnabled(false)

    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button") -- 邀请
    self._btnSearch = seekNodeByName(self, "Button_search", "ccui.Button") -- 搜索

    self._btnInvite:setVisible(false)
    self._btnSearch:setVisible(false)

    self._panelTimeType = seekNodeByName(self, "Panel_Sortingrules_Memberlist", "ccui.Layout")
    self._panelSearch = seekNodeByName(self, "Panel_search", "ccui.Layout")
    self._beginPosY = self._panelSearch:getPositionY()
    self._panelTimeType:setVisible(true)
    self._panelSearch:setVisible(false)

    self._btnSearch1 = seekNodeByName(self, "Button_search1", "ccui.Button")
    self._textFieldSearch = seekNodeByName(self, "TextField_search", "ccui.TextField") -- 搜索输入框
    self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button") -- 取消

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

-- 玩家列表
function UIClubMemberPage_Member:onClubMemberRetrived(members)
    self._clubMembers = clone(members)

    self._btnInvite:setVisible(true)
    self._btnSearch:setVisible(true)

    self:_updataMember(members)
end

function UIClubMemberPage_Member:_updataMember(members)
    -- 清空数据
    self._reusedListManager:deleteAllItems()
    -- 排序
    table.sort(members, function(a, b)
        -- 在线状态
        if a.status < b.status then
            return true
        elseif a.status > b.status then
            return false
        end
        -- 玩家职位
        if a.memberRight > b.memberRight then
            return true
        elseif a.memberRight < b.memberRight then
            return false
        end
        -- 入会时间
        return a.joinTimestamp < b.joinTimestamp
    end)
    
    for _, member in ipairs(members) do
        -- 有的图片不是96*96的
        if string.find(member.roleIcon, "/0", -2) then
            member.roleIcon = string.sub(member.roleIcon, 1, -3) .. "/96"
        end
        member.clubId = self._clubId
        member.hasHeadDownload = false
        self._reusedListManager:pushBackItem(member)
    end
end

--刷新玩家信息
function UIClubMemberPage_Member:onClubManagerChanged(event)
    local itemIdx, data = self:_indexOfInvitation(event.playerInfo.clubId, event.playerInfo.memberId)
    if Macro.assertFalse(itemIdx ~= false) then
        data.title = event.playerInfo.title
        self._reusedListManager:updateItem(itemIdx, data)
    end
end

-- 玩家被踢
function UIClubMemberPage_Member:onClubMemberChanged(event)
    local itemIdx = self:_indexOfInvitation(event.clubId, event.memberId)
    if Macro.assertFalse(itemIdx ~= false) then
        self._reusedListManager:deleteItem(itemIdx)
    end
end

-- 玩家备注发生变化
function UIClubMemberPage_Member:onClubRemarkChange(event)
    local itemIdx, data = self:_indexOfInvitation(event.clubId, event.roleId)
    if Macro.assertFalse(itemIdx ~= false) then
        data.remark = event.remark
        self._reusedListManager:updateItem(itemIdx, data)
    end
end



-- 查找item
function UIClubMemberPage_Member:_indexOfInvitation(clubId, roleId)
    for idx,item in ipairs(self._reusedListManager:getItemDatas()) do
        if item.clubId == clubId and item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

-- 邀请
function UIClubMemberPage_Member:_onClickClubInvite()
    -- 统计亲友圈成员列表邀请的加号点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Member_Invite);

    -- show邀请界面
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    local idx = clubList:indexOfClub(self._clubId)
    UIManager:getInstance():show("UIClubWeChatInvited", clubList.clubs[idx], true)    
end

-- 搜索
function UIClubMemberPage_Member:_onClickSearch()
    self._panelTimeType:setVisible(false)
    self._panelSearch:setVisible(true)
end

function UIClubMemberPage_Member:_onClickSearch1()
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

    self:_updataMember(self._searchMembers)
end

function UIClubMemberPage_Member:_onClickCancel()
    self._panelTimeType:setVisible(true)
    self._panelSearch:setVisible(false)
    if #self._searchMembers > 0 then
        self:_updataMember(self._clubMembers)
        self._searchMembers = {}
    end
end

function UIClubMemberPage_Member:hide()
    self._searchMembers = {}
    self:setVisible(false)
end


--改变输入框位置
function UIClubMemberPage_Member:_onEventSearch(sender, event)
    local platForm = cc.Application:getInstance():getTargetPlatform()
    if platForm ~= cc.PLATFORM_OS_ANDROID then
        if event == ccui.TextFiledEventType.attach_with_ime then
            self._panelSearch:setPositionY(self._beginPosY + display.height * 0.6)
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            self._panelSearch:setPositionY(self._beginPosY)
        end
    end
end


return UIClubMemberPage_Member