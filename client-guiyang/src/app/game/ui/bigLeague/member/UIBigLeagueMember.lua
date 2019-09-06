local csbPath = "ui/csb/BigLeague/UIBigLeagueMember.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMember:UIBase
local UIBigLeagueMember = super.buildUIClass("UIBigLeagueMember", csbPath)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local FILE_TYPE = "playericon"
local _pendingHeadIconTasks = {}

-- 防止头像下载失败，一直下载，造成卡顿
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

--[[
    俱乐部成员界面
        目前只有B显示，用于管理俱乐部成员
]]

function UIBigLeagueMember:ctor()

end

function UIBigLeagueMember:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

    self._textPeoples = seekNodeByName(self, "TextBMFont_Peoples", "ccui.TextBMFont")
    self._textPeoples:setVisible(false)
    self._panelTime = seekNodeByName(self, "Panel_Time", "ccui.Layout")

    self._btnSearch = seekNodeByName(self, "Button_search", "ccui.Button")
    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button")
    self._btnAdd = seekNodeByName(self, "Button_add", "ccui.Button")

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSearch, handler(self, self._onClickSearch), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite, handler(self, self._onClickInvite), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnAdd, handler(self, self._onClickAdd), ccui.TouchEventType.ended)

    self._btnAll = seekNodeByName(self, "CheckBox_All", "ccui.CheckBox")
    self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox")
    self._btnThreeDays = seekNodeByName(self, "CheckBox_ThreeDays", "ccui.CheckBox")
    self._btnSevenDays = seekNodeByName(self, "CheckBox_SevenDays", "ccui.CheckBox")
    local tbChkBox = {self._btnAll, self._btnToday, self._btnThreeDays, self._btnSevenDays}

    local isSelected = false
    local pFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if sender:getName() == "CheckBox_Today" then 
                self._isSort = true
                self:_sendCCLQueryMembersREQ(1)
            elseif sender:getName() == "CheckBox_ThreeDays" then 
                self._isSort = true
                self:_sendCCLQueryMembersREQ(3)
            elseif sender:getName() == "CheckBox_SevenDays" then 
                self._isSort = true
                self:_sendCCLQueryMembersREQ(7)
            elseif sender:getName() == "CheckBox_All" then 
                self._isSort = false
                self:_sendCCLQueryMembersREQ(0)
            end

            for _,btn in ipairs(tbChkBox) do 
                btn:setSelected(sender == btn)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end

    self._btnAll:addTouchEventListener(pFunc)
    self._btnToday:addTouchEventListener(pFunc)
    self._btnThreeDays:addTouchEventListener(pFunc)
    self._btnSevenDays:addTouchEventListener(pFunc)

    self._reusedListMember = ListFactory.get(
        seekNodeByName(self, "ListView_Member", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListMember:setScrollBarEnabled(false)

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

function UIBigLeagueMember:_sendCCLQueryMembersREQ(days)
    self._bigLeagueService:sendCCLQueryMembersREQ(
            self._bigLeagueService:getLeagueData():getLeagueId(),
            self._bigLeagueService:getLeagueData():getClubId(),
            days,
            self._memberType,
            self._bigLeagueService:getLeagueData():getTitle(),
            self._roleId
    )
end

function UIBigLeagueMember:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueMember:_onListViewInit(listView)
    listView.imgHeadNode = seekNodeByName(listView, "Image_HeadNode", "ccui.ImageView")
    listView.imgHead = seekNodeByName(listView, "Image_Head", "ccui.ImageView") -- 头像
    listView.panelFrame = seekNodeByName(listView, "frame", "ccui.Layout") -- 头像框
    listView.textName = seekNodeByName(listView, "Text_Name", "ccui.Text") -- 昵称
    listView.textId = seekNodeByName(listView, "Text_Id", "ccui.Text") -- Id
    listView.textStatus = seekNodeByName(listView, "Text_Status", "ccui.Text") -- 状态
    listView.textScore = seekNodeByName(listView, "Text_Score", "ccui.Text") -- 分数
    listView.textRemarks = seekNodeByName(listView, "Text_Remarks", "ccui.Text") -- 备注
    listView.btnOperating = seekNodeByName(listView, "Button_Operating", "ccui.Button") -- 操作
    listView.imgStatus = seekNodeByName(listView, "Image_status", "ccui.ImageView") -- 在线状态
    listView.textEnterCount = seekNodeByName(listView, "Text_EnterCount", "ccui.Text") -- 参赛场数
    listView.btnAddPoints = seekNodeByName(listView, "Button_AddPoints", "ccui.Button") -- 加分
    listView.btnMinusPoints = seekNodeByName(listView, "Button_MinusPoints", "ccui.Button") -- 减分

    local spr = cc.Sprite:create()
    local x, y = listView.imgHead:getPosition()
    listView.imgHead:removeFromParent()
    listView.imgHeadNode:addChild(spr, -1)
    spr:setPosition(x, y)
    spr:setScale(0.65)
    listView.imgHead = spr

end

function UIBigLeagueMember:_onListViewSetData(listView, val)
    _addLoadingHeadIconTask(listView.imgHead, val.headUrl, val.hasHeadDownload)
    if val.hasHeadDownload == false then
        val.hasHeadDownload = true
    end

    listView.textName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.nickname))
    listView.textId:setString(val.roleId)
    listView.textScore:setString(math.round(val.gameScore * 100) / 100)
    listView.textEnterCount:setString(val.roomCount)
    listView.textStatus:setString(ClubConstant:getClubTitle(val.title))
    listView.textRemarks:setString(val.remark)
    listView.imgStatus:loadTexture(ClubConstant:getOnlineStatusIcon("member", val.status))
    game.util.PlayerHeadIconUtil.setIconFrame(listView.panelFrame, PropReader.getIconById(val.headFrameId), 0.6)

    listView.btnAddPoints:setVisible(tonumber(val.gameScore) ~= 0)
    listView.btnMinusPoints:setVisible(tonumber(val.gameScore) ~= 0)

    bindEventCallBack(listView.imgHeadNode, function ()
        UIManager:getInstance():show("UIBigLeagueMemberInfo", val)
    end, ccui.TouchEventType.ended)

    listView.btnOperating:setVisible(not self._bigLeagueService:getLeagueData():isManager() or self._memberType == self._bigLeagueService:getLeagueData():getMemberType().MEMBER)

    bindEventCallBack(listView.btnOperating, function()
        -- 根据item的位置改变setting界面显示位置
        local x, y = listView.btnOperating:getPosition()
        local pos = listView.btnOperating:getParent():convertToWorldSpace(cc.p(x, y))
        UIManager:getInstance():show("UIBigLeagueMemberSetting", pos, val, self._bigLeagueService:getLeagueData():isPartner() and "UIBigLeagueMember" or "UIBigLeagueMember_Member")
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnAddPoints, function ()
        self:_setAdjustmentScore(val, "+")
    end, ccui.TouchEventType.ended)
    bindEventCallBack(listView.btnMinusPoints, function ()
        self:_setAdjustmentScore(val, "-")
    end, ccui.TouchEventType.ended)
