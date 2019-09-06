local seekButton = require("app.game.util.UtilsFunctions").seekButton
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local csbPath = "ui/csb/Club/UIClubRoom.csb"
local super = require("app.game.ui.UIBase")
local room = require("app.game.ui.RoomSettingHelper")
local Constants = require("app.gameMode.mahjong.core.Constants")
local UI_ANIM = require("app.manager.UIAnimManager")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local UIClubRoomBtnClick = require("app.game.ui.club.room.UIClubRoomBtnClick")

--[[
    亲友圈牌局界面
]]
local ITEM_COUNT = 3
local DEFAULT_ICON = "club4/img_frame0.png"
local DEFAULT_ICON = "club/img_tableplayer1_club.png"
local FILE_TYPE = "playericon"
local _pendingHeadIconTasks = {}

local RoomColor = {
    {r = 255, g = 255, b = 255},     -- 未开局（白色）
    {r = 0, g = 255, b = 235},     -- 提前开局（蓝色）
    {r = 78, g = 191, b = 223},       -- 已满（红色）
}

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

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemRoomItem = class("UIElemRoomItem")

function UIElemRoomItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemRoomItem)
    self:_initialize()
    return self
end

function UIElemRoomItem:_initialize()
    local panelItem = seekNodeByName(self, "Panel_7", "ccui.Layout")
    self._objItem = bindNodeToTarget(panelItem)

    local createRoom = seekNodeByName(self, "Panel_0_Clubpj", "ccui.Layout")
    self._itemCreateRoom = bindNodeToTarget(createRoom)

    self._itemCardRooms = {}
    for i = 1, 3 do
        local cardRoom = seekNodeByName(self, "Panel_" .. i .."_Clubpj", "ccui.Layout")
        self._itemCardRooms[i] = bindNodeToTarget(cardRoom)
        for ii = 1, 4 do
            local imageview = self._itemCardRooms[i]["Image_face_player" .. ii .. "_1_Clubpj"]
            local spr = cc.Sprite:create()
            local x, y = imageview:getPosition()
            imageview:removeFromParent()
            self._itemCardRooms[i]["Panel_player" .. ii .. "_1_Clubpj"]:addChild(spr, -1)
            spr:setPosition(x, y)
            --spr:setScale(0.7)
            self._itemCardRooms[i]["Image_face_player" .. ii .. "_1_Clubpj"] = spr
        end
        --
    end
end

function UIElemRoomItem:setData(val)
     -- 创建房间的item默认不显示
     self._objItem["Panel_0_Clubpj"]:setVisible(false)

     for i, roomInfo in ipairs(val) do
        if roomInfo.type == "add" then
            self._objItem["Panel_1_Clubpj"]:setVisible(false)
            self._objItem["Panel_0_Clubpj"]:setVisible(true)
            self._itemCreateRoom.Image_frozen:setVisible(false)
            bindEventCallBack(self._itemCreateRoom.Button_an_0_Clubpj, function () self:_onClickCreateRoom(roomInfo) end, ccui.TouchEventType.ended)
        else
            self._objItem["Panel_" .. i .. "_Clubpj"]:setVisible(true)
            self:_updataItemData(self._objItem["Panel_" .. i .. "_Clubpj"], self._itemCardRooms[i], roomInfo)
        end
     end

     -- 隐藏多余的item
     for i = 1, ITEM_COUNT do
        if i > #val then
            self._objItem["Panel_" .. i .. "_Clubpj"]:setVisible(false)
        end
     end
end

-- 更新数据
function UIElemRoomItem:_updataItemData(node, itemCardRooms, data)
    for i = 1, 4 do
        if i <= data.playerMax then
            itemCardRooms["Panel_player" .. i .."_1_Clubpj"]:setVisible(true)           -- 默认显示头像
            itemCardRooms["Image_black_player" .. i .. "_1_Clubpj"]:setVisible(false)   -- 蒙灰
            itemCardRooms["Button_djgz_player" .. i .. "_1_Clubpj"]:setVisible(false)   -- 观战
            itemCardRooms["Button_djjr_player" .. i .. "_1_Clubpj"]:setVisible(false)   -- 加入
            itemCardRooms["Image_ddz_player" .. i .. "_1_Clubpj"]:setVisible(false)     -- 等待中

            -- 注册观战事件
            bindEventCallBack(itemCardRooms["Button_djgz_player" .. i .. "_1_Clubpj"], function()
                self:_onClickWatching(data.roomId)
            end, ccui.TouchEventType.ended)
            -- 注册加入事件
            bindEventCallBack(itemCardRooms["Button_djjr_player" .. i .. "_1_Clubpj"], function()
                self:_onClickJoin(data)
            end, ccui.TouchEventType.ended)

            if i <= #data.players then
                -- 有的图片不是96*96的
                if string.find(data.players[i].head, "/0", -2) then
                    data.players[i].head = string.sub(data.players[i].head, 1, -3) .. "/96"
                end
                itemCardRooms["Image_face_player" .. i .. "_1_Clubpj"]:setScale(0.7)
                 _addLoadingHeadIconTask(itemCardRooms["Image_face_player" .. i .. "_1_Clubpj"], data.players[i].head, data.hasHeadDownload)
                if data.hasHeadDownload == false then 
                    data.hasHeadDownload = true
                end

                -- 开局玩家头像都会有一层蒙灰
                if data.hasStartBattle then
                    itemCardRooms["Image_black_player" .. i .. "_1_Clubpj"]:setVisible(true)
                    if bit.band(data.players[i].status, Constants.PlayerStatus.WAITING) ~= 0 then
                        -- 显示等待状态
                        itemCardRooms["Image_ddz_player" .. i .. "_1_Clubpj"]:setVisible(true)
                    else
                        -- 显示观战(有管理权限的才能显示)
                        local club = game.service.club.ClubService.getInstance():getClub(data.clubId)
                        local isManager = club:isPermissions(game.service.LocalPlayerService:getInstance():getRoleId())
                        itemCardRooms["Button_djgz_player" .. i .. "_1_Clubpj"]:setVisible(isManager)
                    end
                end
            else
                -- 没满人时，显示默认头像
                itemCardRooms["Image_face_player" .. i .. "_1_Clubpj"]:setTexture(DEFAULT_ICON)
                itemCardRooms["Image_face_player" .. i .. "_1_Clubpj"]:setScale(1.0)
                -- 显示加入
                itemCardRooms["Button_djjr_player" .. i .. "_1_Clubpj"]:setVisible(true)
            end
        else
             -- 超出最大人数，隐藏多余的玩家信息
             itemCardRooms["Panel_player" .. i .."_1_Clubpj"]:setVisible(false)
        end
    end

    -- 玩法显示
    local roomSettingInfo = RoomSettingInfo.new(data.gameplays, data.roundType)
    local gameTypeZHName = game.service.club.ClubService.getInstance():getInterceptString(roomSettingInfo:getZHArray()[1] or "", 8)
    local roundCount = roomSettingInfo:getRoundCountNumber() or 0

    node:setBackGroundImage(gameTypeZHName == "跑得快" and "art/club/img_pktable_club.png" or "art/club/img_table_club.png")

    local text = ""
    if data.hasStartBattle then
        if data.playerMax ~= #data.players then
            text = string.format("%s\n%s\n%d/%d局", "提前开局", gameTypeZHName, data.finishRoundCount, roundCount)
            itemCardRooms["Text_z_1_Clubpj"]:setColor(cc.c4b(RoomColor[2].r, RoomColor[2].g, RoomColor[2].b, 255))
        else
             text = string.format("%s\n%s\n%d/%d局", "已开局", gameTypeZHName, data.finishRoundCount, roundCount)
             itemCardRooms["Text_z_1_Clubpj"]:setColor(cc.c4b(RoomColor[3].r, RoomColor[3].g, RoomColor[3].b, 255))
        end
    else
        text = string.format("%s\n%s\n%d局", "未开局", gameTypeZHName, roundCount)
        itemCardRooms["Text_z_1_Clubpj"]:setColor(cc.c4b(RoomColor[1].r, RoomColor[1].g, RoomColor[1].b, 255))
    end
    -- 极速模式icon
    itemCardRooms["Text_z_1_Clubpj"]:setString(text)
    itemCardRooms["Image_extremeSpeed"]:setVisible(false)
    itemCardRooms["Image_extremeSpeed"]:setVisible(roomSettingInfo:isFastModeOpen())
    
    -- 详情点击事件
    bindEventCallBack(itemCardRooms["Button_3"], function () self:_onClickRoomInfo(data) end, ccui.TouchEventType.ended)
