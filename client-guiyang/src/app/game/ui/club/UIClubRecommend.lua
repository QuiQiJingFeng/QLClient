local csbPath = "ui/csb/Club/UIClubRecommend.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    新玩家推荐
        邀请玩家加入亲友圈
]]

local RECOMMEND_STATUS = 
{
    {"新玩家", ClubConstant:getClubQueryRecommandType().RECOMMANDED, "click_club_recommend_manager_newPlayer"},
    {"已邀请", ClubConstant:getClubQueryRecommandType().INVITED, "click_club_recommend_manager_invited"},
    {"已接受", ClubConstant:getClubQueryRecommandType().ACCEPTTED, "click_club_recommend_manager_received"},
}

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemClubRecommendPlayerItem = class("UIElemClubRecommendPlayerItem")

function UIElemClubRecommendPlayerItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemClubRecommendPlayerItem)
    self:_initialize()
    return self
end

function UIElemClubRecommendPlayerItem:_initialize()
    self:setAnchorPoint(0, 0)
    self._textPlayName = seekNodeByName(self, "Text_name", "ccui.Text") -- 玩家名字
    self._textNumber_Card = seekNodeByName(self, "Text_end_time_jushu", "ccui.Text") -- 牌局数
    self._textLogo = seekNodeByName(self, "Text_word", "ccui.Text") -- 标识语
    self._textAbnormalRate = seekNodeByName(self, "Text_end_yichang", "ccui.Text") -- 玩家异常率
    self._textCreateTime = seekNodeByName(self, "Text_end_time_1", "ccui.Text") -- 玩家注册时间
    self._textStatus = seekNodeByName(self, "Text_InvitedTime", "ccui.Text") -- 状态
    self._imgHead = seekNodeByName(self, "Image_Newplayer", "ccui.ImageView") -- 玩家头像
    self._btnInvition = seekNodeByName(self, "Button_Invition", "ccui.Button") -- 邀请
    self._imgLogo = seekNodeByName(self, "Image_12", "ccui.ImageView") -- 标识语背景
    self._imgAccept = seekNodeByName(self, "Image_yyq", "ccui.ImageView") -- 接受邀请标识
    self._imgInvite = seekNodeByName(self, "Image_jsyq", "ccui.ImageView") -- 已邀请标识
end

function UIElemClubRecommendPlayerItem:setData(val)
    if self._data == val then
        return
    end

    self._data = val

    self._textPlayName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.roleName, 8))
    self._textNumber_Card:setString(string.format("今日/七日牌局数:%d/%d", val.todayRoomCount, val.sevenDayRoomCount))

    local logo = string.format(config.STRING.UICLUBRECOMMEND_STRING_100, val.cardFriends[1], #val.cardFriends > 1 and string.format("等%d人", #val.cardFriends) or "")
    -- self._textLogo:setString(val.releaseMsg)
    self._textLogo:setString(logo)

    self._textAbnormalRate:setString(string.format("牌局解散率:%d%%", val.abnormalRate * 100))
    self._textCreateTime:setString(string.format("注册时间:%s", os.date("%Y-%m-%d", val.registerTime/1000)))

    -- 有的图片不是96*96的
    if string.find(val.roleIcon, "/0", -2) then
        val.roleIcon = string.sub(val.roleIcon, 1, -3) .. "/96"
    end

    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, val.roleIcon);
    
    self._imgLogo:setVisible(val.opType == RECOMMEND_STATUS[1][2])
    -- 新玩家数据显示邀请按钮
    self._btnInvition:setVisible(val.opType == RECOMMEND_STATUS[1][2])
    -- 更改状态
    local textContent = ""
    self._imgAccept:setVisible(false)
    self._imgInvite:setVisible(false)
    if val.opType == RECOMMEND_STATUS[2][2] then
        textContent = os.date("%Y-%m-%d\n%H:%M", val.invitedTime/1000)
        self._imgInvite:setVisible(true)
    elseif val.opType == RECOMMEND_STATUS[3][2] then
        textContent = os.date("%Y-%m-%d\n%H:%M", val.processedTime/1000)
        self._imgAccept:setVisible(true)
    end

    self._textStatus:setString(textContent)
    self._textStatus:setVisible(val.opType ~= RECOMMEND_STATUS[1][2])

    bindEventCallBack(self._btnInvition, function()
        -- 统计群主点击“邀请”
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_manager_invite)
        self:_onClickInvition(val)
    end, ccui.TouchEventType.ended)
