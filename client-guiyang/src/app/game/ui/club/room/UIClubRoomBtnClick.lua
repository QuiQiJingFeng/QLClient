local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubRoomBtnClick = class("UIClubRoomBtnClick")

UIClubRoomBtnClick.btnType =
{
    group = "group", -- 小组
    ranking = "ranking", -- 排行
    message = "Message", -- 消息
    record = "record", -- 战绩
    member = "member", -- 成员
    manager = "manager", -- 管理
    close = "close", -- 关闭
    buy = "buy", -- 购买
    switchingClub = "switchingClub", -- 切换俱乐部
    clubInfo = "clubInfo", -- 俱乐部信息
    task = "task", -- 任务
    notice = "notice", -- 公告
    redPacket = "redPacket", -- 五一福利
    recommend = "recommend", -- 新用户推荐
    activity = "activity", -- 活动
    zhuoji = "zhuoji", -- 捉鸡
    questionnaire = "questionnaire", -- 有奖问答
    turnCard = "turnCard", -- 翻牌
    wxShare = "wxShare", -- 活动:微信邀请（拉新活动）  300006
    shuang11 = "shuang11", -- 双11活动
    leaderBoardActivity = "leaderBoardActivity", -- 排行榜活动
    createRoom = "createRoom", -- 创建房间
    oneKeyCreateRoom = "oneKeyCreateRoom", -- 一键开房
    oneKeyRoomRule = "oneKeyRoomRule", -- 一键开房玩法规则
    oneKeyCreateRoom_2 = "oneKeyCreateRoom_2", -- 一键开房多玩法
    comeback = "comeback", -- 拉新回流
    retain = "retain", -- 俱乐部七日签到
    koi = "koi", -- 锦鲤活动
}

function UIClubRoomBtnClick.onBtnClick(btnType, clubId)
   local switch =
   {
        [UIClubRoomBtnClick.btnType.group] = function ()
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_ClubGroup)
            UIManager:getInstance():show("UIClubGroupMain", clubId)
        end,
        [UIClubRoomBtnClick.btnType.ranking] = function ()
            -- 统计点击俱乐部排行榜钮的事件数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leaderboard)
            UIManager:getInstance():show("UIClubLeaderboardMain", clubId)
            UIManager:getInstance():hide("UIClubRoom")
        end,
        [UIClubRoomBtnClick.btnType.message] = function ()
            UIManager:getInstance():show("UIMessageMain", clubId)
        end,
        [UIClubRoomBtnClick.btnType.record] = function ()
            -- 统计点击战绩按钮的事件数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.ClubRecord);
            UIManager:getInstance():show("UIClubHistoryPage", clubId, "UIClubRoom")
            UIManager:getInstance():hide("UIClubRoom")
        end,
        [UIClubRoomBtnClick.btnType.member] = function ()
            -- 统计点击成员按钮的事件数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.ClubMembers);
            UIManager:getInstance():show("UIClubMemberPage", clubId)
            UIManager:getInstance():hide("UIClubRoom")
        end,
        [UIClubRoomBtnClick.btnType.manager] = function ()
            -- 统计点击管理按钮的事件数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Manager_Click);
            UIManager:getInstance():show("UIClubManager", clubId)
        end,
        [UIClubRoomBtnClick.btnType.close] = function ()
            GameFSM.getInstance():enterState("GameState_Lobby")
        end,
        [UIClubRoomBtnClick.btnType.buy] = function ()
            UIClubRoomBtnClick._onBuyClick(clubId)
        end,
        [UIClubRoomBtnClick.btnType.switchingClub] = function ()
            -- 统计点击切换亲友圈按钮的事件数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.ChangeClub);
            UIManager:getInstance():show("UIClubList2")
        end,
        [UIClubRoomBtnClick.btnType.clubInfo] = function ()
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Head_Click);
            UIManager:getInstance():show("UIClubInfo", clubId)
        end,
        [UIClubRoomBtnClick.btnType.task] = function ()
            -- 统计活动按钮的点击次数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Activity);
            UIManager:getInstance():show("UIClubTask", clubId)
        end,
        [UIClubRoomBtnClick.btnType.notice] = function ()
            -- 统计每日亲友圈公告编辑按钮的事件数
            if UIManager:getInstance():getIsShowing("UIClubRoom") then
                game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_EditNotice);
                local ui = UIManager:getInstance():getUI("UIClubRoom")
                UIManager:getInstance():show("UIClubEditNotice", clubId, ui:getNode().textNotice:getString())
            end
            -- game.ui.UIMessageTipsMgr.getInstance():showTips("亲友圈通知功能暂时关闭使用，给您带来的不便，还请谅解!")
        end,
        [UIClubRoomBtnClick.btnType.redPacket] = function ()
            UIManager:getInstance():show("UIClubRedBox", clubId)
        end,
        [UIClubRoomBtnClick.btnType.recommend] = function ()
            UIManager:getInstance():show("UIClubRecommend", clubId)
        end,
        [UIClubRoomBtnClick.btnType.activity] = function ()
            -- 统计活动按钮的点击次数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Activity_System);
            UIManager:getInstance():show("UIClubActivityMain", clubId)
        end,
        [UIClubRoomBtnClick.btnType.zhuoji] = function ()
            UIManager:getInstance():show("UIClubZhuoJi", clubId)
        end,
        [UIClubRoomBtnClick.btnType.questionnaire] = function ()
            --有奖问答
            game.service.ActivityService.getInstance():sendCACQueryQuestionnaireREQ()
        end,
        [UIClubRoomBtnClick.btnType.turnCard] = function ()
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_CLICK)
	        UIManager:getInstance():show("UITurnCard")
        end,
        [UIClubRoomBtnClick.btnType.wxShare] = function ()
            -- 统计分享功能面板的唤出次数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Hshare);
            game.service.ActivityService.getInstance():sendCACQueryShareRewardsREQ()
        end,
        [UIClubRoomBtnClick.btnType.shuang11] = function ()
            UIManager.getInstance():show("UIShuang11")
        end,
        [UIClubRoomBtnClick.btnType.leaderBoardActivity] = function ()
            UIManager:getInstance():show("UILeaderboardActivityMain")
        end,
        [UIClubRoomBtnClick.btnType.createRoom] = function ()
            local club = game.service.club.ClubService.getInstance():getClub(clubId)
            -- 获取禁用玩法
            local banGameplays = club and club.data and club.data.banGameplays or {}
            UIManager:getInstance():show("UICreateRoom", clubId, ClubConstant:getGamePlayType().normal, banGameplays)
        end,
        [UIClubRoomBtnClick.btnType.oneKeyCreateRoom] = function ()
            UIClubRoomBtnClick._onOneKeyCreateRoom(clubId)
        end,
        [UIClubRoomBtnClick.btnType.oneKeyRoomRule] = function ()
            UIClubRoomBtnClick._onBtnRoomRuleDetails(clubId)
        end,
        [UIClubRoomBtnClick.btnType.oneKeyCreateRoom_2] = function ()
            UIManager:getInstance():show("UIClubRuleSelecting", clubId)
        end,
        [UIClubRoomBtnClick.btnType.comeback] = function ()
            local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
            if service then
                service:sendCACBackInfoClubManagerREQ()
            end
        end,
        [UIClubRoomBtnClick.btnType.retain] = function ()
            local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CLUB_WEEK_SIGN)
            service:sendCACQueryClubWeekSignInfoREQ()
        end,
        [UIClubRoomBtnClick.btnType.koi] = function ()
            local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CLUB_KOI)
            service:sendCACQueryKoiFishActivityInfoREQ({area = service:getAreaId()})
        end,
   }

   switch[btnType]()
end

function UIClubRoomBtnClick._onBuyClick(clubId)
    -- 亲友圈房卡【购买】按钮的点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Buy)
    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    -- 群主添加代理入口
    if club:isManager(localRoleId) then
        local text = config.STRING.UICLUBROOM_STRING_101
        local btnName = "成为代理"
        local talkingData = game.globalConst.StatisticNames.Club_Buy_Bedaili
        if game.service.AgentService.getInstance():getIsAgency() then
            text = config.STRING.UICLUBROOM_STRING_102
            btnName = "代理后台"
            talkingData = game.globalConst.StatisticNames.Club_Buy_Dailihoutai

            game.ui.UIMessageBoxMgr.getInstance():show(text, {btnName}, function()
                -- 亲友圈代理按钮的点击
                game.service.DataEyeService.getInstance():onEvent(talkingData)
                
                game.service.AgentService.getInstance():openWebView(config.AGTSTYLE.club)
            end, nil, false, true)
        else
            game.ui.UIMessageBoxMgr.getInstance():show(text, {btnName}, function()
                -- 亲友圈代理按钮的点击
                game.service.DataEyeService.getInstance():onEvent(talkingData)
                
                game.service.AgentService.getInstance():sendCGQueryAgtInfoREQ()        
            end, nil, false, true)
        end        
    else
        -- 管理显示房卡
        local clubList = game.service.club.ClubService.getInstance():getClubList()
        local idx = clubList:indexOfClub(clubId)
        if idx ~= false then
            if clubList.clubs[idx]:isManager(game.service.LocalPlayerService:getInstance():getRoleId()) then
                game.ui.UIMessageBoxMgr.getInstance():show(string.format(config.STRING.UICLUBROOM_STRING_103, config.GlobalConfig.getShareInfo()[1]), {"确定"})
            else
                game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBROOM_STRING_104, {"确定"})
            end
        end
    end
