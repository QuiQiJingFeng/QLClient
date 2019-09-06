local csbPath = "ui/csb/BigLeague/UIBigLeagueMain.csb"
local super = require("app.game.ui.UIBase")
local UIBigLeagueMain = class("UIBigLeagueMain", super, function() return kod.LoadCSBNode(csbPath) end)

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UIElemRoomItem = require("app.game.ui.bigLeague.room.UIElemRoomItem")
local ITEM_COUNT = 3


function UIBigLeagueMain:ctor()
    self._rightTopButtons = {}
end

function UIBigLeagueMain:init()
    self._rightTopPanel = seekNodeByName(self, "Panel_rightTopPanel", "ccui.Layout") -- 按钮panel

    self._btnGamePlay = seekNodeByName(self, "Button_GamePlay", "ccui.Button") -- 玩法
    self._imgGamePlayRed = seekNodeByName(self, "Image_GamePlay_Red", "ccui.ImageView") -- 玩法小红点
    self._btnLeaderboard = seekNodeByName(self, "Button_Leaderboard", "ccui.Button") -- 排行榜
    self._btnLeagueData = seekNodeByName(self, "Button_LeagueData", "ccui.Button") -- 联盟数据
    self._btnLeague = seekNodeByName(self, "Button_League", "ccui.Button") -- 联盟
    self._btnMember = seekNodeByName(self, "Button_Member", "ccui.Button") -- 成员
    self._btnMessage = seekNodeByName(self, "Button_Message", "ccui.Button") -- 消息
    self._imgMessageRed = seekNodeByName(self._btnMessage, "Image_Message_Red", "ccui.ImageView") -- 联盟红点
    self._btnRecord = seekNodeByName(self, "Button_Record", "ccui.Button") -- 战绩
    self._btnMore = seekNodeByName(self, "Button_More", "ccui.Button") -- 更多
    self._btnManager = seekNodeByName(self, "Button_manager", "ccui.Button") -- 管理
    self._btnCreateRoom = seekNodeByName(self, "Button_CreateRoom", "ccui.Button") -- 创建房间
    -- self._btnPlayFilter = seekNodeByName(self, "Button_GameFilter", "ccui.Button") --玩法筛选按钮
    -- self._imgFilterRed = seekNodeByName(self, "Image_Play_Red", "ccui.ImageView") --玩法筛选红点

    self._btnSwitch = seekNodeByName(self, "Button_Switch", "ccui.Button") -- 切换
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    self._textLeagueName = seekNodeByName(self, "Text_LeagueName", "ccui.Text") -- 联盟名称（俱乐部名称）

    self._panelRoomCard = seekNodeByName(self, "Panel_RoomCard", "ccui.Layout") -- 房卡
    self._textRoomCard = seekNodeByName(self, "Text_RoomCard", "ccui.TextBMFont")
    self._panelRoomGold = seekNodeByName(self, "Panel_RoomGold", "ccui.Layout") -- 金币
    self._textRoomGold = seekNodeByName(self, "Text_RoomGold", "ccui.TextBMFont")

    self._panelMyPoint_C = seekNodeByName(self, "Panel_MyPoint_C", "ccui.Layout") -- 我的赛事分
    self._textMyPoint_C = seekNodeByName(self, "BitmapFontLabel_MyPoint_C", "ccui.TextBMFont")
    self._panelMPC_Detail = seekNodeByName(self, "Button_MPC", "ccui.Button") -- 我的赛事分 详 按钮
    self._panelMyPoint_B = seekNodeByName(self, "Panel_MyPoint_B", "ccui.Layout") -- 我的赛事分
    self._textMyPoint_B = seekNodeByName(self, "BitmapFontLabel_MyPoint_B", "ccui.TextBMFont")
    self._panelTeamPoint_B = seekNodeByName(self, "Panel_TeamPoint_B", "ccui.Layout") -- 团队赛事分
    self._textTeamPoint_B = seekNodeByName(self, "BitmapFontLabel_TeamPoint_B", "ccui.TextBMFont")
    self._panelTPB_Detail = seekNodeByName(self, "Button_TPB", "ccui.Button") -- 团队赛事分 详 按钮 
    self._panelTeamPoint_A = seekNodeByName(self, "Panel_TeamPoint_A", "ccui.Layout") -- 赛事分
    self._textTeamPoint_A = seekNodeByName(self, "BitmapFontLabel_TeamPoint_A", "ccui.TextBMFont")
    self._panelTPA_Detail = seekNodeByName(self, "Button_TPA", "ccui.Button") -- 我的赛事分 详 按钮 
    self._panelActiveValue = seekNodeByName(self, "Panel_ActiveValue", "ccui.Layout") -- 活跃值
    self._textActiveValue = seekNodeByName(self, "BitmapFontLabel_ActiveValue", "ccui.TextBMFont")
    self._panelAV_Datail = seekNodeByName(self, "Button_AV", "ccui.Button") -- 活跃值 详 按钮 
    self._panelPointParent = seekNodeByName(self, "Button_3", "ccui.Button")

    self._panelAnnouncement = seekNodeByName(self, "Panel_Announcement", "ccui.Layout")
    self._textAnnouncement = seekNodeByName(self._panelAnnouncement, "Text_Announcement", "ccui.Text") -- 公告
    self._btnEdit = seekNodeByName(self._panelAnnouncement, "Button_Edit", "ccui.Button") -- 编辑
    self._imgName = seekNodeByName(self._panelAnnouncement, "Image_Name", "ccui.ImageView")
    self._imgAnnouncement = seekNodeByName(self._panelAnnouncement, "Image_Announcement", "ccui.ImageView")
    self._imgAnnouncement:setVisible(false)

    self._ingCompetition = seekNodeByName(self, "Image_Competition", "ccui.ImageView") -- 比赛标识

    self._reusedListRooms = UIItemReusedListView.extend(seekNodeByName(self, "ListView_RoomList", "ccui.ListView"), UIElemRoomItem)
    self._reusedListRooms:addScrollViewEventListener(handler(self, self._onScroll2))
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListRooms:setScrollBarEnabled(false)

    self:_managerBtn()
    self:_registerCallBack()
end

-- 管理主界面按钮
function UIBigLeagueMain:_managerBtn()
    table.insert(self._rightTopButtons, self._btnManager)
    table.insert(self._rightTopButtons, self._btnMore)
    table.insert(self._rightTopButtons, self._btnRecord)
    table.insert(self._rightTopButtons, self._btnMember)
    table.insert(self._rightTopButtons, self._btnMessage)
    table.insert(self._rightTopButtons, self._btnLeague)
    table.insert(self._rightTopButtons, self._btnLeagueData)
    table.insert(self._rightTopButtons, self._btnLeaderboard)
    table.insert(self._rightTopButtons, self._btnGamePlay)
end

--改变单个按钮的显示和隐藏，改变玩了之后要重排
function UIBigLeagueMain:_changeButtonVisibleState(button, visible)
    -- button:setVisible(visible)
    -- self:_sortAllButtons()
end

--调整按钮位置
function UIBigLeagueMain:_sortAllButtons()
    self:sortPanelButtons(self._rightTopPanel, self._rightTopButtons, 1, 1)
    -- 所有右上角按钮的Y坐标调整
    table.foreach(self._rightTopButtons, function(idx, btn)
        btn:setPositionY(43)
    end)
end

--dir:0从左开始排，1从右开始排
function UIBigLeagueMain:sortPanelButtons(panel, buttons, dir, interval)
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

function UIBigLeagueMain:_registerCallBack()
    -- 为了切换页面刷新活跃值
    bindEventCallBack(self._btnGamePlay, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickGamePlay()
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLeaderboard, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickLeaderboard()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLeague, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickLeague()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMember, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickMember()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMessage, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickMessage()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRecord, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickRecord()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMore, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickMore()
    end , ccui.TouchEventType.ended)
    -- bindEventCallBack(self._btnManager, function ()
    --     self:_sendCCLQueryFireScoreREQ()
    --     self:_onClickMore()
    -- end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreateRoom, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickCreateRoom()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEdit, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickEdit()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, function ()
        self:_onClickClose()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSwitch, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickSwitch()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelTeamPoint_A, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelTPA_Detail, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelTeamPoint_B, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelTPB_Detail, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelMyPoint_C, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelMPC_Detail, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack(self._panelMyPoint_B, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickManagerPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack( self._panelActiveValue, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)
    bindEventCallBack( self._panelAV_Datail, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickPoint()
    end , ccui.TouchEventType.ended)

    bindEventCallBack( self._btnLeagueData, function ()
        self:_sendCCLQueryFireScoreREQ()
        self:_onClickLeagueData()
    end , ccui.TouchEventType.ended)

    -- bindEventCallBack(self._btnPlayFilter,function()
    --     self:_sendCCLQueryFireScoreREQ()
    --     self:_onClickGamePlayFilter()
    -- end , ccui.TouchEventType.ended)
end

-- 刷新活跃值
function UIBigLeagueMain:_sendCCLQueryFireScoreREQ()
    -- if not self._bigLeagueService:getIsSuperLeague() and not self._bigLeagueService:getLeagueData():isManager() then
    --     return
    -- end
    -- self._bigLeagueService:sendCCLQueryFireScoreREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._bigLeagueService:getLeagueData():getClubId())
end

function UIBigLeagueMain:_onClickGamePlay()
    -- 显示玩法界面
    UIManager:getInstance():show("UIBigLeagueGameRuleList")
end

function UIBigLeagueMain:_onClickLeaderboard()
    -- 显示排行榜界面
    local leagueType = self._bigLeagueService:getIsSuperLeague() and 1 or 2
    UIManager:getInstance():show("UIBigLeagueRank", leagueType)
end

function UIBigLeagueMain:_onClickLeague()
    -- 显示联盟界面
    UIManager:getInstance():show("UIBigLeagueList")
end

function UIBigLeagueMain:_onClickMessage()
    -- 显示消息界面
    UIManager:getInstance():show("UIMessageMain", self._bigLeagueService:getLeagueData():getClubId(), self._bigLeagueService:getIsSuperLeague())
end

-- 显示成员界面
function UIBigLeagueMain:_onClickMember()
    -- 搭档显示搭档界面
    if self._bigLeagueService:getLeagueData():isPartner() then
        UIManager:getInstance():show("UIBigLeagueMember", game.service.LocalPlayerService:getInstance():getRoleId(), self._bigLeagueService:getLeagueData():getMemberType().MEMBER_PARTNER)
        return
    end
    -- B或者管理没有搭档时显示该界面
    if self._bigLeagueService:getLeagueData():getPartnerNumber() <= 0 then
        UIManager:getInstance():show("UIBigLeagueMember", 0, self._bigLeagueService:getLeagueData():getMemberType().MEMBER)
        return
    end
    -- B或者管理有搭档时显示该界面
    UIManager:getInstance():show("UIBigLeagueMemberManager")
end

function UIBigLeagueMain:_onClickRecord()
    -- 显示战绩界面
    UIManager:getInstance():show("UIBigLeagueHistory")
end

function UIBigLeagueMain:_onClickMore()
    -- 显示管理（更多）界面
    UIManager:getInstance():show("UIBigLeagueManager")
end

function UIBigLeagueMain:_onClickCreateRoom()
    -- 显示创建房间界面
    UIManager:getInstance():show("UIBigLeagueGameRuleSelect")    
end

function UIBigLeagueMain:_onClickEdit()
    -- 显示公告编辑界面
    UIManager:getInstance():show("UIClubEditNotice", self._bigLeagueService:getLeagueData():getClubId(), self._textAnnouncement:getString())
end

function UIBigLeagueMain:_onClickSwitch()
    UIManager:getInstance():show("UIClubList2")
end

--点击联盟数据 超级盟主A盟主 B展示不同的界面
function UIBigLeagueMain:_onClickLeagueData()
    --为了之后成员数据显示
    if self._bigLeagueService:getIsSuperLeague() then
        UIManager:getInstance():show("UIBigLeagueEventStatistics")  
    else
        UIManager:getInstance():show("UIBigLeagueManagerData")  
    end
end

--点击玩法筛选
function UIBigLeagueMain:_onClickGamePlayFilter()
    UIManager:getInstance():show("UIBigLeagueGameFilter")  
end

function UIBigLeagueMain:_onClickClose()
    self:hideSelf()
    GameFSM.getInstance():enterState("GameState_Lobby")
end

function UIBigLeagueMain:onShow()
    self._isQuery = false
    self._nowNum = 0
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_NAME_CHANGE", handler(self, self._upadtaLeagueName), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_ROOMS_INFO", handler(self, self._updateRooms), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_ROOMS_DETAIL", handler(self, self._updateRoomDetails), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_INFO_SYN", handler(self, self._updateLeagueInfo), self)
    game.service.NoticeMailService:getInstance():addEventListener("EVENT_REDDOT_CHANGED", handler(self, self._updateLeagueInfo), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._updateLeagueInfo), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_MEMBER", handler(self, self._updateLeagueInfo), self)
    game.service.LocalPlayerService.getInstance():addEventListener("EVENT_GOLD_COUNT_CHANGED", handler(self, self._updateLeagueInfo), self)
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_LEAGUE_CARD_INFO", handler(self, self._updateLeagueInfo), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY", handler(self, self._initGamePlayRed), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_INFO", handler(self, self._initLeagueInfo), self)
    game.service.LoginService:getInstance():addEventListener("USER_DATA_RETRIVED", handler(self, self._onRegisterAgain), self)
    self._bigLeagueService:addEventListener("EVENT_GAMEPLAY_FILTER", handler(self, self._updateRoomDetails), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY_REDDOT", function(event)
        self:_setGameFilterRed(event.gamePlayId, event.modifyTime)
    end, self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY_MODIFYTIME",handler(self, self._initGamePlayRed), self)
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_CLUB_INFO_NOTICE_CHANGED", function(event)
        self:_setClubNotice(event.clubId, event.clubNotice)
    end, self)
    self._bigLeagueService:addEventListener("EVENT_FIRESCORE_CHANGE", function ()
        self._textActiveValue:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getFireScore()) * 100) / 100, 2))
    end, self)
    -- 联盟被解散
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_DISBAND", function ()
        self._curLeagueId = 0
    end, self)
    local clubservice = game.service.club.ClubService.getInstance()
    clubservice:getClubManagerService():addEventListener("EVENT_CLUB_INFO_CHANGED",  handler(self, self._upadtaLeagueName), self)

    --FYD 进入联盟页面的时候请求联盟的基本信息
    --大联盟赛事界面(管理界面) 传递的 联盟ID和俱乐部ID都是0
    --进入赛事俱乐部  传递的是联盟的ID 和俱乐部ID
    self._bigLeagueService:sendCCLQueryLeagueREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._bigLeagueService:getLeagueData():getClubId())

    self._imgGamePlayRed:setVisible(false)
    -- self._imgFilterRed:setVisible(false)
    self:_initChangeButtonVisible()
    self:_upadtaLeagueName()
    self:_updateLeagueInfo()
    self:_onShowMarquee()