end

-- 观战
function UIElemRoomItem:_onClickWatching(roomId)
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end
    
    game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.Watch, true);
end

-- 加入房间
function UIElemRoomItem:_onClickJoin(data)
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end

    local roundCount, gamePlays = game.service.club.ClubService.getInstance():getClubRoomService():getRoomRule()
    if #gamePlays == 0 or data.gameplays[1] == gamePlays[1] then
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
        return
    end

    local str = string.format("检测到您上次完成的牌局玩法是%s，当前牌桌玩法是%s，是否继续进入房间？", RoomSettingInfo.new(gamePlays, roundCount):getZHArray()[1], RoomSettingInfo.new(data.gameplays, data.roundType):getZHArray()[1])
    UIManager:getInstance():show("UIClubRuleTips", str, 5, function ()
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
    end)
end

-- 创建房间
function UIElemRoomItem:_onClickCreateRoom(data)
    local club = game.service.club.ClubService.getInstance():getClub(data.clubId)
    if club.data ~= nil and bit.band(club.data.switches, ClubConstant:getClubSwitchType().FROZEN_ROOM) > 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.UICLUBROOM_STRING_100)
        return
    end

    -- 获取预设玩法
    local presetGameplays = club and club.data and club.data.presetGameplays or {}
    -- 获取禁用玩法
    local banGameplays = club and club.data and club.data.banGameplays or {}
    
    UIManager:getInstance():show("UICreateRoom", data.clubId, ClubConstant:getGamePlayType().normal, banGameplays)
end

-- 显示房间信息
function UIElemRoomItem:_onClickRoomInfo(roomInfo)
    -- 统计点击详情按钮的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Details);
    UIManager:getInstance():show("UIClubRoomInfo", roomInfo)
end