end

-- 邀请加入亲友圈
function UIElemClubRecommendPlayerItem:_onClickInvition(palyerInfo)
    UIManager:getInstance():show("UIClubEnterPlayerInfo", palyerInfo)
end


local UIClubRecommend = class("UIClubRecommend", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRecommend:ctor()
    self._btnQuit = nil -- 退出
    self._listRecommendType = nil -- 推荐玩家类型
    self._reusedListClubRecommend = nil -- 推荐玩家列表
    self._textSuccess = nil -- 成功邀请的人数
    self._saveRecommendType = nil -- 保存当前显示的类型

    self._maxInvitedTimes = 5 -- 保存每日最大邀请次数

    self._btnHelp = nil -- 帮助
end

function UIClubRecommend:init()
    self._btnQuit = seekNodeByName(self, "Button_x_ClubCL", "ccui.Button")
    self._textSuccess = seekNodeByName(self, "Text_Notes", "ccui.Text")
    self._btnHelp = seekNodeByName(self, "Button_help", "ccui.Button")

    self._reusedListClubRecommend = UIItemReusedListView.extend(seekNodeByName(self, "ListView_word_Newplayer", "ccui.ListView"), UIElemClubRecommendPlayerItem)    
     -- 不显示滚动条, 无法在编辑器设置
    self._reusedListClubRecommend:setScrollBarEnabled(false)
    

    self._listRecommendType = seekNodeByName(self, "ListView_Game_Newplayer", "ccui.ListView")
    self._listRecommendType:setScrollBarEnabled(false)
	self._listRecommendType:setTouchEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listRecommendType, "GAME_TYPE_BUTTON")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onBtnHelp), ccui.TouchEventType.ended)
end

function UIClubRecommend:onShow(clubId)
    self._clubId = clubId
    self:_initListView()

    local clubManagerService = game.service.club.ClubService.getInstance():getClubManagerService()
    local clubMemberService = game.service.club.ClubService.getInstance():getClubMemberService()
    clubManagerService:addEventListener("EVENT_CLUB_RECOMMEND_PLAYER_INFO", handler(self, self._initRecommendPlayerList), self)
    clubMemberService:addEventListener("EVENT_CLUB_RECOMMEND_INVITATION_CHANGED", handler(self, self._initRecommendPlayerChanged), self)

    -- 判断是否是要弹帮助的框
    local playerData = game.service.club.ClubService.getInstance():loadLocalStoragePlayerInfo()
    local playerInfo = playerData:getClubInfo(self._clubId)
    if playerInfo.isRecommend == nil or playerInfo.isRecommend then
        UIManager:getInstance():show("UIClubRecommend_Help")
        playerInfo.isRecommend = false
        game.service.club.ClubService.getInstance():saveLocalStoragePlayerInfo(playerData)
    end
end

function UIClubRecommend:_initListView()
    -- 清空列表
    self._listRecommendType:removeAllChildren()

    self._btnCheckList = {}

    for i = 1, #RECOMMEND_STATUS do
        local node = self._listviewItemBig:clone()
		self._listRecommendType:addChild(node)
		node:setVisible(true)

        -- 显示功能名字
        local textType = ccui.Helper:seekNodeByName(node, "GAME_TYPE_BUTTON_TXT")
        textType:setString(RECOMMEND_STATUS[i][1])

        local isSelected = false
        node:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = node:isSelected()
			elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then	
				self:_onItemTypeClicked(RECOMMEND_STATUS[i])
                -- 统计item点击次数
                game.service.DataEyeService.getInstance():onEvent(RECOMMEND_STATUS[i][3])
				node:setSelected(true)
          	elseif eventType == ccui.TouchEventType.canceled then
                node:setSelected(isSelected)
            end
        end)

        self._btnCheckList[RECOMMEND_STATUS[i][2]] = node
    end

    -- 默认显示第一个
    self:_onItemTypeClicked(RECOMMEND_STATUS[1])