end

-- 显示公告跑马灯
function UIBigLeagueMain:_onShowMarquee()
    local clubService = game.service.club.ClubService.getInstance()
    local clubId = self._bigLeagueService:getLeagueData():getClubId()
    local club = clubService:getClub(clubId)
    local content = ""
    if club ~= nil and club.data ~= nil then 
        content = club.data.clubNotice 
    else 
        content = "群主和管理暂未发布通知"
    end 
    local data = {
        color = "#80FCFF",
        text = content,
    }
    if content ~= "" then 
        UIManager:getInstance():show("UIMarqueeTips", data)
    end 
end 

--FYD 联盟基本信息返回之后会进入这个方法 CCLQueryLeagueREQ
function UIBigLeagueMain:_initLeagueInfo()
    self:_initChangeButtonVisible()
    self:_upadtaLeagueName()
    self:_updateLeagueInfo()
    --FYD 这里的玩法请求只是为了显示玩法的小红点,如果一个玩法也没有,那么就会有个小红点的提示
    --需求修改：房间列表要加入玩法筛选，所以所有人都要在进入联盟主界面的时候请求玩法列表
    if self._bigLeagueService:getIsSuperLeague() then
        self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    else
        self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId(),self._bigLeagueService:getLeagueData():getClubId())
    end
    --FYD 关注大联盟内的推送数据
    self._curLeagueId = self._bigLeagueService:getLeagueData():getLeagueId()
    self._bigLeagueService:sendCCLFocusOnLeagueRoomREQ(self._bigLeagueService:getLeagueData():getLeagueId(), 1)
end

function UIBigLeagueMain:_initGamePlayRed()
    self._imgGamePlayRed:setVisible(#self._bigLeagueService:getLeagueData():getGameRules() == 0)
    -- self._imgFilterRed:setVisible(self:getIsShowRed())
end

function UIBigLeagueMain:_setGameFilterRed(gameplayID,modifyTime)
    if self._bigLeagueService:getIsSuperLeague() then 
        return
    end
    gameplayID = tostring(gameplayID)
    local tblocalGameData = self._bigLeagueService:getLeagueData():getGamePlay(self._bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法

    if (tblocalGameData[gameplayID] and tblocalGameData[gameplayID].bSelected ) or 
    not tblocalGameData[gameplayID] then  --选中关注的玩法或者新玩法
        -- self._imgFilterRed:setVisible(true)
    end
end

function UIBigLeagueMain:getIsShowRed()
    if self._bigLeagueService:getIsSuperLeague() then 
        return false
    end
    local tbGameData = clone(self._bigLeagueService:getLeagueData():getGameRules())  --盟主设置的所有玩法
    local tblocalGameData = self._bigLeagueService:getLeagueData():getGamePlay(self._bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法
    local bRed = false
    --处理下数据，是否选中，是否是新玩法，是否有小红点,删除的玩法就不会在显示了
    for i, gamePlay in ipairs(tbGameData) do
        local localGame = tblocalGameData[tostring(gamePlay.id)]
        if localGame then 
            bRed = localGame.bRed or (localGame.bSelected and localGame.modifyTime ~= gamePlay.modifyTime) --只要玩家关注的玩法修改了才显示红点
        else
            bRed = true --新玩法红点
        end

        if bRed then 
            break
        end
    end

    return bRed
end

function UIBigLeagueMain:_updateLeagueInfo()
    -- 不知道为什么实际上调用的是大厅的邮件，改为使用邮件更新机制
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self._bigLeagueService:getLeagueData():getClubId())
    local isVisible = self._bigLeagueService:getLeagueData():getHaveApproval()
    if club ~= nil then
        isVisible = club:hasApplicationBadges()
    end

    local noticeService = game.service.NoticeMailService.getInstance()
    if noticeService:isNoticeDotShow() or noticeService:isMailDotShow() then
        self._imgMessageRed:setVisible(true or isVisible)
    else
        self._imgMessageRed:setVisible(false or isVisible)
    end

    self._textRoomCard:setString(kod.util.String.formatMoney(tonumber(self._bigLeagueService:getLeagueData():getCardNum()), 2))
    self._textRoomGold:setString(kod.util.String.formatMoney(tonumber(game.service.LocalPlayerService:getInstance():getGoldAmount()), 2))

    self._textMyPoint_C:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getMyScore()) * 100) / 100, 2))
    self._textMyPoint_B:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getMyScore()) * 100) / 100, 2))
    self._textTeamPoint_B:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getTeamScore()) * 100) / 100, 2))
    self._textTeamPoint_A:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getTeamScore()) * 100) / 100, 2))
    self._textActiveValue:setString(kod.util.String.formatMoney(math.round(tonumber(self._bigLeagueService:getLeagueData():getFireScore()) * 100) / 100, 2))
end

function UIBigLeagueMain:_setClubNotice(clubId, clubNotice)
    if self._bigLeagueService:getIsSuperLeague() then
        --self._textAnnouncement:setString("\n\n绿色娱乐\n\n健康游戏\n\n仅供娱乐\n\n严禁赌博")
        --self._textAnnouncement:setTextHorizontalAlignment(1)
        self._imgName:setVisible(false)
        self._textAnnouncement:setString("")
        self._imgAnnouncement:setVisible(true)
        return
    end
    self._imgName:setVisible(true)
    self._imgAnnouncement:setVisible(false)

    if clubId ~= self._bigLeagueService:getLeagueData():getClubId() then
        return
    end

    if clubNotice == "" then
        clubNotice = "群主和管理暂未发布通知"
    end
    -- 居中显示
    -- self._textAnnouncement:setTextHorizontalAlignment(1)

    self._textAnnouncement:setString(clubNotice)
end

function UIBigLeagueMain:_upadtaLeagueName()
    local clubService = game.service.club.ClubService.getInstance()
    local name = self._bigLeagueService:getIsSuperLeague() and
        string.format("%s\nID:%s",
                clubService:getInterceptString(self._bigLeagueService:getLeagueData():getLeagueName()),
                self._bigLeagueService:getLeagueData():getLeagueId()) or
        string.format("%s\n邀请码:%s", clubService:getInterceptString(clubService:getClubName(self._bigLeagueService:getLeagueData():getClubId())),
        clubService:getClubInvitationCode(self._bigLeagueService:getLeagueData():getClubId()))
    self._textLeagueName:setString(name)
    local x, y = self._textLeagueName:getPosition()
    local size = self._textLeagueName:getVirtualRendererSize()
    self._btnSwitch:setPositionX(x + size.width)

    local club = clubService:getClub(self._bigLeagueService:getLeagueData():getClubId())
    local str = ""
    if club ~= nil and club.data ~= nil then
        str = club.data.clubNotice
    end

    self:_setClubNotice(self._bigLeagueService:getLeagueData():getClubId(), str)
end

-- 初始化按钮显隐
function UIBigLeagueMain:_initChangeButtonVisible()
    local isSuper = self._bigLeagueService:getIsSuperLeague()
    local isManager = self._bigLeagueService:getLeagueData():isManager()
    local isPart = self._bigLeagueService:getLeagueData():isPartner()
    -- 超级盟主 盟主  成员
    self._panelRoomCard:setVisible(isSuper)
    self._panelRoomGold:setVisible(false)
    self._btnCreateRoom:setVisible(not isSuper)
    -- self._btnPlayFilter:setVisible(not isSuper)
    self._btnEdit:setVisible(isManager)
    self._btnSwitch:setVisible(not isSuper)
    self._ingCompetition:setVisible(not isSuper)

    self._panelMyPoint_C:setVisible(not isSuper and not isManager and not isPart)
    self._panelMyPoint_B:setVisible(isManager or isPart)
    self._panelTeamPoint_B:setVisible(isManager or isPart)
    self._panelTeamPoint_A:setVisible(isSuper)
    self._panelActiveValue:setVisible(isSuper or isManager or isPart)

    self:_changeButtonVisibleState(self._btnMore, isSuper)
    self:_changeButtonVisibleState(self._btnRecord, true)
    self:_changeButtonVisibleState(self._btnMessage, true)
    self:_changeButtonVisibleState(self._btnMember, isManager or isPart)
    self:_changeButtonVisibleState(self._btnLeague, isSuper)
    self:_changeButtonVisibleState(self._btnLeaderboard, false)
    self:_changeButtonVisibleState(self._btnLeagueData, isSuper or isManager)
    -- self:_changeButtonVisibleState(self._btnLeagueData, false)
    -- self:_changeButtonVisibleState(self._btnLeaderboard, isSuper or isManager or isPart)
    self:_changeButtonVisibleState(self._btnGamePlay, isSuper) --只有盟主看得見玩法按鈕
    self:_changeButtonVisibleState(self._btnManager, isManager)

    if not isSuper and not isManager and not isPart then
        self._panelPointParent:setOpacity(0)
        self._panelPointParent:setCascadeOpacityEnabled(false)
    else
        self._panelPointParent:setOpacity(255)
    end
end

function UIBigLeagueMain:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService:getInstance():removeEventListenersByTag(self)

    --FYD 大联盟界面隐藏的时候取消关注
    --界面里存储是因为切换俱乐部时也设置这个值，会导致联盟id异常
    if self._curLeagueId ~= nil and self._curLeagueId ~= 0 then
        self._bigLeagueService:sendCCLFocusOnLeagueRoomREQ(self._curLeagueId, 0)
    end
end


function UIBigLeagueMain:_updateRooms()
    self._reusedListRooms:deleteAllItems()
    -- 获取数据
    local rooms = self._bigLeagueService:getLeagueData():getShowRoomList()
    local roomRow = {}
    -- 先添加创建亲友圈的item

    -- 添加牌局
    local idx = 1
    for roomIdx,room in pairs(rooms) do
        room.type = "room"
        room.hasHeadDownload = false
        table.insert(roomRow, room)
        if #roomRow == ITEM_COUNT then
            self._reusedListRooms:pushBackItem(roomRow)
            roomRow = {}
        end
    end

    if #roomRow > 0  then
        self._reusedListRooms:pushBackItem(roomRow)
        roomRow = {}
    end 


    self._bigLeagueService:sendCCLQueryRoomDetailsREQ()
end

function UIBigLeagueMain:_updateRoomDetails()
    local rooms = self._bigLeagueService:getLeagueData():getShowRoomList()
    local roomRow = {}
    -- 先添加创建亲友圈的item

    -- 添加牌局
    local idx = 1
    for roomIdx,room in pairs(rooms) do
        local info = self._bigLeagueService:getLeagueData():getRoomDetailById(room.roomId)
        table.insert(roomRow, info)
        if #roomRow == ITEM_COUNT then
            self._reusedListRooms:updateItem(idx, roomRow)
            roomRow = {}
            idx = idx + 1
        end
    end

    if #roomRow > 0 then
        self._reusedListRooms:updateItem(idx, roomRow)
        idx = idx + 1
        roomRow = {}
    end 

    for i = idx, #self._reusedListRooms._itemDatas do
        self._reusedListRooms:deleteItem(idx)
    end
end

function UIBigLeagueMain:_onScroll2(obj, event)
    local items = obj._spawnItems
    if #items == 0 then
        return 
    end
    
    local id = items[#items]._itemId
    if id ~= nil and id % 7 == 0 and id > self._nowNum then
        self._nowNum = id
        self._bigLeagueService:sendCCLQueryRoomDetailsREQ()
    end
end

function UIBigLeagueMain:_onClickPoint()
    if self._bigLeagueService:getIsSuperLeague() then
        UIManager:getInstance():show("UIBigLeagueScoreMain", 1)
    elseif self._bigLeagueService:getLeagueData():isManager() then 
        UIManager:getInstance():show("UIBigLeagueScoreMain", 2, self._bigLeagueService:getLeagueData():getClubId())
    elseif self._bigLeagueService:getLeagueData():isPartner() then
        UIManager:getInstance():show("UIBigLeagueScoreMain", 4, self._bigLeagueService:getLeagueData():getClubId(), game.service.LocalPlayerService:getInstance():getRoleId())
    else
        UIManager:getInstance():show("UIBigLeagueScoreDetail", 3, 1, self._bigLeagueService:getLeagueData():getClubId(),self._bigLeagueService:getLeagueData():getPartnerId(), game.service.LocalPlayerService:getInstance():getRoleId())
    end
end
function UIBigLeagueMain:_onClickManagerPoint()
    UIManager:getInstance():show("UIBigLeagueScoreDetail", 3, 1, self._bigLeagueService:getLeagueData():getClubId(),self._bigLeagueService:getLeagueData():getPartnerId(), game.service.LocalPlayerService:getInstance():getRoleId())

end

function UIBigLeagueMain:_onRegisterAgain()
    self._bigLeagueService:getLeagueData():clearRoomData()
    self._bigLeagueService:sendCCLFocusOnLeagueRoomREQ(self._curLeagueId, 1)
end

return UIBigLeagueMain