local UIClubRoom = class("UIClubRoom", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRoom:ctor()
    -- 按钮列表
    self._rightTopButtons = {}
    self._leftDownButtons = {}
    -- 让一键开房的规则能够显示在通知之上
    seekNodeByName(self, "Panel_top_Clubpj", "ccui.Layout"):setLocalZOrder(65535)
end

function UIClubRoom:init()
    self._btnHistory                = seekNodeByName(self, "Button_Zj_top_Clubpj",          "ccui.Button") -- 战绩
    self._btnProunnce                = seekNodeByName(self, "Button_Gg_top_Clubpj",          "ccui.Button") -- 公告
    self._btnMembers                = seekNodeByName(self, "Button_Cy_top_Clubpj",          "ccui.Button") -- 成员
    self._btnManager                = seekNodeByName(self, "Button_Gl_top_Clubpj",          "ccui.Button") -- 管理
    self._btnQuit                   = seekNodeByName(self, "Button_fh_top_Clubpj",          "ccui.Button") -- 返回
    self._imgClubIcon               = seekNodeByName(self, "Image_icon_top_Clubpj",         "ccui.ImageView") -- 亲友圈头像
    self._textClubName              = seekNodeByName(self, "Text_name_top_Clubpj",          "ccui.Text") -- 亲友圈名字
    self._textInvitationCode        = seekNodeByName(self, "Text_Id_top_Clubpj",            "ccui.Text") -- 亲友圈Id
    self._panelRoomCard             = seekNodeByName(self, "Panel_RoomCard",                "ccui.Layout") -- 亲友圈房卡的panel
    self._textBMFontRoomCardCount   = seekNodeByName(self, "BitmapFontLabel_z_top_Clubpj",  "ccui.TextBMFont") -- 亲友圈房卡
    self._btnSwitchingClub          = seekNodeByName(self, "Button_qh_top_Clubpj",          "ccui.Button") -- 切换亲友圈
    self._imgRedDot_Prounnce         = seekNodeByName(self, "Image_2_0_prounnce",           "ccui.ImageView")
    self._imgRedDot_Switching       = seekNodeByName(self, "Image_2",                       "ccui.ImageView") -- 切换亲友圈上的小红点
    self._btnTask                   = seekNodeByName(self, "Button_rw_top_Clubpj",          "ccui.Button") -- 任务
    self._redDot_Task               = seekNodeByName(self, "Particle_1_0",                  "cc.ParticleSystemQuad") -- 任务上的粒子特效
    self._textNotice                = seekNodeByName(self, "Text_nr_tz_ClubRoom",           "ccui.Text") -- 通知
    --self._textNoticeTitle           = seekNodeByName(self, "BitmapFontLabel_z_tz_ClubRoom", "ccui.TextBMFont") -- 通知标题
    self._btnNotice                 = seekNodeByName(self, "Button_bj",                     "ccui.Button") -- 通知编辑按钮
    self._imgRoomCardType           = seekNodeByName(self, "Panel_RoomCard_0",              "ccui.Layout") -- 群主出卡
    self._btnRedPacket              = seekNodeByName(self, "Button_qhb",                    "ccui.Button") -- 五一福利
    self._particleRedPacket         = seekNodeByName(self, "Particle_1",                    "cc.ParticleSystemQuad")
    self._btnRecommend              = seekNodeByName(self, "Button_xwjtj_top_Clubpj",       "ccui.Button") -- 新用户推荐
    self._btnActivity               = seekNodeByName(self, "Button_top_activity",           "ccui.Button") -- 活动按钮
    self._imgActivityRed            = seekNodeByName(self, "Image_activity_red",            "ccui.ImageView") -- 活动小红点
    self._btnZhuoji                 = seekNodeByName(self, "Button_zjxb",                   "ccui.Button") -- 捉鸡寻宝活动入口
    self._imgRedDot_Manager         = seekNodeByName(self, "Image_manager_red",             "ccui.ImageView") -- 管理后台红点
    self._btnZhuojiRed              = seekNodeByName(self._btnZhuoji, "Image_4",            "ccui.ImageView") -- 捉鸡寻宝红点提示
    self._btnQuestion               = seekNodeByName(self, "Button_Main_ask",               "ccui.Button") -- 问卷调查
    self._btnQuestionOk             = seekNodeByName(self, "Button_Main_ask_ok",            "ccui.Button") -- 问卷完成
    self._btnCreateRoom             = seekNodeByName(self, "Button_createRoom",             "ccui.Button") -- 创建房间
    self._btnLeaderboard            = seekNodeByName(self, "Button_Leaderboard",            "ccui.Button") -- 排行榜
    self._btnTurnCard               = seekNodeByName(self, "Button_TurnCard",               "ccui.Button") -- 翻牌
    self._btnGroup                  = seekNodeByName(self, "Button_clubGroup",              "ccui.Button") -- 俱乐部小组
    self._btnPullNew                = seekNodeByName(self, "btnPullNew",                    "ccui.Button") -- 邀请有礼
    self._btnLeaderboardActivity    = seekNodeByName(self, "Button_leaderboardActivity",    "ccui.Button") -- 排行榜活动
    self._imgRedDot_LeaderboardActivity = seekNodeByName(self, "Image_activity_red_0", "ccui.ImageView") -- 排行榜活动红点
    self._btnComeback               = seekNodeByName(self, "Button_Comeback", "ccui.Button") -- 回流活动
    self._btnRetain                 = seekNodeByName(self, "Button_retain", "ccui.Button") -- 俱乐部七日签到
    self._imgRedDot_Retain          = seekNodeByName(self._btnRetain, "Image_Point_Main", "ccui.ImageView") -- 俱乐部七日签到红点
    self._btnKoi                    = seekNodeByName(self, "Button_Koi", "ccui.Button")
    self._imgRedDot_Koi             = seekNodeByName(self._btnKoi, "Image_activity_red", "ccui.ImageView")

    --双11活动
    self._btnShuang11 = seekNodeByName(self, "Panel_shuang11", "ccui.Layout")
    self._btnShuang11.red = seekNodeByName(self._btnShuang11, "Image_Point_Main", "ccui.ImageView")

    self._nodeCreateRoom = seekNodeByName(self, "Node_1", "cc.Node") -- 一键开房的panel
    self._btnCreate_Room = seekNodeByName(self._nodeCreateRoom, "Button_Gl_top_Clubpj_0", "ccui.Button") -- 一键开房按钮
    self._btnRoomRuleDetails = seekNodeByName(self._nodeCreateRoom, "Button_Gl_top_Clubpj_0_0", "ccui.Button") -- 玩法详情按钮
    self._panelRoomRuleDetails = seekNodeByName(self._nodeCreateRoom, "Panel_4", "ccui.Layout") -- 玩法详情的panel
    self._textRoomRuleDetails = seekNodeByName(self._nodeCreateRoom, "Text_3", "ccui.Text") -- 玩法详情
    self._btnCreate_Room_list = seekNodeByName(self._nodeCreateRoom, "Button_list", "ccui.Button") -- 多玩法显示

    -- 亲友圈牌局列表
    self._reusedListRooms = UIItemReusedListView.extend(seekNodeByName(self, "ListView_PJ_Main", "ccui.ListView"), UIElemRoomItem)
    -- 不显示滚动条
    self._reusedListRooms:setScrollBarEnabled(false)

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

    self:_initBtnIsVisible()
    self:_managerBtn()
    self:_registerCallBack()
end

function UIClubRoom:_initBtnIsVisible()
    self._panelRoomRuleDetails:setVisible(false)
    self._textRoomRuleDetails:setVisible(false)
    self._imgActivityRed:setVisible(false)
    self._panelRoomCard:setVisible(false)
    self._imgRoomCardType:setVisible(false)
    self._btnRedPacket:setVisible(false)
    self._btnTask:setVisible(false)
    self._imgRedDot_Prounnce:setVisible(false)
    self._btnZhuoji:setVisible(false)
    self._imgRedDot_Manager:setVisible(false)
    self._btnQuestion:setVisible(false)
    self._btnQuestionOk:setVisible(false)
    self._btnNotice:setVisible(false)
    self._nodeCreateRoom:setVisible(false)
    self._btnCreate_Room_list:setVisible(false)
    self._btnRoomRuleDetails:setVisible(false)
    self._imgRedDot_Retain:setVisible(false)
    self._btnRetain:setVisible(false)
end

function UIClubRoom:_managerBtn() 
    self._action = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._action)

    -- 右上角按钮
    self._rightTopPanel = seekNodeByName(self, "Panel_rightTopPanel", "ccui.Layout")
    table.insert(self._rightTopButtons, self._btnManager)
    table.insert(self._rightTopButtons, self._btnMembers)
    table.insert(self._rightTopButtons, self._btnHistory)
    table.insert(self._rightTopButtons, self._btnProunnce)
    table.insert(self._rightTopButtons, self._btnLeaderboard)
    table.insert(self._rightTopButtons, self._btnRecommend)
    table.insert(self._rightTopButtons, self._btnGroup)

    -- 左下角按钮
    self._leftDownPanel = seekNodeByName(self, "Panel_leftDownPanel", "ccui.Layout")
    table.insert(self._leftDownButtons, self._btnPullNew)
    table.insert(self._leftDownButtons, self._btnActivity)
    table.insert(self._leftDownButtons, self._btnShuang11)
    table.insert(self._leftDownButtons, self._btnLeaderboardActivity)
    table.insert(self._leftDownButtons, self._btnComeback)
    table.insert(self._leftDownButtons, self._btnRetain)
    table.insert(self._leftDownButtons, self._btnQuestion)
    table.insert(self._leftDownButtons, self._btnQuestionOk)
    table.insert(self._leftDownButtons, self._btnTask)
    table.insert(self._leftDownButtons, self._btnRedPacket)
    table.insert(self._leftDownButtons, self._btnTurnCard)
    table.insert(self._leftDownButtons, self._btnKoi)
end

--改变单个按钮的显示和隐藏，改变玩了之后要重排
function UIClubRoom:_changeButtonVisibleState(button, visible)
	button:setVisible(visible)
	self:_sortAllButtons()
end

--调整按钮位置
function UIClubRoom:_sortAllButtons()
	self:sortPanelButtons(self._rightTopPanel, self._rightTopButtons, 1, 5)
    self:sortPanelButtons(self._leftDownPanel, self._leftDownButtons, 0, 10)
	-- 所有右上角按钮的Y坐标调整
	table.foreach(self._rightTopButtons, function(idx, btn)
		btn:setPositionY(50)
    end)
    
    table.foreach(self._leftDownButtons, function(idx, btn)
		btn:setPositionY(50)
	end)
end

function UIClubRoom:sortPanelButtons(panel, buttons, dir, interval) 	--dir:0从左开始排，1从右开始排
	-- local buttons = panel:getChildren()
	local i = 0
	for _, button in ipairs(buttons) do
		if button:isVisible() then
			if dir == 0 then
				button:setAnchorPoint(cc.p(0, 0.5))
				button:setPositionX(i * (button:getContentSize().width + interval))
				i = i + 1
			else
				button:setAnchorPoint(cc.p(1, 0.5))
				button:setPositionX(panel:getContentSize().width - i *(button:getContentSize().width + interval))
				i = i + 1
			end
		end
	end
end

function UIClubRoom:_registerCallBack()
    bindEventCallBack(self._btnHistory, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.record, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnProunnce, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.message, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMembers, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.member, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnManager, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.manager, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.close, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._panelRoomCard, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.buy, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSwitchingClub, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.switchingClub, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._imgClubIcon, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.clubInfo, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnTask, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.task, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnNotice, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.notice, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRedPacket, function ()
        local club = game.service.club.ClubService:getInstance():getClub(self._clubId)
        if club then
            club:mergeRedPacketChanged()
            self._particleRedPacket:setVisible(club:isRedPacketChanged())
        end
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.redPacket, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRecommend, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.recommend, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnActivity, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.activity, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnZhuoji, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.zhuoji, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuestion, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.questionnaire, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuestionOk, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.questionnaire, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLeaderboard, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.ranking, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnTurnCard, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.turnCard, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGroup, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.group, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPullNew, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.wxShare, self._clubId)
    end, ccui.TouchEventType.ended)
    bindTouchEventWithEffect(self._btnShuang11,	function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.shuang11, self._clubId)
    end, 1.05)
    bindEventCallBack(self._btnLeaderboardActivity, function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.leaderBoardActivity, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreateRoom, function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.createRoom, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate_Room, function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.oneKeyCreateRoom, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate_Room_list, function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.oneKeyCreateRoom_2, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRoomRuleDetails, function()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.oneKeyRoomRule, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnComeback, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.comeback, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRetain, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.retain, self._clubId)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnKoi, function ()
        UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.koi, self._clubId)
    end)
end

function UIClubRoom:getNode()
    return 
    {
        panelOneKeyRoomRule = self._panelRoomRuleDetails,
        textOneKeyRoomRule = self._textRoomRuleDetails,
        textNotice = self._textNotice,
    }

end

function UIClubRoom:onShow(clubId)
    --self._textNoticeTitle:setString(config.STRING.UICLUBROOM_STRING_110 or "")
    self._action:gotoFrameAndPlay(0, true)
    self._clubId = clubId

    game.service.club.ClubService.getInstance():tryQueryDirtyClubData(self._clubId, true)
    -- club 关注亲友圈房间列表变化
    game.service.club.ClubService.getInstance():getClubRoomService():sendCCLFocusOnRoomListREQ(self._clubId, 1)

    self:_initChangeButtonVisible()
    self:_setManagerPermissions(self._clubId)
    self:_refreshRewardQuestionStatus()
    self:_setLeaderboardActivity()
    self:_activityQuerysOnShow()
    self:_eventListener()
    self:_isFirstLogin()
end

-- 监听事件
function UIClubRoom:_eventListener()
    local clubService = game.service.club.ClubService.getInstance()
    local clubManagerService = game.service.club.ClubService.getInstance():getClubManagerService()
    local clubRoomService = game.service.club.ClubService.getInstance():getClubRoomService()
    local clubActivityService = game.service.club.ClubService.getInstance():getClubActivityService()

    clubManagerService:addEventListener("EVENT_CLUB_ROOM_DATA_RETRIVED", handler(self, self._onRoomDataRetrived), self)
    clubManagerService:addEventListener("EVENT_CLUB_BAN_GAMEPLAY_CHANGED", handler(self, self._refreshCreateRoomUI),self)
    clubManagerService:addEventListener("EVENT_USER_INFO_CARD_COUNT_CHANGED", handler(self, self._onCardCountChangedEvent), self)
    clubManagerService:addEventListener("EVENT_CLUB_INFO_CHANGED",  handler(self, self._onClubInfoChanged), self)
    clubManagerService:addEventListener("EVENT_CLUB_INFO_NOTICE_CHANGED", function(event)
        self:_setClubNotice(event.clubId, event.clubNotice)
    end, self)

    clubRoomService:addEventListener("EVENT_CLUB_ROOM_DATA_RETRIVED", handler(self, self._onRoomDataRetrived), self)
    clubRoomService:addEventListener("EVENT_CLUB_ROOM_DATA_CHANGED",    handler(self, self._onRoomDataChanged),  self)
    
    clubService:addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
    clubService:addEventListener("EVENT_CLUB_DATA_RETRIVED", function(event)
        self:_setManagerPermissions(event.clubId)
    end, self)
    clubService:addEventListener("EVENT_CLUB_INFO_TASK_CHANGED", function(event)
        self:_onTaskChange(event.clubId, event.clubTaskVersion)
    end, self)
    
    -- 有新的红包推送
    clubActivityService:addEventListener("EVENT_CLUB_REDPACKET_CHANGED", handler(self, self._onRedPacketChanged), self)
    clubActivityService:addEventListener("EVENT_CLUB_ACTIVITY_TREASURE_VERSION_CHANGED", handler(self, self._changeZhuojiRed), self)
    -- 断线重连的时候，重新关注，更新UI新数据
    game.service.LoginService:getInstance():addEventListener("USER_DATA_RETRIVED", handler(self, self._onRegisterAgain), self)
    game.service.NoticeMailService:getInstance():addEventListener("EVENT_REDDOT_CHANGED", handler(self, self._hasProunnceRed), self)
    game.service.AgentService.getInstance():addEventListener("EVENT_AGT_RECRUIT_CHANGED", handler(self, self._updateRecruitInfo), self)
    -- 监听二丁拐的进度消息
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):addEventListener("EVENT_TWO_GAY_ACT_PROGRESS", handler(self, self._refreshErDingGuaiActivity), self)
    -- 监听红点树的消息
    game.service.LocalPlayerService:getInstance():addEventListener("EVENT_RED_DOT_CHANGE", handler(self, self._setLeaderboardActivity), self)
    -- 处理活动消息
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._refreshTurnCardActivity), self)
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_INFO", handler(self, self._refreshTurnCardActivity), self);

    -- 回流活动的监听
    local comebackService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if comebackService then
        comebackService:addEventListener("EVENT_ACTIVITY_COMEBACK_FINAL_REWARD_TIME_SYN", handler(self, self._refreshComebackBtnVisible), self)
    end
end

-- 更新调查问卷信息
function UIClubRoom:_refreshRewardQuestionStatus()
    -- 俱乐部暂时不需要，直接注释了
    -- local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEN_JUAN)
    -- if service then
        -- local isOpening = service:isActivityOpening()
        -- local notDone = false -- 跳转webView
        -- local doneWithoutRecv = false -- 领奖
        -- if isOpening then
        --     notDone = not service:isQuestionnaireDone() 
        --     doneWithoutRecv = service:isQuestionnaireDone() and (not service:isQuestionnaireRewardReceived()) 
        -- end
        -- local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
        -- local managerId = game.service.club.ClubService.getInstance():getClubManagerId(self._clubId)
        -- local isManager = roleId == managerId
        -- self:_changeButtonVisibleState(self._btnQuestion, notDone and isManager)
        -- self:_changeButtonVisibleState(self._btnQuestionOk, doneWithoutRecv and isManager)
    -- end
end

-- 默认隐藏btn排序
function UIClubRoom:_initChangeButtonVisible()
    self:_changeButtonVisibleState(self._btnManager, false)
    self:_changeButtonVisibleState(self._btnRecommend, false)
    self:_changeButtonVisibleState(self._btnGroup, false)
    self:_changeButtonVisibleState(self._btnActivity, false)
    self:_changeButtonVisibleState(self._btnLeaderboardActivity, game.service.club.ClubService.getInstance():getClubActivityService():isActivitiesWithin(ClubConstant:getClubActivityId().LEADER_BOARD))
    self:_changeButtonVisibleState(self._btnPullNew, game.service.ActivityService.getInstance():isShareQuality())
    self:_changeButtonVisibleState(self._btnShuang11, game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY))
    self:_changeButtonVisibleState(self._btnRetain, game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.CLUB_WEEK_SIGN))
    self:_changeButtonVisibleState(self._btnKoi, game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.CLUB_KOI))

    if game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.CLUB_KOI) then
        if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.club.ClubService.getInstance():getClubActivityService():getKoiActivityShow() then
            UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.koi, self._clubId)
        end
    end

    --翻牌活动是否开启
    --if game.service.ActivityService:getInstance():isActivitieswithin(net.protocol.activityType.TURN_CARD) then
    --
	--	--每日首次登陆自动显示
    --    self:_changeButtonVisibleState(self._btnTurnCard, true)
    --    local chance = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum()
	--    self._btnTurnCard:getChildByName("Image_Point_Main"):setVisible(chance > 0)
    --else
    --    self:_changeButtonVisibleState(self._btnTurnCard, false)
    --end
    self:_changeButtonVisibleState(self._btnTurnCard, false)

    -- 俱乐部七日签到活动(活动期间玩家首次登录弹出)
    if game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.CLUB_WEEK_SIGN) then
        local playersInfo = game.service.club.ClubService:getInstance():loadLocalStorageGamePlayInfo()
        local isShowRetain = playersInfo:getPlayerInfo(self._roleId).isShowRetain
        if isShowRetain == nil or isShowRetain == false then
            UIClubRoomBtnClick.onBtnClick(UIClubRoomBtnClick.btnType.retain, self._clubId)
            playersInfo:getPlayerInfo(self._roleId).isShowRetain = true
            game.service.club.ClubService:getInstance():saveLocalStorageGamePlayInfo(playersInfo)
        end
    end
end

function UIClubRoom:_setManagerPermissions(clubId)
    if clubId ~= self._clubId then
        return
    end

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)

    if club.data == nil then
        return
    end

    if not config.GlobalConfig.OPEN_CLUB_EARLY then
        -- 客户端自己强行把提前开局关闭
        if bit.band(club.data.switches, ClubConstant:getClubSwitchType().EARLY_BATTLE_3) > 0 then
            game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(self._clubId, ClubConstant:getClubSwitchType().EARLY_BATTLE_3, false)
        end
        if bit.band(club.data.switches, ClubConstant:getClubSwitchType().EARLY_BATTLE_4) > 0 then
            game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(self._clubId, ClubConstant:getClubSwitchType().EARLY_BATTLE_4, false)
        end
    end

    -- 亲友圈信息
    local invitationCode = string.format("邀请码:%s",  tostring(club.data.invitationCode))
    self._textInvitationCode:setString(invitationCode)
    self._textClubName:setString(clubService:getInterceptString(club.data.clubName))
    self._imgClubIcon:loadTexture(clubService:getClubIcon(club.data.clubIcon))
    -- 切换地区按钮根据亲友圈名字长度做适配
    local x, y = self._textClubName:getPosition()
    local size = self._textClubName:getVirtualRendererSize()
    self._btnSwitchingClub:setPosition(x + size.width, y)

    -- 群主、管理特权
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    self:_changeButtonVisibleState(self._btnManager, club:isPermissions(localRoleId))
    self._panelRoomCard:setVisible(club:isPermissions(localRoleId))
    self._imgRoomCardType:setVisible(not club:isPermissions(localRoleId))
    -- 暂时屏蔽通知功能
    self._btnNotice:setVisible(club:isPermissions(localRoleId))


    --仅限群主权限
    local isManager = clubService:isMeManager(self._clubId)
    local groupId = clubService:getGroupId(self._clubId)
    self:_changeButtonVisibleState(self._btnGroup, isManager or groupId ~= "")

    -- 并且在白名单内开启该功能
    self:_changeButtonVisibleState(self._btnRecommend, club:isPermissions(localRoleId) and bit.band(club.data.clubWhiteList, ClubConstant:getWhiteListType().RECOMMEND) > 0)

    self:_onTaskChange(club.info.clubId, club.info.clubTaskVersion)

    self:_setClubNotice(self._clubId, club.data.clubNotice)

    self:_onCardCountChangedEvent()

    self:_changeButtonVisibleState(self._btnTask, club.data.hasTask)

    if club and club:isRedPacketChanged() then
        self._particleRedPacket:setVisible(true)
    else
        self._particleRedPacket:setVisible(false)
    end

    self:_showTabBadge()
    self:_hasProunnceRed()

    -- 亲友圈活动显示
    game.service.CampaignService.getInstance():getSelfbuildService():onCampaignCreateListREQ(self._clubId)
    game.service.CampaignService.getInstance():addEventListener("EVENT_CLUBCAMPAIGN_REFRESH", function(event)
        self:_changeButtonVisibleState(self._btnActivity, club.data.hasManagerActivity or #event.data.campaigns > 0)
    end, self)

    self._btnZhuoji:setVisible(club.data.hasTreasure and club:isManager(localRoleId))
    self:_changeZhuojiRed()

    self:_initOneKeyCreateRoom()
    self:_refreshComebackBtnVisible()
end

-- 任务版本号推送
function UIClubRoom:_onTaskChange(clubId, clubTaskVersion)
    if clubId ~= self._clubId then
        return
    end

    -- 亲友圈任务版本号不等于本地保存的版本号就弹出任务板
    if not game.service.club.ClubService.getInstance():hasTaskChange(clubId, clubTaskVersion) then
        return
    end

    -- 不是群主就不需要弹任务窗
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)

    -- 没有任务就不弹任务板了
    if club.data == nil or not club.data.hasTask then
        return
    end

    if not club:isPermissions(game.service.LocalPlayerService.getInstance():getRoleId()) then
        return
    end

    if UIManager:getInstance():getIsShowing(UIClubTask) then
        UIManager:getInstance():hide("UIClubTask")
    end
    UIManager:getInstance():show("UIClubTask", self._clubId)
end

-- 设置排行榜活动红点显示
function UIClubRoom:_setLeaderboardActivity()
    local redDotStateTreeManager = manager.RedDotStateTreeManager.getInstance()
    self._imgRedDot_LeaderboardActivity:setVisible(redDotStateTreeManager:isVisibleParent(redDotStateTreeManager:getRedDotParent().CLUB_RANK_REWARD))
    self._imgRedDot_Koi:setVisible(redDotStateTreeManager:isVisible(redDotStateTreeManager:getRedDotKey().KOI_FISH_ACTIVITY))
end

-- 捉鸡寻宝红点改变
function UIClubRoom:_changeZhuojiRed()
    local cache = game.service.club.ClubService.getInstance():getClubActivityService():getActivityCache()
	self._btnZhuojiRed:setVisible(not cache:getTreasureIsRead())
end

-- 亲友圈公告小红点显示机制
function UIClubRoom:_hasProunnceRed()
    -- 不知道为什么实际上调用的是大厅的邮件，改为使用邮件更新机制
   local clubService = game.service.club.ClubService.getInstance()
   local club = clubService:getClub(self._clubId)
   local isVisible = club:hasApplicationBadges()
   local noticeService = game.service.NoticeMailService.getInstance()
   if noticeService:isNoticeDotShow() or noticeService:isMailDotShow() then
       self._imgRedDot_Prounnce:setVisible(true or isVisible)
   else
       self._imgRedDot_Prounnce:setVisible(false or isVisible)
   end
end

-- 更新Tab上的Badge状态
function UIClubRoom:_showTabBadge()
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local noticeService = game.service.NoticeMailService.getInstance()
    local isVisible = noticeService:isNoticeDotShow() or noticeService:isMailDotShow()
    self._imgRedDot_Prounnce:setVisible(club:hasApplicationBadges() or isVisible)
    self._redDot_Task:setVisible(club:hasTaskBadges())
    
    self._imgRedDot_Switching:setVisible(clubService:hasClubBadges(self._clubId))
end

function UIClubRoom:_onRedPacketChanged(event)
    if event.clubId == self._clubId then
        local club = game.service.club.ClubService:getInstance():getClub(self._clubId)
        if club then
            -- 这里的红包判断还有红包数量
            self._particleRedPacket:setVisible(true)
            if self._redPacketAnim ~= nil then
                UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
                self._redPacketAnim = nil
            end

            local pos = cc.p(display.width/2, display.height/2)
            pos = self:getParent():convertToWorldSpace(pos)
            -- 新的动画特效
            self._redPacketAnim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("csb/Effect_redbox.csb", function()
            end, -1, pos, nil, nil, false, self._btnTask:getParent()))
            local delay = cc.DelayTime:create(2)
            local move = cc.MoveTo:create(0.5, cc.p(self._btnTask:getPosition()))
            local callback = cc.CallFunc:create(function()
                UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
                self._redPacketAnim = nil
            end)
            local seq = cc.Sequence:create(delay, move, callback)
            self._redPacketAnim._csbAnim:runAction(seq)
        end
    end
end

-- 申请代理
function UIClubRoom:_updateRecruitInfo(event)
	local path = {}
	-- 下载gmt配置的图片
	local FILE_TYPE = "playericon"
	for k, v in ipairs(event.recruitInfo.sowingMapUrl) do
		local fileExist = manager.RemoteFileManager.getInstance():doesFileExist(FILE_TYPE, v)
		if fileExist == false then
			manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, v, function(tf, fileType, fileName)
				if Macro.assetFalse(tf) then
					-- 获取成功之后设置图片
					local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
					table.insert(path, filePath)
					if UIManager:getInstance():getIsShowing("UIRecruit") then
						UIManager:getInstance():destroy("UIRecruit")
					end
					UIManager:getInstance():show("UIRecruit", path, event.recruitInfo.weChat)	
				end
			end)
		else
			local filePath = manager.RemoteFileManager.getInstance():getFilePath(FILE_TYPE, v)
			table.insert(path, filePath)
		end
	end
	
	if #path == #event.recruitInfo.sowingMapUrl then
		if UIManager:getInstance():getIsShowing("UIRecruit") then
			UIManager:getInstance():destroy("UIRecruit")
		end
		UIManager:getInstance():show("UIRecruit", path, event.recruitInfo.weChat)
	end
end

-- 设置亲友圈房卡数量
function UIClubRoom:_onCardCountChangedEvent()
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    if club:isManager(localRoleId) then
        local userData = game.service.club.ClubService.getInstance():getUserData();
        self._textBMFontRoomCardCount:setString(kod.util.String.formatMoney(userData.info and userData.info.clubCardCount or "0", 2))
    elseif club:isAdministrator(localRoleId) then
        self._textBMFontRoomCardCount:setString(kod.util.String.formatMoney(club.info.clubCardCount, 2))
    end
end

-- 亲友圈信息变化
function UIClubRoom:_onClubInfoChanged(event)
    if event.clubId ~= self._clubId then
        return
    end
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._clubId)
    self._imgClubIcon:loadTexture(clubService:getClubIcon(clubService:getClubIconName(self._clubId)))
    self._textClubName:setString(clubService:getInterceptString(clubService:getClubName(self._clubId)))
    -- self:_changeButtonVisibleState(self._btnRedPacket, club.hasActivity)
end

-- 处理断线重连重新关注房间变化
function UIClubRoom:_onRegisterAgain()
    self:_refreshRewardQuestionStatus()
    game.service.club.ClubService.getInstance():tryQueryDirtyClubData(self._clubId, true)
    game.service.club.ClubService.getInstance():getClubRoomService():sendCCLFocusOnRoomListREQ(self._clubId, 1);
end

-- 亲友圈公告
function UIClubRoom:_setClubNotice(clubId, clubNotice)
    if clubId ~= self._clubId then
        return
    end

    if clubNotice == "" then
        clubNotice = "群主和管理暂未发布通知"
    end

    -- clubNotice = config.STRING.CLUB_NOTICE_STRING_100
    -- 居中显示
    -- self._textNotice:setTextHorizontalAlignment(1)

    self._textNotice:setString(clubNotice)
end

--翻牌活动标记更新
function UIClubRoom:_refreshTurnCardActivity()
	local chance = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum()
	self._btnTurnCard:getChildByName("Image_Point_Main"):setVisible(chance > 0)
	-- self._btnTurnCard:getChildByName("Particle_1"):setVisible(chance > 0)
end

function UIClubRoom:_refreshErDingGuaiActivity()
	local progressData = game.service.ActivityService.getInstance().erDingGuaiProgerss
	local hasChance = false
	if progressData then
		for k, v in ipairs(progressData.progress) do
			if v.status == net.protocol.ProgressStatus.completed then
				hasChance = true
				break
			end
		end
	end
	
	self._btnShuang11.red:setVisible(hasChance)
end

function UIClubRoom:_activityQuerysOnShow()
	local activityService = game.service.ActivityService.getInstance()
	if activityService:isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY) then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldProgressREQ()
	end
    -- 每日自动弹出俱乐部回流活动
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if service then
        service:checkAutoShow(self.class.__cname)
    end
end

-- 不在活动期间内，但是服务器发送这个消息的话，就显示按钮
function UIClubRoom:_refreshComebackBtnVisible()
    local value = false
    -- 经理才会显示
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    local managerId = game.service.club.ClubService.getInstance():getClubManagerId(self._clubId)
    if roleId == managerId then
        local comebackService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
        if comebackService then
            local isInTime = game.service.ActivityService:getInstance():isActivitieswithin(net.protocol.activityType.COMEBACK)
            if isInTime then
                value = true
            else
                value = comebackService:getIsInFinalRewardTime()
            end
        end
    end
    self:_changeButtonVisibleState(self._btnComeback, value)
end

-- 群主设定创建房间的禁止项
function UIClubRoom:_refreshCreateRoomUI(event)
    local isShowingCreateRoom = UIManager:getInstance():getIsShowing("UICreateRoom");
    if self._clubId == event.clubId and isShowingCreateRoom then
        UIManager:getInstance():hide("UICreateRoom");
        self:_showCreateRoom();
        game.ui.UIMessageTipsMgr.getInstance():showTips("群主或者管理修改房间的规则!")
    end

    self:_initOneKeyCreateRoom()
end

-- 显示创建房间界面
function UIClubRoom:_showCreateRoom()
    local clubService = game.service.club.ClubService.getInstance();
    local club = self._clubId and clubService and clubService:getClub(self._clubId) or nil;
    local banGameplays = club and club.data and club.data.banGameplays or {};        -- 服务器传回的已被禁止项
    UIManager:getInstance():show("UICreateRoom", self._clubId, ClubConstant:getGamePlayType().normal, banGameplays)
end

function UIClubRoom:_initOneKeyCreateRoom()
    local clubService = game.service.club.ClubService.getInstance()
    local presetGamePlays = clubService:getPresetGameplays(self._clubId)
    local isInvalid = false
    for id, rule in ipairs(presetGamePlays) do
        if not rule.isInvalid then
            isInvalid = true
            break
        end
    end

    self._nodeCreateRoom:setVisible(isInvalid)
    if isInvalid then
        local maxPresetGamePlay = clubService:getMaxPresetGamePlay(self._clubId)
        self._btnRoomRuleDetails:setVisible(maxPresetGamePlay == 1)
        self._btnCreate_Room_list:setVisible(maxPresetGamePlay ~= 1)
    end
end

-- 第一次要不要显示clubPush引导
function UIClubRoom:_isFirstLogin()
    if  game.plugin.Runtime.isAccountInterflow() == false then
        return
    end
    local clubService = game.service.club.ClubService.getInstance()
    local gamePlayerInfo = clubService:loadLocalStorageGamePlayInfo()
    if gamePlayerInfo:getPlayerInfo().isFirstLogin == false then
        UIManager:getInstance():show("UIClubPushGuidance")
        gamePlayerInfo:getPlayerInfo().isFirstLogin = true
        clubService:saveLocalStorageGamePlayInfo(gamePlayerInfo)
    end