end

function UIClubRecommend:_onItemTypeClicked(recommendStatus)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == recommendStatus[2] then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local managerId = game.service.club.ClubService.getInstance():getClubManagerId(self._clubId)
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLQueryRecommendPlayerListREQ(areaId, self._clubId, recommendStatus[2], managerId)
end

function UIClubRecommend:_initRecommendPlayerList(event)
    if event.recommendPlayerInfo.clubId ~= self._clubId then
        return
    end
    -- 清空列表
    self._reusedListClubRecommend:deleteAllItems()

    self._maxInvitedTimes = event.recommendPlayerInfo.maxInvitedTimes

    local text = ""
    if event.recommendPlayerInfo.opType == RECOMMEND_STATUS[1][2] then
        text = string.format("今日邀请次数:%d/%d", event.recommendPlayerInfo.todayInvitedTimes, event.recommendPlayerInfo.maxInvitedTimes)
        -- 排序：按照低展示次数优先，高展示次数靠后，展示次数相同历史牌局数多的靠前的顺序进行排列
        table.sort(event.recommendPlayerInfo.recommandInfos, function(a, b)
            if a.checkTimes == b.checkTimes then
                return a.sevenDayRoomCount > b.sevenDayRoomCount
            end
            
            return a.checkTimes < b.checkTimes
        end)
    elseif event.recommendPlayerInfo.opType == RECOMMEND_STATUS[2][2] then
        text = string.format("未处理邀请:%d", event.recommendPlayerInfo.unprocessedCount)
        -- 排序：按邀请时间先后顺序排
        table.sort(event.recommendPlayerInfo.recommandInfos, function(a, b)
            return a.invitedTime > b.invitedTime
        end)
    elseif event.recommendPlayerInfo.opType == RECOMMEND_STATUS[3][2] then
        text = string.format("今日成功邀请玩家:%d/%d", event.recommendPlayerInfo.todayAcceptTimes, event.recommendPlayerInfo.maxInvitedTimes)
        -- 排序：按接受时间先后顺序排
        table.sort(event.recommendPlayerInfo.recommandInfos, function(a, b)
            return a.processedTime > b.processedTime
        end)
    end
    self._textSuccess:setString(text)

    self._saveRecommendType = event.recommendPlayerInfo.opType

    for idx, playerInfo in ipairs(event.recommendPlayerInfo.recommandInfos) do
        playerInfo.opType = event.recommendPlayerInfo.opType
        playerInfo.clubId = event.recommendPlayerInfo.clubId
        self._reusedListClubRecommend:pushBackItem(playerInfo)
    end
end

function UIClubRecommend:_initRecommendPlayerChanged(event)
    -- 当前类型不是返回类型
    if event.clubId ~= self._clubId or self._saveRecommendType ~= RECOMMEND_STATUS[1][2] then
        return
    end
    
    -- 刷新邀请次数
    self._textSuccess:setString(string.format("今日邀请次数:%d/%d", event.todayInvitedTimes, self._maxInvitedTimes))

    local itemIdx = self:_indexOfInvitation(event.clubId, event.inviterId)
    -- 删除数据        
    if Macro.assertFalse(itemIdx ~= false) then
        self._reusedListClubRecommend:deleteItem(itemIdx)
    end
end

-- 查找item
function UIClubRecommend:_indexOfInvitation(clubId, inviterId)
    for idx,item in ipairs(self._reusedListClubRecommend:getItemDatas()) do
        if item.clubId == clubId and item.roleId == inviterId then
            return idx
        end
    end

    return false;
end


function UIClubRecommend:_onBtnQuit()
    UIManager:getInstance():hide("UIClubRecommend")
end
function UIClubRecommend:onHide()
    -- 清空列表
    self._listRecommendType:removeAllChildren()
    self._reusedListClubRecommend:deleteAllItems()

    self._btnCheckList = {}
    game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

function UIClubRecommend:_onBtnHelp()
    -- 统计群主点击“邀请”
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_manager_introduction)

    UIManager:getInstance():show("UIClubRecommend_Help")
end

function UIClubRecommend:needBlackMask()
	return true
end

function UIClubRecommend:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRecommend:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRecommend
