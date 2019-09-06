local csbPath = "ui/csb/Mail/UIOperationRecord2.csb"
local super = require("app.game.ui.UIBase")
---@class UIOperationRecord2:UIBase
local UIOperationRecord2 = class("UIOperationRecord2", function() return cc.CSLoader:createNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")

local CLUB_ACTIONS = {
    AGREE = 1, -- 同意申请加入大联盟
    REFUSE = 2, -- 拒绝申请加入大联盟
    MODIFY_INITIAL_SCORE = 3, -- 修改初始分值
    MODIFY_FIRE_SCORE = 4, -- 修改火力值
    SIGN_UP = 5, -- 俱乐部报名比赛
    CLICK_LIKE = 6, -- 给俱乐部点赞
    MODIFY_GAME_PLAY = 7, -- 修改玩法
    PAUSE_GAME = 8, -- 暂停比赛
    RESTORE_GAME = 9, -- 恢复比赛
    FORCE_QUIT_GAME = 10, -- 强制退赛
    CANCLE_LIKE = 11, -- 给俱乐部取消点赞
    CHANGE_ONE_CLUB_FIRE  = 12, --单独修改俱乐部赠送活跃值
    ADD_GAME_PLAY   = 13, --新增玩法
    DELETE_GAME_PLAY  = 14 ,--删除玩法


    ORDER_MEMBER = 100, -- 指派出战
    FORCE_QUIT_MEMBER = 101, -- 强制退赛
    REJOIN_LEAGUE = 102, -- 重新报名参赛
    GAMEPLAY_MODIFIED = 103, -- 联盟玩法变动
    QUERY_JOIN_LEAGUE = 104, -- 申请加入超级联盟
    BE_AGREE_JOIN = 105, -- 超级联盟审批通过
    BE_REFUSE_JOIN = 106, -- 超级联盟审批拒绝
    RANK_BE_LIKE = 107, -- 排名被点赞
    INITIAL_SCORE_BE_CHANGED = 108, -- 团队初始分值被修改
    FIRE_SCORE_BE_CHANGED = 109, -- 团队火力值被修改
    BE_PAUSED = 110, -- 被总盟主暂停比赛
    BE_RESTORED = 111, -- 被总盟主恢复比赛
    MEMBER_JOIN = 112, -- 玩家加入俱乐部
    MEMBER_QUIT = 113, -- 玩家推出俱乐部
    ORDER_ASSISTANT = 114, -- 设置玩家为管理员
    RANK_BE_CANCEL_LIKE = 115, -- 排名被取消点赞
    PAUSE_MEMBER_GAME = 116, -- 暂停某玩家参与比赛
    RESTORE_MEMBER_GAME = 117, -- 恢复某玩家比赛资格
    MODIFY_MEMBER_SCORE = 118, -- 调整分数

    BE_ORDERED_GAME = 201, -- 被指派出战
    BE_FORCE_QUITED = 202, -- 被强制退赛
    MEMBER_GAMEPLAY_MODIFIED = 203, -- 联盟玩法变动
    MEMBER_REJOIN_LEAGUE = 204, -- 俱乐部重新报名参赛
    CLUB_BE_PAUSED = 205, -- 团队被总盟主暂停比赛
    CLUB_BE_RESTORED = 206, -- 团队被总盟主恢复比赛
    BE_ORDERED_ASSISTANT = 207, -- 玩家被升级为管理员
    BE_PAUSE_GAME = 208, -- 玩家被暂停比赛
    BE_RESTORE_GAME = 209, -- 玩家被恢复比赛
    BE_MODIFY_SCORE = 210, -- 被调整分数
}

local TREND_VALUE =
{
    LEAGUE_NAME = "leagueName", -- 大联盟名称
    CLUB_NAME = "clubName", -- 俱乐部名称
    SCORE = "score", -- 分值
    CLUB_MANAGER_NAME = "clubManagerName", -- 俱乐部经理名称
    MEMBER_NAME = "memberName", -- 成员名称
    MEMBER_INITIAL_SCORE = "memberInitialScore", -- 成员初始分
    MEMBER_MODIFY_SCORE = "memberModifyScore", -- 成员被退赛时的分数
    TIME = "time", -- 时间
    SETTLE_TIME = "settleTime", -- 结算点的动态
    CLUB_MODIFY_SCORE = "clubModifyScore", -- 俱乐部被修改的分数
}

function UIOperationRecord2:ctor()
    self._textPrompt = seekNodeByName(self, "Text_tiao", "ccui.Text")

    self._reusedListOperationRecord = ListFactory.get(
            seekNodeByName(self, "ListView_OperationRecord", "ccui.ListView"),
            handler(self, self._onListViewInit),
            handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListOperationRecord:setScrollBarEnabled(false)
end

function UIOperationRecord2:show(parent)
    self:setVisible(true)
    self:setPosition(0, 0)
    self._parent = parent

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._bigLeagueService:sendCCLQueryTrendREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._bigLeagueService:getLeagueData():getClubId(), self._bigLeagueService:getLeagueData():getTitle())
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_TREND", handler(self, self._upadtaListView), self)

    self:_upadtaListView()
end

function UIOperationRecord2:_upadtaListView()
    self._reusedListOperationRecord:deleteAllItems()

    if #self._bigLeagueService:getLeagueData():getTrendInfo() < 1 then
        self._textPrompt:setVisible(true)
        return
    end

    self._textPrompt:setVisible(false)

    for _, trend in ipairs(self._bigLeagueService:getLeagueData():getTrendInfo()) do
        self._reusedListOperationRecord:pushBackItem(trend)
    end
end

function UIOperationRecord2:_onListViewInit(listView)
    listView.textTime = seekNodeByName(listView, "Text_Time", "ccui.Text")
    listView.textRecord = seekNodeByName(listView, "Text_Record", "ccui.Text")
end

function UIOperationRecord2:_onListViewSetData(listView, val)
    listView.textTime:setString(os.date("%Y-%m-%d %H:%M", val.time/1000))
    listView.textRecord:setString(self:_getContent(val.data, val.type))
end

function UIOperationRecord2:_getContent(data, type)
    local data = json.decode(data)
    local leagueName = game.service.club.ClubService.getInstance():getInterceptString(data[TREND_VALUE.LEAGUE_NAME], 8)
    local clubName = game.service.club.ClubService.getInstance():getInterceptString(data[TREND_VALUE.CLUB_NAME], 8)
    local managerName = game.service.club.ClubService.getInstance():getInterceptString(data[TREND_VALUE.CLUB_MANAGER_NAME], 8)
    local memberName = game.service.club.ClubService.getInstance():getInterceptString(data[TREND_VALUE.MEMBER_NAME], 8)
    local score = kod.util.String.formatMoney(tonumber(data[TREND_VALUE.SCORE]) or 0, 2)
    local initScore = kod.util.String.formatMoney(tonumber(data[TREND_VALUE.MEMBER_INITIAL_SCORE]) or 0, 2)
    -- local modifyScore = kod.util.String.formatMoney(tonumber(data[TREND_VALUE.MEMBER_MODIFY_SCORE]) or 0, 2)
    local mScore = tonumber(data[TREND_VALUE.MEMBER_MODIFY_SCORE]) or 0
    local modifyScore = kod.util.String.formatMoney(mScore , 2)
    local modifyScore = mScore > 0 and "+" .. modifyScore or modifyScore

    local clubScore = tonumber(data[TREND_VALUE.CLUB_MODIFY_SCORE]) or 0
    local clubModifyScore = kod.util.String.formatMoney(clubScore, 2)
    local clubModifyScore = clubScore > 0 and "+" .. clubModifyScore or clubModifyScore
    local switch = {
        [CLUB_ACTIONS.AGREE] = function()
            local str = string.format("您已批准%s%s加入比赛", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.REFUSE] = function()
            local str = string.format("您已拒绝%s%s参加比赛", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.MODIFY_INITIAL_SCORE] = function()
            return string.format("%s团队的团队可支配分%s，修改后为%s", clubName, clubModifyScore, score)
        end,
        [CLUB_ACTIONS.MODIFY_FIRE_SCORE] = function()
            return string.format("%s团队的活跃值比例调整至%s%%", clubName, score)
        end,
        [CLUB_ACTIONS.SIGN_UP] = function()
            return string.format("%s团体报名新的一天比赛", clubName)
        end,
        [CLUB_ACTIONS.CLICK_LIKE] = function()
            local str = string.format("%s团队%s日的排名已被您点赞", clubName, os.date("%d", data[TREND_VALUE.TIME]/1000))
            return str
        end,
        [CLUB_ACTIONS.CANCLE_LIKE] = function()
            local str = string.format("%s团队%s日的排名已被您取消点赞", clubName, os.date("%d", data[TREND_VALUE.TIME]/1000))
            return str
        end,

        [CLUB_ACTIONS.MODIFY_GAME_PLAY] = function()
            local str = string.format("赛事修改玩法:%s",data.gameName) 
            return str
        end,
        [CLUB_ACTIONS.PAUSE_GAME] = function()
            local str = string.format("%s%s暂停比赛", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.RESTORE_GAME] = function()
            local str = string.format("%s%s恢复比赛", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.FORCE_QUIT_GAME] = function()
            local str = string.format("%s%s强制退赛", clubName, config.STRING.COMMON)
            return str
        end,


        [CLUB_ACTIONS.ORDER_MEMBER] = function()
            local str = string.format("%s指派玩家%s参与比赛，赛事初始分为%s", managerName, memberName, initScore)
            return str
        end,
        [CLUB_ACTIONS.FORCE_QUIT_MEMBER] = function()
            local str = string.format("%s强制玩家%s退出比赛，退出时赛事分为%s", managerName, memberName, score)
            return str
        end,
        [CLUB_ACTIONS.REJOIN_LEAGUE] = function()
            local str = string.format("%s重新报名比赛，报名后初始分数为%s", clubName, score)
            return str
        end,
        [CLUB_ACTIONS.GAMEPLAY_MODIFIED] = function()
            return "赛事玩法变动"
        end,
        [CLUB_ACTIONS.QUERY_JOIN_LEAGUE] = function()
            return "申请加入赛事"
        end,
        [CLUB_ACTIONS.BE_AGREE_JOIN] = function()
            local str = string.format("您的%s%s已成功报名", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.BE_REFUSE_JOIN] = function()
            local str = string.format("您的%s%s被拒绝参加比赛", clubName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.RANK_BE_LIKE] = function()
            local str = string.format("您%s日的排名已被点赞", os.date("%d", data[TREND_VALUE.TIME]/1000))
            return str
        end,
        [CLUB_ACTIONS.RANK_BE_CANCEL_LIKE] = function()
            local str = string.format("您%s日的排名已被取消点赞", os.date("%d", data[TREND_VALUE.TIME]/1000))
            return str
        end,
        [CLUB_ACTIONS.INITIAL_SCORE_BE_CHANGED] = function()
            local str = string.format("团队可支配分%s，修改后为%s", clubModifyScore, score)
            return str
        end,
        [CLUB_ACTIONS.FIRE_SCORE_BE_CHANGED] = function()
            local str = string.format("%s团队的活跃值比例调整至%s%%", clubName, score)
            return str
        end,
        [CLUB_ACTIONS.BE_PAUSED] = function()
            return "团队已被暂停比赛"
        end,
        [CLUB_ACTIONS.BE_RESTORED] = function()
            return "团队已被恢复比赛"
        end,
        [CLUB_ACTIONS.MEMBER_JOIN] = function()
            local str = string.format("玩家：%s加入%s", memberName, config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.MEMBER_QUIT] = function()
            local str = string.format("玩家：%s退出%s", memberName, config.STRING.COMMON)
            return str
        end,

        [CLUB_ACTIONS.BE_ORDERED_GAME] = function()
            local str = string.format("您已被队长指派参赛，参赛积分为%s", initScore)
            return str
        end,
        [CLUB_ACTIONS.BE_FORCE_QUITED] = function()
            return "您已被强制退赛"
        end,
        [CLUB_ACTIONS.MEMBER_GAMEPLAY_MODIFIED] = function()
            return "赛事玩法变动"
        end,
        [CLUB_ACTIONS.MEMBER_REJOIN_LEAGUE] = function()
            local str = string.format("%s重新报名参赛", config.STRING.COMMON)
            return str
        end,
        [CLUB_ACTIONS.CLUB_BE_PAUSED] = function()
            return "团队已被暂停比赛"
        end,
        [CLUB_ACTIONS.CLUB_BE_RESTORED] = function()
            return "团队已被恢复比赛"
        end,
        [CLUB_ACTIONS.ORDER_ASSISTANT] = function()
            local str = string.format("玩家%s被任命为管理员", memberName)
            return str
        end,
        [CLUB_ACTIONS.BE_ORDERED_ASSISTANT ] = function()
            local str = string.format("玩家%s被任命为管理员", memberName)
            return str
        end,
        [CLUB_ACTIONS.PAUSE_MEMBER_GAME] = function()
            local str = string.format("%s暂停%s参与比赛", managerName, memberName)
            return str
        end,
        [CLUB_ACTIONS.RESTORE_MEMBER_GAME] = function()
            local str = string.format("%s恢复%s比赛资格", managerName, memberName)
            return str
        end,
        [CLUB_ACTIONS.BE_PAUSE_GAME] = function()
            local str = string.format("您已被%s暂停参与比赛", managerName)
            return str
        end,
        [CLUB_ACTIONS.BE_RESTORE_GAME] = function()
            local str = string.format("您已被%s恢复参与比赛", managerName)
            return str
        end,
        [CLUB_ACTIONS.MODIFY_MEMBER_SCORE] = function()
            local str = string.format("%s调整玩家%s分数%s，赛事初始分为%s", managerName, memberName, modifyScore, initScore)
            return str
        end,
        [CLUB_ACTIONS.BE_MODIFY_SCORE] = function()
            local str = string.format("您已被队长调整分数%s，调整后分数为%s", modifyScore, initScore)
            return str
        end,
        --单独修改俱乐部赠送活跃值
        [CLUB_ACTIONS.CHANGE_ONE_CLUB_FIRE] = function()
            local str = "赛事修改了您的活跃值赠送数值"
            return str
        end,
        --新增玩法
        [CLUB_ACTIONS.ADD_GAME_PLAY] = function()
            local str = string.format("赛事添加了玩法:%s",data.gameName)
            return str
        end,
        --删除玩法
        [CLUB_ACTIONS.DELETE_GAME_PLAY ] = function()
            local str = string.format("赛事删除了玩法:%s",data.gameName )
            return str
        end,
    }
    return switch[type]()
end


function UIOperationRecord2:hide()
    self._reusedListOperationRecord:deleteAllItems()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIOperationRecord2