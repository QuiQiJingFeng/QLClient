local ns = namespace("game.service.bigLeague")
local BigLeagueService = class("BigLeagueService")
local BigLeagueData = require("app.game.service.bigLeague.BigLeagueData")
ns.BigLeagueService = BigLeagueService

function BigLeagueService:ctor()
    -- 绑定事件系统
    cc.bind(self, "event");

    self._bigLeagueServiceId = - 1
    self._isSuperLeague = false
    self._gameplayId = 0
    self._isSuperLeagueId = 0
    self._leagueData = BigLeagueData.new()
    self._isOpenGps = false
end

function BigLeagueService:getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getBigLeagueService()
    end

    return nil
end

function BigLeagueService:isOpenGps()
    return  self._isOpenGps
end

function BigLeagueService:setOpenGps(openGps)
    self._isOpenGps = openGps
    Logger.debug("setOpenGps =================== "..tostring(openGps))
end

function BigLeagueService:getLeagueData()
    return self._leagueData
end

function BigLeagueService:getGamePlayId()
    return  self._gameplayId
end

function BigLeagueService:setId(roleId, bigLeagueServiceId)
    self._roleId = roleId
    self._bigLeagueServiceId = bigLeagueServiceId
end

function BigLeagueService:getBigLeagueServiceId()
    return self._bigLeagueServiceId
end

-- 判断当前联盟是不是A，这里特别注意，在进入大联盟的时候加了一个判断，A的入口就传true，B、C入口传false
function BigLeagueService:setIsSuperLeague(isSuperLeague)
    self._isSuperLeague = isSuperLeague
end

function BigLeagueService:getIsSuperLeague()
    return self._isSuperLeague
end

-- 大厅判断是否显示超级盟主入口
function BigLeagueService:getIsSuperLeagueId()
    Logger.debug("BigLeagueService:getIsSuperLeagueId self._isSuperLeagueId = " .. self._isSuperLeagueId)
    return self._isSuperLeagueId ~= 0
end

function BigLeagueService:_showCommonTips(result)
    if result == net.ProtocolCode.CLC_ERROR_CODE_CLUB_SEALED then
        game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(result), {"确定"})
    elseif result == net.ProtocolCode.CREATE_LEAGUE_ROOM_FAIL_PAUSE_GAME then
        game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(result), {"确定"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(result))
    end
end