end

function UIClubRoomBtnClick._onOneKeyCreateRoom(clubId)
    -- 统计玩家看到的一键开房点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.the_button_of_creat_room_quickly);
    local clubService = game.service.club.ClubService.getInstance();
    local presetGamePlays = clubService:getPresetGameplays(clubId)
    local club = clubService:getClub(clubId)
    local managerId = club.info.managerId or 0
    -- 默认显示第一个玩法
    local gamePlay = presetGamePlays[1]

    if clubService:getMaxPresetGamePlay(clubId) ~= 1 then
        local localValid = false
        local id = 0
        local playerInfo = clubService:loadLocalStoragePlayerInfo()
        local presetGamePlayId = playerInfo:getClubInfo(clubId).presetGamePlayId or 0
        if presetGamePlayId == 0 then
            UIManager:getInstance():show("UIClubRuleSelecting", clubId)
            return
        end

        for i, data in ipairs(presetGamePlays) do
            -- 看看本地保存的玩法是否有效
            if presetGamePlayId == i and not data.isInvalid then
                localValid = true
                break
            end
            -- 如果无效，默认调用第一个有效的玩法
            if id == 0 and not data.isInvalid then
                id = i
            end
        end
        -- 这里不用判断id是否等于0，因为有此按钮肯定有一个玩法是有效的（有外部判断）
        if not localValid then
            presetGamePlayId = id
            -- 保存一下玩法
            playerInfo:getClubInfo(clubId).presetGamePlayId = id
            clubService:saveLocalStoragePlayerInfo(playerInfo)
        end

        gamePlay = presetGamePlays[presetGamePlayId]
    end

    -- 创建房间
    game.service.RoomCreatorService.getInstance():createClubRoomReq(0, gamePlay.gameplays, gamePlay.roundType,
        clubId, managerId, false, {}, ClubConstant:getCreateRoomType().CLUB_QUICK_CREATE, {})
end

function UIClubRoomBtnClick._onBtnRoomRuleDetails(clubId)
    -- 隐藏玩法详情时就不用获取模版玩法了
    if UIManager:getInstance():getIsShowing("UIClubRoom") then
        local ui = UIManager:getInstance():getUI("UIClubRoom")
        local panelRoomRuleDetails = ui:getNode().panelOneKeyRoomRule
        local textRoomRuleDetails = ui:getNode().textOneKeyRoomRule
        if panelRoomRuleDetails:isVisible() == false then
            local clubService = game.service.club.ClubService.getInstance();
            local presetGameplays = clubService:getPresetGameplays(clubId)
            local roomSettingInfo = RoomSettingInfo.new(presetGameplays[1].gameplays, presetGameplays[1].roundType)
            local lineTable = {}
            local lineCount = 3
            local zhTable = roomSettingInfo:getZHArray()
            local zhCount = #zhTable
            for startIndex = 1, zhCount, lineCount do
                local endIndex = startIndex + lineCount - 1
                if endIndex > zhCount then
                    endIndex = zhCount
                end
                table.insert(lineTable, table.concat(zhTable, ',' , startIndex, endIndex))
            end
            textRoomRuleDetails:setString(table.concat(lineTable, '\n'))
            local _size = textRoomRuleDetails:getVirtualRendererSize()
            -- 根据文字多少适配文字框大小
            panelRoomRuleDetails:setContentSize(cc.size(_size.width + 40, _size.height + 30))
        end
    
        -- 同一个按钮控制玩法详情的显隐
        textRoomRuleDetails:setVisible(not panelRoomRuleDetails:isVisible())
        panelRoomRuleDetails:setVisible(not panelRoomRuleDetails:isVisible())
    end
end

return UIClubRoomBtnClick