end

function UIBigLeagueMember:_setAdjustmentScore(data, symbol)
    local str = string.format("参赛分可用%s", math.round(self._bigLeagueService:getLeagueData():getCurrentScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "调整分数", "请输入调整分数", str, true, symbol, function (score)
        if self._memberType == self._bigLeagueService:getLeagueData():getMemberType().MEMBER then
            self._bigLeagueService:sendCCLModifyMemberScoreREQ(
                    self._bigLeagueService:getLeagueData():getLeagueId(),
                    self._bigLeagueService:getLeagueData():getClubId(),
                    data.roleId,
                    self._bigLeagueService:getLeagueData():getModifyMemberScoreType().MODIFY,
                    score
            )
        else
            self._bigLeagueService:sendCCLModifyPartnerScoreREQ(
                    self._bigLeagueService:getLeagueData():getLeagueId(),
                    self._bigLeagueService:getLeagueData():getClubId(),
                    data.roleId,
                    self._memberType - 1, -- 类型（1:经理给搭档调整，2：搭档给搭档成员调整）
                    score
            )
        end
    end)
end

function UIBigLeagueMember:onShow(roleId, memberType)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._isSort = false
    self._roleId = roleId or 0
    self._memberType = memberType or self._bigLeagueService:getLeagueData():getMemberType().MEMBER
    -- 当在该界面设置搭档后，就变成新的成员的界面
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_INFO_SYN", function ()
        if self._bigLeagueService:getLeagueData():getPartnerNumber() > 0 then
            UIManager:getInstance():show("UIBigLeagueMemberManager", 2)
            self:hideSelf()
        end
    end, self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_MEMBER", handler(self, self._upadtaListView), self)

    self:_sendCCLQueryMembersREQ(0)
    local tbChkBox = {self._btnAll, self._btnToday, self._btnThreeDays, self._btnSevenDays}
    for _,btn in ipairs(tbChkBox) do
        btn:setSelected(btn == self._btnAll)
    end

     self._bigLeagueService:addEventListener("EVENT_LEAGUE_PARTNER", function ()
         self:_sendCCLQueryMembersREQ(0)
     end, self)

     self._btnInvite:setVisible(false)
    self._btnAdd:setVisible(self._bigLeagueService:getLeagueData():isPartner())
    self._panelTime:setVisible(not self._bigLeagueService:getLeagueData():isPartner())
end

function UIBigLeagueMember:_upadtaListView(event)
    if event.roleId == 0 then
        local memberInfo = self._bigLeagueService:getLeagueData():getMemberInfo()
        if self._isSort then
            table.sort(memberInfo, function (a, b)
                if a.roomCount == b.roomCount then
                    if a.status == b.status then
                        if  ClubConstant:getClubTitleSort(a.title) == ClubConstant:getClubTitleSort(b.title) then
                            return a.joinClubTime < b.joinClubTime
                        end
                        return ClubConstant:getClubTitleSort(a.title) > ClubConstant:getClubTitleSort(b.title)
                    end
                    return a.status < b.status
                end
                return a.roomCount > b.roomCount
            end)
        end

        self:_upadtaListViewInfo(memberInfo)
    else
        -- 玩家列表数据更新
        local itemIdx = self:_indexOfApplicationItem(event.roleId)
        if itemIdx ~= false then
            local member = self._bigLeagueService:getLeagueData():getMemberById(event.roleId)
            if member == nil then
                self._reusedListMember:deleteItem(itemIdx)
            else
                self._reusedListMember:updateItem(itemIdx, member)
            end
        end
    end
end

function UIBigLeagueMember:_upadtaListViewInfo(memberInfo)
    self._reusedListMember:deleteAllItems()
    for _, member in ipairs(memberInfo) do
        member.hasHeadDownload = false
        -- 有时候服务器发的头像url没有设置大小，造成客户端下载图片过大，造成卡顿
        if string.find(member.headUrl, "/0", -2) then
            member.headUrl = string.sub(member.headUrl, 1, -3) .. "/96"
        end
        self._reusedListMember:pushBackItem(member)
    end
end

-- 查找item
function UIBigLeagueMember:_indexOfApplicationItem(roleId)
    for idx,item in ipairs(self._reusedListMember:getItemDatas()) do
        if item.roleId == roleId then
            return idx
        end
    end

    return false;
end

function UIBigLeagueMember:_onClickSearch()
    UIManager:getInstance():show("UIBigLeagueMemberFind", function (playerInfo)
        if playerInfo == "" then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入成员昵称或Id")
            return
        end

        local searchMembers = {}
        for _, data in ipairs(self._bigLeagueService:getLeagueData():getMemberInfo()) do
            if string.find(data.nickname, playerInfo) ~= nil or string.find(data.roleId, playerInfo) then
                table.insert(searchMembers, data)
            end
        end
        if #searchMembers == 0 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("未找到该玩家")
            return
        end
        self:_upadtaListViewInfo(searchMembers)
        UIManager:getInstance():destroy("UIBigLeagueMemberFind")
    end)
end

function UIBigLeagueMember:_onClickInvite()
end

function UIBigLeagueMember:_onClickAdd()
    UIManager:getInstance():show("UIBigLeaguePartnerInvite")
end

function UIBigLeagueMember:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_UPDATA_MEMBER_INFO"})
end

return UIBigLeagueMember