function BigLeagueService:initialize()
    local requestManager = net.RequestManager.getInstance()

    requestManager:registerResponseHandler(net.protocol.CLCLeagueInfoSYN.OP_CODE, self, self._onCLCLeagueInfoSYN)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueRES.OP_CODE, self, self._onCLCQueryLeagueRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueGameplayRES.OP_CODE, self, self._onCLCQueryLeagueGameplayRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyLeagueGameplayRES.OP_CODE, self, self._onCLCModifyLeagueGameplayRES)
    requestManager:registerResponseHandler(net.protocol.CLCDeleteLeagueGameplayRES.OP_CODE, self, self._onCLCDeleteLeagueGameplayRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueRankRES.OP_CODE, self, self._onCLCQueryLeagueRankRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeaguesRES.OP_CODE, self, self._onCLCQueryLeaguesRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyLeagueRES.OP_CODE, self, self._onCLCModifyLeagueRES)
    requestManager:registerResponseHandler(net.protocol.CLCPauseGameRES.OP_CODE, self, self._onCLCPauseGameRES)
    requestManager:registerResponseHandler(net.protocol.CLCRestoreGameRES.OP_CODE, self, self._onCLCRestoreGameRES)
    requestManager:registerResponseHandler(net.protocol.CLCForceQuitGameRES.OP_CODE, self, self._onCLCForceQuitGameRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryTrendRES.OP_CODE, self, self._onCLCQueryTrendRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryApprovalRES.OP_CODE, self, self._onCLCQueryApprovalRES)
    requestManager:registerResponseHandler(net.protocol.CLCApprovalRES.OP_CODE, self, self._onCLCApprovalRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyLeagueNameRES.OP_CODE, self, self._onCLCModifyLeagueNameRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryJoinLeagueRES.OP_CODE, self, self._onCLCQueryJoinLeagueRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryMembersRES.OP_CODE, self, self._onCLCQueryMembersRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyMemberScoreRES.OP_CODE, self, self._onCLCModifyMemberScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCPauseMemberGameRES.OP_CODE, self, self._onCLCPauseMemberGameRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueRoomHistoryRES.OP_CODE, self, self._onCLCQueryLeagueRoomHistoryRES)
    requestManager:registerResponseHandler(net.protocol.CLCCreateLeagueRoomRES.OP_CODE, self, self._onCLCCreateLeagueRoomRES)
    requestManager:registerResponseHandler(net.protocol.CLCFocusOnLeagueRoomRES.OP_CODE, self, self._onCLCFocusOnLeagueRoomRES)
    requestManager:registerResponseHandler(net.protocol.CLCNotifyLeagueRoomSYN.OP_CODE, self, self._onCLCNotifyLeagueRoomSYN)
    requestManager:registerResponseHandler(net.protocol.CLCShowStartTableRES.OP_CODE, self, self._onCLCShowStartTableRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueNameRES.OP_CODE, self, self._onCLCQueryLeagueNameRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryRoomDetailsRES.OP_CODE, self, self._onCLCQueryRoomDetailsRES)
    requestManager:registerResponseHandler(net.protocol.CLCClickLikeRES.OP_CODE, self, self._onCLCClickLikeRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueScoreRES.OP_CODE, self, self._onCLCQueryLeagueScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryScoreRecordRES.OP_CODE, self, self._onCLCQueryScoreRecordRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryClubRecordRES.OP_CODE, self, self._onCLCQueryClubRecordRES)
    requestManager:registerResponseHandler(net.protocol.CLCConversionScoreRES.OP_CODE, self, self._onCLCConversionScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryFireScoreRES.OP_CODE, self, self._onCLCQueryFireScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueMatchActivityInfoRES.OP_CODE, self, self._onCLCQueryLeagueMatchActivityInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryLeagueClubActivityInfoRES.OP_CODE, self, self._onCLCQueryLeagueClubActivityInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCQueryClubMemberActivityInfoRES.OP_CODE, self, self._onCLCQueryClubMemberActivityInfoRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyLeagueGpsRuleRES.OP_CODE, 	  self, self._onModifyLeagueGpsRuleRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyGamePlayClubFireScoreRES.OP_CODE,self, self._onCLCModifyGamePlayClubFireScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCOrderPartnerRES.OP_CODE, self, self._onCLCOrderPartnerRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyPartnerScoreRES.OP_CODE, self, self._onCLCModifyPartnerScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCInvitePartnerMemberRES.OP_CODE,self, self._onCLCInvitePartnerMemberRES)
    requestManager:registerResponseHandler(net.protocol.CLCModifyGamePlayPartnerFireScoreRES.OP_CODE, self, self._onCLCModifyGamePlayPartnerFireScoreRES)
    requestManager:registerResponseHandler(net.protocol.CLCLeagueGameplayInfoSYN.OP_CODE,self, self._onCLCLeagueGamePlayInfoSYN)
    requestManager:registerResponseHandler(net.protocol.CLCQueryGameplayStatisticsRES.OP_CODE,self, self._onCLCQueryGameplayStatisticsRES)
end

-- 联盟推送类型
local LeagueSynType =
{
    LOGIN = 1, -- 登录
    APPROVAL = 2, -- 新的审批
    MODIFY_SCORE = 3, -- 修改比赛分
    CREATE_LEAGUE = 4, -- 创建联盟
    MODIFY_CLUB_LEAGUE = 5, -- 修改联盟分数
    LOTTERY = 6, -- 牌局结束抽奖
    DELETE_LEAGUE = 7, -- 解散联盟
    BE_ORDERED_ASSISTANT = 8, -- 玩家职位变动
    CONVERSION = 9, -- 活跃值转换
    PARTNER_NUMBER = 10, -- 搭档人数
}

function BigLeagueService:_onCLCLeagueInfoSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    --FYD:登录之后推送联盟ID和审批消息是否存在的bool变量,无论是不是有大联盟都会推送,如果玩家没有大联盟,那么联盟ID为0
    if protocol.type == LeagueSynType.LOGIN then
        self._isSuperLeagueId = protocol.leagueId
        Logger.debug("_onCLCLeagueInfoSYN protocol.type == LeagueSynType.LOGIN protocol.leagueId = " .. protocol.leagueId)
        self._leagueData:setHaveApproval(protocol.haveApproval)
        -- 有时候我们显示了UIMain然后服务器推送，这是需要刷新一下UIMain
        if UIManager:getInstance():getIsShowing("UIMain") then
            self:dispatchEvent({name = "EVENT_CREATE_LEAGUE"})
        end
    elseif protocol.type == LeagueSynType.APPROVAL then   --FYD 当有新的审批消息的时候回接收到这个推送
        self._leagueData:setHaveApproval(protocol.haveApproval)
    elseif protocol.type == LeagueSynType.MODIFY_SCORE then  --FYD 通知我的赛事分更新
        -- 只更新当前所在的俱乐部
        if protocol.clubId == self._leagueData:getClubId() then
            self._leagueData:setMyScore(protocol.myScore)
        end
    elseif protocol.type == LeagueSynType.CREATE_LEAGUE then
        self._isSuperLeagueId = protocol.leagueId
        if UIManager:getInstance():getIsShowing("UIMain") then
            self:dispatchEvent({name = "EVENT_CREATE_LEAGUE"})
        end
    elseif protocol.type == LeagueSynType.MODIFY_CLUB_LEAGUE then
        if protocol.clubId == self._leagueData:getClubId() then
            self._leagueData:setTeamScore(protocol.myScore)
        end
    elseif protocol.type == LeagueSynType.DELETE_LEAGUE then
        -- 如果该玩家是A，就需要把赛事入口隐藏，赛事id清空
        if self._isSuperLeagueId == protocol.leagueId then
            self._isSuperLeague = false
            self._isSuperLeagueId = 0
            if UIManager:getInstance():getIsShowing("UIMain") then
                self:dispatchEvent({name = "EVENT_CREATE_LEAGUE"})
            end
        end
        -- B、C如果在当前联盟内时要清除本地缓存的联盟id，强制退出联盟
        if self._leagueData:getLeagueId() == protocol.leagueId then
            self._leagueData:setLeagueId(0) 
            local lastState = GameFSM.getInstance():getCurrentState().class.__cname
            if lastState == "GameState_League" then
                self:dispatchEvent({name = "EVENT_LEAGUE_DISBAND"})
                game.ui.UIMessageBoxMgr.getInstance():show("赛事被解散" , {"确定"}, function ()
                    GameFSM.getInstance():enterState("GameState_Lobby")
                end, function()end, true)
            end
        end
    elseif protocol.type == LeagueSynType.LOTTERY then
        self._leagueData:setLotteryGold(protocol.myScore)
    elseif protocol.type == LeagueSynType.BE_ORDERED_ASSISTANT then
        -- 通知玩家权限变动
        if protocol.clubId == self._leagueData:getClubId() then
            self:dispatchEvent({name = "EVENT_LEAGUE_MEMBER_TITLE_CHANGE"})
        end
    elseif protocol.type == LeagueSynType.CONVERSION then
    elseif protocol.type == LeagueSynType.PARTNER_NUMBER then
        if self._leagueData:getLeagueId() == protocol.leagueId then
            self._leagueData:setPartnerNumber(tonumber(protocol.myScore))
        end
    else
        Logger.debug("CLCLeagueInfoSYN protocol.type = %s", protocol.type)
    end

        self:dispatchEvent({name = "EVENT_LEAGUE_INFO_SYN"})
end

-- 请求联盟信息
function BigLeagueService:sendCCLQueryLeagueREQ(leagueId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueREQ, self._bigLeagueServiceId)
    if self:getIsSuperLeague() then
        request:getProtocol():setData(0, clubId)
    else
        request:getProtocol():setData(leagueId, clubId)
    end
    request.clubId = clubId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    Logger.dump(protocol, "_onCLCQueryLeagueRES~~~~~~~~~~")
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_SUCCESS then
        protocol.goldCount = game.service.LocalPlayerService:getInstance():getGoldAmount()
        self._leagueData:setBaseInfo(protocol)
        self._leagueData:setClubId(request.clubId)
        self:dispatchEvent({name = "EVENT_LEAGUE_INFO"})
    elseif protocol.result == net.ProtocolCode.DO_NOT_HAVE_LEAGUE then
        UIManager:getInstance():show("UIBigLeagueCreate")
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求查看大联盟玩法
function BigLeagueService:sendCCLQueryLeagueGameplayREQ(leagueId, clubId, partnerId, removeZeroCost, type, isGamePlayQuery)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueGameplayREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId, removeZeroCost, self._leagueData:getTitle(), type)
    request.isGamePlayQuery = isGamePlayQuery
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueGameplayRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_GAMEPLAY_SUCCESS then
        if response:getRequest().isGamePlayQuery then 
            self._leagueData:setClubFireScores(protocol)
            dump(protocol.gameplays,'_onCLCQueryLeagueGameplayRES=================chen',1000)
            self:dispatchEvent({name = "EVENT_CLUB_FIRE_CHANGE"})
        else 
            self._leagueData:setGameRules(protocol)
            self:setOpenGps(protocol.isOpenGPS)
            self:dispatchEvent({name = "EVENT_LEAGUE_GAMEPLAY", id = -1})
        end 
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求修改大联盟玩法
function BigLeagueService:sendCCLModifyLeagueGameplayREQ(leagueId, id, gameplay)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyLeagueGameplayREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, id, gameplay)
    request.gameplay = gameplay
    request.leagueId = leagueId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyLeagueGameplayRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_LEAGUE_GAMEPLAY_SUCCESS then
        self:sendCCLQueryLeagueGameplayREQ(request.leagueId)
        --self._leagueData:changeOneRule(protocol.id, request.gameplay)
        --self:dispatchEvent({name = "EVENT_LEAGUE_GAMEPLAY", id = protocol.id, isDestroy = false})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求删除大联盟玩法
function BigLeagueService:sendCCLDeleteLeagueGameplayREQ(leagueId, id)
    local request = net.NetworkRequest.new(net.protocol.CCLDeleteLeagueGameplayREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, id)
    request.id = id
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCDeleteLeagueGameplayRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.DELETE_LEAGUE_GAMEPLAY_SUCCESS then
        self._leagueData:deleteOneRule(request.id)
        self:dispatchEvent({name = "EVENT_LEAGUE_GAMEPLAY", id = request.id, isDestroy = true})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求查看大联盟排行榜
function BigLeagueService:sendCCLQueryLeagueRankREQ(leagueId, clubId, operatorType, date)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueRankREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, operatorType, date)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueRankRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_RANK_SUCCESS then
        local obj = request:getProtocol():getProtocolBuf()
        local day = game.service.TimeService:getInstance():getDaysAgo(request:getProtocol():getProtocolBuf().date)
        self._leagueData:setRankInfo(protocol,  day)
        self:dispatchEvent({name = "EVENT_LEAGUE_RANK"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求点赞
function BigLeagueService:sendCCLClickLikeREQ(leagueId, clubId, date, like)
    local request = net.NetworkRequest.new(net.protocol.CCLClickLikeREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, date, like)
    request.clubId = clubId
    request.like = like
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCClickLikeRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CLICK_LIKE_SUCCESS then
        local day = game.service.TimeService:getInstance():getDaysAgo(request:getProtocol():getProtocolBuf().date)
        self._leagueData:changeRankInfo(request.clubId, request.like, day)
        self:dispatchEvent({name = "EVENT_LIKE_CHANGE", clubId = request.clubId, like = request.like})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求查看联盟列表
function BigLeagueService:sendCCLQueryLeaguesREQ(leagueId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeaguesREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeaguesRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUES_SUCCESS then
        self._leagueData:setLeaguesInfo(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_LEAGUEINFO", clubId = 0})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求修改联盟信息
function BigLeagueService:sendCCLModifyLeagueREQ(leagueId, clubId, currentScore, fireScoreRate, remark, isRemarks)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyLeagueREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, currentScore, fireScoreRate, remark)
    request.league =
    {
        clubId = clubId,
        currentScore = currentScore,
        fireScoreRate = fireScoreRate,
        remark = remark,
    }
    request.isRemarks = isRemarks or false
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyLeagueRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    local isSuccess = protocol.result == net.ProtocolCode.MODIFY_LEAGUE_SUCCESS
    event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = not isSuccess, isDestroy = isSuccess})
    if isSuccess then
        -- 因为修改备注也是这条消息，所以要做一个区分
        if request.isRemarks == false then
            local text = string.format("团队调整分数%s，调整后分数为%s", request.league.currentScore, math.round(tonumber(protocol.currentScore) * 100) / 100)
            game.ui.UIMessageTipsMgr.getInstance():showTips(text)
        end

        request.league.currentScore = tonumber(protocol.currentScore)
        self._leagueData:changeLeagueInfo(request.league)
        self:dispatchEvent({name = "EVENT_LEAGUE_LEAGUEINFO", clubId = request.league.clubId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求强制退赛
function BigLeagueService:sendCCLForceQuitGameREQ(leagueId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLForceQuitGameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId)
    request.clubId = clubId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCForceQuitGameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.FORCE_QUIT_GAME_SUCCESS then
        self._leagueData:setLeagueStop(request.clubId)
        self:dispatchEvent({name = "EVENT_LEAGUE_LEAGUEINFO", clubId = request.clubId})
    elseif protocol.result == net.ProtocolCode.FORCE_QUIT_GAME_FAIL_IN_GAME then
        game.ui.UIMessageBoxMgr.getInstance():show("该团队还有成员在赛事内，请联系队长确认！", {"确定", "取消"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求暂停比赛
function BigLeagueService:sendCCLPauseGameREQ(leagueId, clubId, name)
    local request = net.NetworkRequest.new(net.protocol.CCLPauseGameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId)
    request.clubId = clubId
    request.name = name
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCPauseGameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.PAUSE_GAME_SUCCESS then
        local str = string.format("你已成功将%s暂停比赛", request.name)
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
        self._leagueData:setLeaguePause(request.clubId)
        self:dispatchEvent({name = "EVENT_LEAGUE_LEAGUEINFO", clubId = request.clubId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求恢复比赛
function BigLeagueService:sendCCLRestoreGameREQ(leagueId, clubId, name)
    local request = net.NetworkRequest.new(net.protocol.CCLRestoreGameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId)
    request.clubId = clubId
    request.name = name
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCRestoreGameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.RESOTRE_GAME_SUCCESS then
        local str = string.format("你已成功将%s恢复比赛", request.name)
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
        self._leagueData:setLeagueRestore(request.clubId)
        self:dispatchEvent({name = "EVENT_LEAGUE_LEAGUEINFO", clubId = request.clubId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求联盟动态
function BigLeagueService:sendCCLQueryTrendREQ(leagueId, clubId, title)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryTrendREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, title)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryTrendRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_TREND_SUCCESS then
        self._leagueData:setTrendInfo(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_TREND"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求审批列表
function BigLeagueService:sendCCLQueryApprovalREQ(leagueId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryApprovalREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryApprovalRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_APPROVAL_SUCCESS then
        self._leagueData:setApprovalInfo(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_APPROVAL"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求操作审批
function BigLeagueService:sendCCLApprovalREQ(leagueId, clubId, agree, clubName)
    local request = net.NetworkRequest.new(net.protocol.CCLApprovalREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, agree)
    request.approval =
    {
        clubId = clubId,
        agree = agree,
    }
    request.clubName = clubName
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCApprovalRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.APPROVAL_SUCCESS then
        self._leagueData:setOperateApproval(request.approval)
        self:dispatchEvent({name = "EVENT_LEAGUE_APPROVAL"})
        local str = ""
        if request.approval.agree then
            str = string.format("您已批准%s%s加入比赛", request.clubName, config.STRING.COMMON)
        else
            str = string.format("您已拒绝%s%s加入比赛", request.clubName, config.STRING.COMMON)
        end
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求修改联盟名称
function BigLeagueService:sendCCLModifyLeagueNameREQ(leagueId, name)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyLeagueNameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, name)
    request.leagueName = name
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyLeagueNameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_LEAGUE_NAME_SUCCESS then
        self._leagueData:setLeagueName(request.leagueName)
        self:dispatchEvent({name = "EVENT_LEAGUE_NAME_CHANGE"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求参赛大联盟
function BigLeagueService:sendCCLQueryJoinLeagueREQ(leagueId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryJoinLeagueREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryJoinLeagueRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local isSuccess = protocol.result == net.ProtocolCode.QUERY_JOIN_LEAGUE_SUCCESS
    event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = not isSuccess, isDestroy = isSuccess})
    if isSuccess then
        game.ui.UIMessageTipsMgr.getInstance():showTips("申请成功")
    elseif protocol.result == net.ProtocolCode.QUERY_JOIN_LEAGUE_FAIL_CONFLICT then
        if protocol.conflictClubName ~= nil and protocol.conflictClubName ~= "" then
            local str = string.format("检测到您的%s%s已加入%s团队，暂时无法加入除%s团队以外的其他团队", protocol.conflictClubName, config.STRING.COMMON, protocol.conflictLeagueName, protocol.conflictLeagueName)
            game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定"})
        end
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求成员信息
function BigLeagueService:sendCCLQueryMembersREQ(leagueId, clubId, days, type, title, partnerId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryMembersREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, days, type, title, partnerId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryMembersRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_MEMBERS_SUCCESS then
        self._leagueData:setMemberInfo(protocol)
        self._leagueData:setCurrentScore(tonumber(protocol.currentScore))
        self:dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = 0})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求调整玩家分数
function BigLeagueService:sendCCLModifyMemberScoreREQ(leagueId, clubId, roleId, type, score)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyMemberScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, roleId, type, score)
    request.member =
    {
        clubId = clubId,
        roleId = roleId,
        score = score,
    }
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyMemberScoreRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_MEMBER_SUCCESS then
        local text = string.format("玩家调整分数%s，调整后分数为%s", request.member.score, math.round(tonumber(protocol.memberScore) * 100) / 100)
        game.ui.UIMessageTipsMgr.getInstance():showTips(text)

        request.member.score = tonumber(protocol.memberScore)
        self._leagueData:setMemberScore(request.member)
        self._leagueData:setCurrentScore(tonumber(protocol.currentScore))
        self._leagueData:setTeamScore(tonumber(protocol.currentScore))
        self:dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = request.member.roleId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求暂停成员参赛
function BigLeagueService:sendCCLPauseMemberGameREQ(leagueId, clubId, roleId, type, pause)
    local request = net.NetworkRequest.new(net.protocol.CCLPauseMemberGameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, roleId, type, pause)
    request.roleId = roleId
    request.pause = pause
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCPauseMemberGameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.PAUSE_MEMBER_SUCCESS then
        game.ui.UIMessageTipsMgr.getInstance():showTips("设置成功")
        self._leagueData:setIsPauseGame(request.roleId, request.pause)
        self:dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = request.roleId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 联盟战绩
function BigLeagueService:sendCCLQueryLeagueRoomHistoryREQ(leagueId, clubId, start, num, queryTime, minScore, onlyAbnormalRoom, queryRoleId, roomId, bSearchRoomID)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueRoomHistoryREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, start, num, queryTime, minScore, onlyAbnormalRoom, queryRoleId, roomId)
    request.bSearchRoomID = bSearchRoomID --是否是房间号查询
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueRoomHistoryRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest()
    if protocol.result == net.ProtocolCode.CLC_QUERY_LEAGUE_ROOM_HISTORY_SUCCESS then
        if not (request.bSearchRoomID and not(protocol.roomRecords)) then  --如果是房间号查询且没有查询相应战绩，给出提示，界面不刷新显示
            self._leagueData:setRoomHistorys(protocol)
        end
        self:dispatchEvent({name = "EVENT_LEAGUE_ROOMHISTORY",bSearchByRoomID = request.bSearchRoomID,roomRecords = protocol.roomRecords})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求创建联盟房间
function BigLeagueService:sendCCLCreateLeagueRoomREQ(leagueId, leaderId, clubId, gameplayId, createType)
    local request = net.NetworkRequest.new(net.protocol.CCLCreateLeagueRoomREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, leaderId, clubId, gameplayId, createType)
    request.gameplayId = gameplayId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCCreateLeagueRoomRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CREATE_LEAGUE_ROOM_SUCCESS then
        self._gameplayId = request.gameplayId
        game.service.RoomCreatorService.getInstance():enterRoom(protocol.battleId, protocol.roomId, game.globalConst.JOIN_ROOM_STYLE.LeagueCreateRoom, nil, true)
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 关注联盟房间
function BigLeagueService:sendCCLFocusOnLeagueRoomREQ(leagueId, optype)
    if optype == 0 then
        self._leagueData:clearRoomData()
    end
    local request = net.NetworkRequest.new(net.protocol.CCLFocusOnLeagueRoomREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, optype)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCFocusOnLeagueRoomRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    
    -- dump(protocol, "_onCLCFocusOnLeagueRoomRES~~~~~~~~~")
    if protocol.result == net.ProtocolCode.FOCUS_ON_LEAGUE_ROOM_SUCCESS then
        self._leagueData:setRoomList(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_ROOMS_INFO"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求房间详细信息
function BigLeagueService:sendCCLQueryRoomDetailsREQ()
    local rooms = self._leagueData:getNoDetailRooms()
    -- dump(rooms, "_onCLCQueryRoomDetailsRES~~~~~~~~~~~")
    if #rooms == 0 then
        return
    end
    local request = net.NetworkRequest.new(net.protocol.CCLQueryRoomDetailsREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(self._leagueData:getLeagueId(), rooms)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryRoomDetailsRES(response)    
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol, "_onCLCQueryRoomDetailsRES~~~~~~~~~~~")
    if protocol.result == net.ProtocolCode.QUERY_ROOM_DETAILS_SUCCESS then
        self._leagueData:setRoomDetails(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_ROOMS_DETAIL", rooms = protocol.tableInfos})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 通知客户端变化的联盟房间
function BigLeagueService:_onCLCNotifyLeagueRoomSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol, "_onCLCNotifyLeagueRoomSYN~~~~~~~~~")
    if protocol.leagueId == self._leagueData:getLeagueId() then
        self._leagueData:setRoomDetails(protocol)
    end
    self:dispatchEvent({name = "EVENT_LEAGUE_ROOMS_DETAIL", rooms = protocol.tableInfos})
end

-- 是否显示开局牌桌
function BigLeagueService:sendCCLShowStartTableREQ(leagueId, show)
    local request = net.NetworkRequest.new(net.protocol.CCLShowStartTableREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, show)
    request.show = show
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCShowStartTableRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.SHOW_START_TABLE_SUCCESS then
        self._leagueData:setIsRoomOpening(request.show)
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求大联盟名称
function BigLeagueService:sendCCLQueryLeagueNameREQ(leagueId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueNameREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId)
    request.leagueId = leagueId
    request.clubId = clubId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueNameRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_NAME_SUCCESS then
        local str = string.format("确认申请加入%s赛事？%s转变为赛事状态后，原有的房卡和成员数据不变，战绩将被清空", protocol.leagueName, config.STRING.COMMON)
        game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定", "取消"}, function ()
            self:sendCCLQueryJoinLeagueREQ(request.leagueId, request.clubId)
        end)
    else
        self:_showCommonTips(protocol.result)
    end
end

--请求积分详情
function BigLeagueService:sendCCLQueryLeagueScoreREQ(leagueId, clubId, partnerId, nType)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId, nType)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueScoreRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol, "_onCLCQueryLeagueScoreRES~~")
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_SCORE_SUCCESS then
        self._leagueData:setLeagueScore(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUE_SCORE"})
    else
        self:_showCommonTips(protocol.result)
    end
end

--请求赛事分变动记录
function BigLeagueService:sendCCLQueryScoreRecordREQ(leagueId, clubId, partnerId, roleId, nType, scoreType, date, endDate)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryScoreRecordREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId, roleId, nType, scoreType, date, endDate)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryScoreRecordRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_SCORE_RECORD_SUCCESS then
        local day = game.service.TimeService:getInstance():getDaysAgo(request:getProtocol():getProtocolBuf().date)
        self._leagueData:setScoreRecord(protocol, day)
        self:dispatchEvent({name = "EVENT_SCORE_RECORD"})
    else
        self:_showCommonTips(protocol.result)
    end
end

--请求成员详情
function BigLeagueService:sendCCLQueryClubRecordREQ(leagueId, clubId, partnerId, nType, queryType)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryClubRecordREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId, nType, queryType)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryClubRecordRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_CLUB_RECORD_SUCCESS then
        self._leagueData:setMemberRecord(protocol, request:getProtocol():getProtocolBuf().clubId, request:getProtocol():getProtocolBuf().partnerId)
        self:dispatchEvent({name = "EVENT_MEMBER_RECORD"})
    else
        self:_showCommonTips(protocol.result)
    end
end
--请求积分记录
function BigLeagueService:sendCCLConversionScoreREQ(leagueId, clubId, partnerId )
    local request = net.NetworkRequest.new(net.protocol.CCLConversionScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId )
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCConversionScoreRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.CONVERSION_SCORE_SUCCESS then
        self._leagueData:setTeamScore(tonumber(protocol.afterScore))
        self._leagueData:setFireScore(0)
        self._leagueData:getScoreData():setFireScore(0)
        self:dispatchEvent({name = "EVENT_LEAGUE_INFO"})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求活跃值
function BigLeagueService:sendCCLQueryFireScoreREQ(leagueId, clubId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryFireScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId )
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryFireScoreRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_FIRE_SCORE_SUCCESS then
        self._leagueData:setFireScore(tonumber(protocol.fireScore))
        self:dispatchEvent({name = "EVENT_FIRESCORE_CHANGE"})
    else
        self:_showCommonTips(protocol.result)
    end
end
---请求盟主界面数据
function BigLeagueService:sendCCLQueryLeagueMatchActivityInfoREQ(leagueId)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueMatchActivityInfoREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueMatchActivityInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_MATCH_ACTIVITY_INFO_SUCCESS then
        self._leagueData:setMatchActivityInfo(protocol)
        self:dispatchEvent({name = "EVENT_MATCH_ACTIVITY"})
    else
        self:_showCommonTips(protocol.result)
    end
end

---请求群主界面数据
function BigLeagueService:sendCCLQueryLeagueClubActivityInfoREQ(leagueId, clubId,date)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryLeagueClubActivityInfoREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, date)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryLeagueClubActivityInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_LEAGUE_CLUB_ACTIVITY_INFO_SUCCESS then
        self._leagueData:setSuperLeagueData(protocol)
        self:dispatchEvent({name = "EVENT_SUPERLEAGUE_DATA"})
    else
        self:_showCommonTips(protocol.result)
    end
end

--请求成员数据
function BigLeagueService:sendCCLQueryClubMemberActivityInfoREQ(leagueId, clubId, date)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryClubMemberActivityInfoREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId , date)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryClubMemberActivityInfoRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_CLUB_MEMBER_ACTIVITY_INFO_SUCCESS then
        self._leagueData:setLeagueManagerMemberData(protocol)
        self:dispatchEvent({name = "EVENT_LEAGUEMANAGER_DATA"})
    else
        self:dispatchEvent({name = "EVENT_GPS_STATE_FAILED"})
        self:_showCommonTips(protocol.result)
    end
end


-- 请求GPS修改
function BigLeagueService:sendModifyLeagueGpsRuleREQ(leagueId, isOpenGps)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyLeagueGpsRuleREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, isOpenGps )
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onModifyLeagueGpsRuleRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_LEAGUE_GPS_RULE_SUCCESS then
        local request = response:getRequest():getProtocol():getProtocolBuf()
        if request.isOpenGps then
            self:setOpenGps(request.isOpenGps)
        end
    else
        self:dispatchEvent({name = "EVENT_GPS_STATE_FAILED"})
        self:_showCommonTips(protocol.result)
    end
end

--请求修改联盟中俱乐部活跃值赠送
function BigLeagueService:sendCCLModifyGamePlayClubFireScoreREQ(leagueId, clubId, gameplayId,startScore,endScore,changeClubFireScore,playerCount)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyGamePlayClubFireScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId ,gameplayId,startScore,endScore,changeClubFireScore,playerCount)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyGamePlayClubFireScoreRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_GAME_PLAY_CLUB_FIRE_SCORE_SUCCESS then
        self._leagueData:setClubFireScores(protocol)
        self:dispatchEvent({name = "EVENT_CLUB_FIRE_CHANGE"})
    else 
        self:_showCommonTips(protocol.result)
    end
end
-- 请求任命或撤职搭档
function BigLeagueService:sendCCLOrderPartnerREQ(leagueId, clubId, memberId, order)
    local request = net.NetworkRequest.new(net.protocol.CCLOrderPartnerREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, memberId, order)
    request.roleId = memberId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCOrderPartnerRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.ORDER_PARTNER_SUCCESS then
        game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():deleteMember(request.roleId)
        game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = request.roleId})
        game.ui.UIMessageTipsMgr.getInstance():showTips("设置成功")
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求给搭档调整分数
function BigLeagueService:sendCCLModifyPartnerScoreREQ(leagueId, clubId, memberId, type, score)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyPartnerScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, memberId, type, score)
    request.member =
    {
        clubId = clubId,
        roleId = memberId,
        score = score,
    }
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyPartnerScoreRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_PARTNER_SCORE_SUCCESS then
        local text = string.format("玩家调整分数%s，调整后分数为%s", request.member.score, math.round(tonumber(protocol.memberScore) * 100) / 100)
        game.ui.UIMessageTipsMgr.getInstance():showTips(text)

        request.member.score = tonumber(protocol.memberScore)
        self._leagueData:setMemberScore(request.member)
        self._leagueData:setCurrentScore(tonumber(protocol.currentScore))
        self._leagueData:setTeamScore(tonumber(protocol.currentScore))
        self:dispatchEvent({name = "EVENT_LEAGUE_MEMBER", roleId = request.member.roleId})
    else
        self:_showCommonTips(protocol.result)
    end
end

-- 请求邀请玩家到联盟俱乐部的搭档成员中
function BigLeagueService:sendCCLInvitePartnerMemberREQ(leagueId, clubId, memberId)
    local request = net.NetworkRequest.new(net.protocol.CCLInvitePartnerMemberREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, memberId)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCInvitePartnerMemberRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local isSuccess = protocol.result == net.ProtocolCode.INVITE_PARTNER_MEMBER_SUCCESS
    event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = not isSuccess, isDestroy = isSuccess})
    if isSuccess then
        self:dispatchEvent({name = "EVENT_LEAGUE_PARTNER"})
        game.ui.UIMessageTipsMgr.getInstance():showTips("邀请成功，玩家已加入")
    else
        self:_showCommonTips(protocol.result)
    end
end


-- 请求修改联盟中俱乐部搭档活跃值赠送
function BigLeagueService:sendCCLModifyGamePlayPartnerFireScoreREQ(leagueId, clubId, partnerId, gameplayId, startScore, endScore, changeClubFireScore)
    local request = net.NetworkRequest.new(net.protocol.CCLModifyGamePlayPartnerFireScoreREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId, clubId, partnerId, gameplayId, startScore, endScore, changeClubFireScore)
    request.leagueId = leagueId
    request.clubId = clubId
    request.partnerId = partnerId
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCModifyGamePlayPartnerFireScoreRES(response)
    local request = response:getRequest()
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.MODIFY_GAME_PLAY_PARTNER_FIRE_SCORE_SUCCESS then
        local type = request.partnerId == 0 and 1 or 0
        self:sendCCLQueryLeagueGameplayREQ(request.leagueId, request.clubId, request.partnerId, true,  type, true)
    else
        self:_showCommonTips(protocol.result)
    end
end

function BigLeagueService:_onCLCLeagueGamePlayInfoSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.leagueId == self._leagueData:getLeagueId() then 
        self:dispatchEvent({name = "EVENT_LEAGUE_GAMEPLAY_REDDOT", gamePlayId = protocol.gamePlayId, modifyTime = protocol.modifyTime })
    end
end

--请求联盟玩法统计
function BigLeagueService:sendCCLQueryGameplayStatisticsREQ(leagueId, date)
    local request = net.NetworkRequest.new(net.protocol.CCLQueryGameplayStatisticsREQ, self._bigLeagueServiceId)
    request:getProtocol():setData(leagueId,date)
    game.util.RequestHelper.request(request)
end

function BigLeagueService:_onCLCQueryGameplayStatisticsRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.QUERY_GAMEPLAY_STATISTICS_SUCCESS then
        --设置玩法统计
        self._leagueData:setGamePlayStatistic(protocol)
        self:dispatchEvent({name = "EVENT_PLAY_STATISTIC"})
    else 
        self:_showCommonTips(protocol.result)
    end
end

function BigLeagueService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
    -- 解绑事件系统
    cc.unbind(self, "event");
end