end

function UIClubRoom:onHide()
    -- 取消监听事件
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubRoomService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
    game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
    -- club 取消关注亲友圈房间列表变化
    game.service.club.ClubService.getInstance():getClubRoomService():sendCCLFocusOnRoomListREQ(self._clubId, 0)
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
    game.service.AgentService.getInstance():removeEventListenersByTag(self)
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
    -- 清空列表
    self._reusedListRooms:deleteAllItems()
    if self._redPacketAnim then
        UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
        self._redPacketAnim = nil
    end
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRoom:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom;
end

-- 获取到了房间列表
function UIClubRoom:_onRoomDataRetrived(event)
    if event.clubId ~= self._clubId then
        return
    end

    -- 清空列表
    self._reusedListRooms:deleteAllItems()

    -- 获取数据
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)

    -- 列表排序
    table.sort(club.rooms, function(a, b)
        -- 1 未开局  2 提前开局 3 已满
        local advance_a =  a.hasStartBattle and 3 or 1
        if a.hasStartBattle and a.playerMax ~= #a.players then
            advance_a = 2
        end

        local advance_b =  b.hasStartBattle and 3 or 1
        if b.hasStartBattle and b.playerMax ~= #b.players then
            advance_b = 2
        end
        if advance_a == advance_b then -- 当开局情况一样时
            local _a = a.playerMax - #a.players -- a差几个人开局
            _a = _a == 0 and 10000 or _a -- 把0个人的牌桌认为差10000个人，这样就会排到最后去，当一个桌子能做10000个人的时候，再来改这里
            local _b = b.playerMax - #b.players -- b差几个人开局
            _b = _b == 0 and 10000 or _b -- 同理

            if _a == _b then -- 当差的人一样时，比较时间先后
                return a.createTimestamp < b.createTimestamp
            end
            -- 差的不一样时，比较谁差的少，谁靠前
            return _a < _b
        end

        return advance_a < advance_b
    end)

    local roomRow = {}
    -- 先添加创建亲友圈的item
    -- table.insert(roomRow, {type = "add", clubId = self._clubId, roomId = -1})

    -- 添加牌局
    for roomIdx,room in ipairs(club.rooms) do
        room.type = "room"
        room.hasHeadDownload = false
        table.insert(roomRow, room)
        if #roomRow == ITEM_COUNT then
            self._reusedListRooms:pushBackItem(roomRow)
            roomRow = {}
        end
    end

    if #roomRow > 0 then
        self._reusedListRooms:pushBackItem(roomRow)
        roomRow = {}
    end 
end

-- 房间信息变化通知
function UIClubRoom:_onRoomDataChanged(event)
      -- 更新List中数据
    if event.clubId ~= self._clubId then
        return
    end
    -- TODO:如果收到数据变化的时候，当前的listview就为空的时候，再更新就会出错了
    -- 这里的已经不能避免了，就不再上传了
    -- if #self._reusedListRooms:getItemDatas() == 0 then
    --     return
    -- end

    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local changeRooms = club.changeRooms

     for _, data in ipairs(changeRooms) do
        local index, item = self:_indexOfItem(self._clubId, data.roomId)
        -- 解散、牌局结束、群主强制解散
        if data.isRemoved then
            -- 当前item不存在就不用就行排序了
            if index then
                if #item > 1 then
                    -- 重新排序
                    local roomDatas = {}
                    local datas = {}
                    local itemDatas = self._reusedListRooms:getItemDatas()
                    for i = index, #itemDatas do
                        for ii = 1, #itemDatas[i] do
                            if itemDatas[i][ii].roomId ~= data.roomId then -- 删除此roomId的数据
                                table.insert(datas, itemDatas[i][ii])
                                if #datas == ITEM_COUNT then
                                    table.insert(roomDatas, datas)
                                    datas = {}
                                end
                            end
                        end
                    end

                    if #datas > 0 then
                        table.insert(roomDatas, datas)
                        datas = {}
                    end

                    if #roomDatas > 0 then
                        -- 当前数据小于以前数据需要删除
                        if  #roomDatas - 1 + index < #self._reusedListRooms:getItemDatas() then
                            self._reusedListRooms:deleteItem(#self._reusedListRooms:getItemDatas()) 
                            -- Macro.assertTrue(#self._reusedListRooms:getItemDatas() == 0, "after delete item, listview 为空！")
                        end
                        -- 从删除的那条开始刷新数据
                        for i = index, #self._reusedListRooms:getItemDatas() do
                            if i - index + 1 <= #roomDatas then
                                self._reusedListRooms:updateItem(i, roomDatas[i - index + 1])
                            end
                        end
                    end
                else
                   -- 当 item 里面只有一条数据时就说明是最后一个直接删除
                    self._reusedListRooms:deleteItem(index)
                    -- Macro.assertTrue(#self._reusedListRooms:getItemDatas() == 0, "delete last item listview 为空！")
                end
            end
        else
            if index ~= false then
                -- 更新数据
                 for i = #item, 1, -1 do
                    if item[i].roomId == data.roomId then
                        item[i] = data
                        item[i].type = "room"
                        item[i].hasHeadDownload = false
                    end
                end
                self._reusedListRooms:updateItem(index, item)
            else
                -- todo: 添加到头部
                -- 创建新的房间item
                local itemDatas = self._reusedListRooms:getItemDatas()

                -- 处理为0的情况 或 最后一个item正好三个时
                if #itemDatas == 0 or #itemDatas[#itemDatas] == ITEM_COUNT then
                    local newRooms = {}
                    data.type = "room"
                    data.hasHeadDownload = false
                    table.insert(newRooms, data)
                    self._reusedListRooms:pushBackItem(newRooms)
                else
                    -- 不够三个时
                    local newRooms = {}
                    for i = 1, #itemDatas[#itemDatas] do
                        table.insert(newRooms, itemDatas[#itemDatas][i])
                    end
                    data.type = "room"
                    data.hasHeadDownload = false
                    table.insert(newRooms, data)
                    self._reusedListRooms:updateItem(#itemDatas, newRooms)
                end
            end
        end
     end
end

-- 查找item
function UIClubRoom:_indexOfItem(clubId, roomId)
    for idx,item in ipairs(self._reusedListRooms:getItemDatas()) do
        for _, data in ipairs(item) do
            if data.clubId == clubId and data.roomId == roomId then
                return idx, item
            end
        end
    end
    return false;
end

return UIClubRoom