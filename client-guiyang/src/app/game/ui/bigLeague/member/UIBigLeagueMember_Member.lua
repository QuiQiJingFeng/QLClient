local csbPath = "ui/csb/BigLeague/UIBigLeagueMember_Member.csb"
---@class UIBigLeagueMember_Member:UIBase
local UIBigLeagueMember_Member = class("UIBigLeagueMember_Member", function() return cc.CSLoader:createNode(csbPath) end)

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

function UIBigLeagueMember_Member:ctor(parent)
    self._parent = parent


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

function UIBigLeagueMember_Member:_onListViewInit(listView)
    listView.imgHeadNode = seekNodeByName(listView, "Image_HeadNode", "ccui.ImageView")
    listView.imgHead = seekNodeByName(listView, "Image_Head", "ccui.ImageView") -- 头像
    listView.panelFrame = seekNodeByName(listView, "frame", "ccui.Layout") -- 头像框
    listView.textName = seekNodeByName(listView, "Text_Name", "ccui.Text") -- 昵称
    listView.textId = seekNodeByName(listView, "Text_Id", "ccui.Text") -- Id
    listView.textStatus = seekNodeByName(listView, "Text_Status", "ccui.Text") -- 状态
    listView.textScore = seekNodeByName(listView, "Text_Score", "ccui.Text") -- 分数
    --listView.textRemarks = seekNodeByName(listView, "Text_Remarks", "ccui.Text") -- 备注
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

function UIBigLeagueMember_Member:_onListViewSetData(listView, val)
    _addLoadingHeadIconTask(listView.imgHead, val.headUrl, val.hasHeadDownload)
    if val.hasHeadDownload == false then
        val.hasHeadDownload = true
    end

    listView.textName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.nickname))
    listView.textId:setString(val.roleId)
    listView.textScore:setString(math.round(val.gameScore * 100) / 100)
    listView.textEnterCount:setString(val.roomCount)
    listView.textStatus:setString(ClubConstant:getClubTitle(val.title))
    --listView.textRemarks:setString(val.remark)
    listView.imgStatus:loadTexture(ClubConstant:getOnlineStatusIcon("member", val.status))
    game.util.PlayerHeadIconUtil.setIconFrame(listView.panelFrame, PropReader.getIconById(val.headFrameId), 0.6)

    listView.btnAddPoints:setVisible(tonumber(val.gameScore) ~= 0)
    listView.btnMinusPoints:setVisible(tonumber(val.gameScore) ~= 0)

    bindEventCallBack(listView.imgHeadNode, function ()
        UIManager:getInstance():show("UIBigLeagueMemberInfo", val)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnOperating, function()
        -- 根据item的位置改变setting界面显示位置
        local x, y = listView.btnOperating:getPosition()
        local pos = listView.btnOperating:getParent():convertToWorldSpace(cc.p(x, y))
        UIManager:getInstance():show("UIBigLeagueMemberSetting", pos, val, "UIBigLeagueMember_Member")
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnAddPoints, function ()
        self:_setAdjustmentScore(val, "+")
    end, ccui.TouchEventType.ended)
    bindEventCallBack(listView.btnMinusPoints, function ()
        self:_setAdjustmentScore(val, "-")
    end, ccui.TouchEventType.ended)
end

function UIBigLeagueMember_Member:_setAdjustmentScore(data, symbol)
    local str = string.format("参赛分可用%s", math.round(self._bigLeagueService:getLeagueData():getCurrentScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "调整分数", "请输入调整分数", str, true, symbol, function (score)
        self._bigLeagueService:sendCCLModifyMemberScoreREQ(
                self._bigLeagueService:getLeagueData():getLeagueId(),
                self._bigLeagueService:getLeagueData():getClubId(),
                data.roleId,
                self._bigLeagueService:getLeagueData():getModifyMemberScoreType().MODIFY,
                score
        )
    end)
end

function UIBigLeagueMember_Member:updataMemberInfo(roleId)
    if roleId == 0 then
        local isSort = self._parent:getisSort()
        local memberInfo = self._bigLeagueService:getLeagueData():getMemberInfo()
        if isSort then
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

        self:upadtaListViewInfo(memberInfo)
    else
        -- 玩家列表数据更新
        local itemIdx = self:_indexOfApplicationItem(roleId)
        if itemIdx ~= false then
            local member = self._bigLeagueService:getLeagueData():getMemberById(roleId)
            if member == nil then
                self._reusedListMember:deleteItem(itemIdx)
            else
                self._reusedListMember:updateItem(itemIdx, member)
            end
        end
    end
end

function UIBigLeagueMember_Member:_indexOfApplicationItem(roleId)
    for idx,item in ipairs(self._reusedListMember:getItemDatas()) do
        if item.roleId == roleId then
            return idx
        end
    end

    return false;
end

function UIBigLeagueMember_Member:upadtaListViewInfo(memberInfo)
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

function UIBigLeagueMember_Member:show()
    self:setVisible(true)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
end

function UIBigLeagueMember_Member:hide()
    self:setVisible(false)
end

return UIBigLeagueMember_Member