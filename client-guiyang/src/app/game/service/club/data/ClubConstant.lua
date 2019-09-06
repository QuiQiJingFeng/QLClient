local ClubConstant = class("ClubConstant")

--[[
    亲友圈常量
]]

-- 亲友圈推送类型
function ClubConstant:getClubNotifyType()
    local notifyType = 
    {
        NORMAL = 1,
        
        USER_MODIFYCARD             = 101,      -- 用户(群主) - 房卡变化 (推送数据: 只有用户数据)
        USER_INVITATION             = 102,      -- 用户 - 邀请版本变化
        USER_BEKICKED               = 103,      -- 用户 - 被踢
        USER_JOINCLUB               = 104,      -- 用户 - 加入亲友圈
        USER_TITLE                  = 105,      -- 用户 - 成员头衔变动

        CLUB_APPLICATION            = 201,      -- 亲友圈 - 申请 （推送数据：亲友圈数据只有该亲友圈的信息)
        CLUB_SEALED                 = 202,      -- 亲友圈 - 封停 （推送数据：亲友圈数据只有该亲友圈的信息)
        CLUB_NOTICE                 = 203,      -- 亲友圈 - 公告 （推送数据：亲友圈数据只有该亲友圈的信息)
        CLUB_REMOVED                = 204,      -- 亲友圈 - 解散 （推送数据：所有亲友圈的信息)
        CLUB_GAMEPLAY               = 205,      -- 亲友圈 - 亲友圈玩法推送
        CLUB_INFO                   = 206,      -- 亲友圈 - 信息 （推送数据：亲友圈头像和名称改变时推送亲友圈信息)
        CLUB_TASK                   = 207,      -- 亲友圈 - 任务 （推送数据：亲友圈有可以领取的任务时推送亲友圈数据)
        CLUB_RED_PACKET             = 209,      -- 亲友圈 - 红包 （推送数据：亲友圈中成员头衔信息变化时推送亲友圈数据)
        CLUB_SWITCHES               = 210,      -- 亲友圈 - 开关 （推送数据：亲友圈开关值变化时推送亲友圈数据)
        JOIN_LEAGUE                 = 212,      -- 俱乐部 - 联盟 （推送数据：俱乐部成功加入联盟)
        QUIT_LEAGUE                 = 213,      -- 俱乐部 - 联盟 （推送数据：俱乐部退出联盟)

        CLUB_ROOM_LIST              = 301,      -- 亲友圈房间 -（推送数据：推送亲友圈中所有房间的数据) 
    }

    return notifyType
end

-- 亲友圈开关类型
function ClubConstant:getClubSwitchType()
    local clubSwitchType =
    {
        -- /** 3人房能否提前开局 */
        EARLY_BATTLE_3 = 1,
        -- /** 4人房能否提前开局 */
        EARLY_BATTLE_4 = bit.lshift(1, 1),
        -- /** 普通成员能否看到已满的牌桌 */
        FULL_PLAYER_ROOM = bit.lshift(1, 2),
        --  /** 私密房间开关 */
        PRIVATE_ROOM = bit.lshift(1, 3),
        -- /** 冻结房间开关 */
        FROZEN_ROOM = bit.lshift(1, 4),
        -- /** 禁用分享文字战绩开关 */
        FORBIDDEN_SHARE_WORDS = bit.lshift(1, 5),
    }

    return clubSwitchType
end

-- 亲友圈icon
function ClubConstant:getClubIcon()
    local clubIcon = {
        ["Club_Icon_1"] = "art/club4/img_tb1.png",
        ["Club_Icon_2"] = "art/club4/img_tb2.png",
        ["Club_Icon_3"] = "art/club4/img_tb3.png",
        ["Club_Icon_4"] = "art/club4/img_tb4.png",
        ["Club_Icon_5"] = "art/club4/img_tb5.png",
    }
    return clubIcon
end

-- 亲友圈默认Icon名字
function ClubConstant:getClubDefaultIconName()
    return "Club_Icon_1"
end

-- 玩家头衔
function ClubConstant:getClubPosition()
    local clubPosition = 
    {
        OBSERVER    = 1,        -- 准成员
        MEMBER      = 2,        -- 成员
        MANAFER     = 3,        -- 群主
        ASSISTANT   = 4,        -- 管理
        PARTNER     = 5,        -- 组长
        BOSS        = 6,        -- 超级盟主
    }
    return clubPosition
end

function ClubConstant:getClubTitleSort(position)
    local titleIndex =
    {
        [ClubConstant:getClubPosition().OBSERVER]   = 1,
        [ClubConstant:getClubPosition().MEMBER]     = 2,
        [ClubConstant:getClubPosition().MANAFER]    = 5,
        [ClubConstant:getClubPosition().ASSISTANT]  = 3,
        [ClubConstant:getClubPosition().PARTNER]    = 4,
    }

    return titleIndex[position] or 0
end

function ClubConstant:getClubTitle(position)
    local clubTitle =
    {
        [ClubConstant:getClubPosition().OBSERVER]   = "准成员",
        [ClubConstant:getClubPosition().MEMBER]     = "成员",
        [ClubConstant:getClubPosition().MANAFER]    = "群主",
        [ClubConstant:getClubPosition().ASSISTANT]  = "管理",
        [ClubConstant:getClubPosition().PARTNER]    = "搭档",
    }

    return clubTitle[position] or ""
end

-- 亲友圈邀请的状态
function ClubConstant:getClubInvitationStatus()
    local clubInvitationStatus = 
    {
        NORMAL = 0,                 -- 未处理
        WAIT_MANAGER_OPERATE = 1,   -- 等待群主处理  
        ACCEPT = 2,                 -- 已接受
        REFUSE = 3,                 -- 已拒绝
    }

    return clubInvitationStatus
end

-- 亲友圈邀请信息的来源
function ClubConstant:getClubInvitationSourceType()
    local clubInvitationSourceType = 
    {
        NORMAL = 0, --  正常来源，在成员列表界面中输入玩家id来邀请
        RECOMMAND = 1, -- 推荐邀请，在推荐玩家列表中发送的邀请
    }

    return clubInvitationSourceType
end

-- 请求推荐列表类型
function ClubConstant:getClubQueryRecommandType()
    local clubQueryRecommandType = 
    {
        RECOMMANDED = 0, -- 推荐玩家列表
        INVITED = 1, -- 已邀请
        ACCEPTTED = 2, -- 已接受
    }

    return clubQueryRecommandType
end

-- 亲友圈操作类型
function ClubConstant:getOperationType()
    local operationType = 
    {
        add = 0,
        delete = 1,
        alter = 2,
    }
    
    return operationType
end

-- 亲友圈玩法类型
function ClubConstant:getGamePlayType()
    local gamePlayType =
    {
        reverse = 1, -- 禁用
        stencil = 2, -- 模版
        normal = 3, -- 正常创建
        superLeague = 4, -- 超级盟主
        league = 5, -- 盟主（成员）
    }

    return gamePlayType
end

function ClubConstant:getClubActivityType()
    local clubActivityType =
    {
        CardCount = 1, -- 牌局累计
        Winner = 2, -- 大赢家
        HighestScore = 3, -- 最高分
        InvitePlayers = 4,  -- 邀请玩家
    }

    local index = 
    {
        clubActivityType.CardCount,
        clubActivityType.Winner,
        clubActivityType.HighestScore,
        clubActivityType.InvitePlayers,
    }

    return clubActivityType, index
end

-- 亲友圈活动操作类型
function ClubConstant:getActivityOperationType()
    local activityOperationType =
    {
        cancel = 1, -- 取消
        stop = 2, -- 中止
        delete = 3, -- 删除
    }

    return activityOperationType
end

-- 亲友圈活动时间类型
function ClubConstant:getTimeType()
    local timeType =
    {
        START = "start",
        END = "end",
    }

    return timeType
end

-- 亲友圈活动状态
function ClubConstant:getActivityStatus()
    local activityStatus =
    {
        start = 2, -- 即将开始
        processing = 1, -- 进行中
        status_end = 3, -- 结束
    }

    return activityStatus
end

-- 获取白名单类型
function ClubConstant:getWhiteListType()
    local whiteListType =
    {
        RECOMMEND = 1, -- 推荐
        PRIVATE_ROOM = bit.lshift(1, 1), -- 包房
        MAHJONGCLIENT = bit.lshift(1, 2), -- 麻将客
        BUSINESSCARD = bit.lshift(1, 3), -- 名片分享
    }

    return whiteListType
end

-- 获取成员入会方式
function ClubConstant:getAdmissionMethod()
    local method =
    {
        InvitationCode = 1, -- 邀请码
        InvitePeople = 2, -- 邀请人
    }

    return method
end

-- 排行榜类型
function ClubConstant:getLeaderboardType()
    local leaderboard =
    {
        roomCard = 1, --牌局数
        winner = 2, -- 大赢家
        integral = 3, -- 积分累计
        winPoints = 4, -- 赢分累计
        dataDaily = 5, -- 数据日报
    }

    return leaderboard
end

-- 玩家在线状态Icon
function ClubConstant:getOnlineStatus()
    local onlineStatusIndex = 
    {
        online = 1, -- 在线
        inGame = 2, -- 游戏中
        offline = 3, -- 离线
    }

    return onlineStatusIndex
end

function ClubConstant:getOnlineStautusName(index)
    local stautusName =
    {
        "在线",
        "游戏中",
        "离线"
    }
    return stautusName[index]
end

function ClubConstant:getOnlineStatusIcon(position ,index)
    local icon1 =
    {
        "art/Icon/icon_zx.png",
        "art/Icon/icon_yxz.png",
        "art/Icon/icon_lx.png",
    }

    local icon2 = 
    {
        "art/img/img_zx.png",
        "art/img/img_yxz.png",
        "art/img/img_lx.png",
    }

    local icon3 =
    {
        "art/Icon/z_zx.png",
        "art/Icon/z_yxz.png",
        "art/Icon/z_lx.png",
    }

    if position == "member" then
        return icon2[index]
    elseif position == "roomInvite" then
        return  icon3[index]
    end

    return icon1[index]
end

-- 创建房间方式
function ClubConstant:getCreateRoomType()
    local createRoomType =
    {
        LOBBY_CREATE = 1, -- 大厅创建房间
        FRIEND_QUICK_CREATE = 2, -- 好友立即组局
        CLUB_CREATE = 3, -- 俱乐部大厅创建房间
        CLUB_QUICK_CREATE = 4, -- 俱乐部一键开房
        ANOTHER_ROOM_CREATE = 5, -- 再来一局创建房间
        LEAGUE_ROOM_CREATE = 6, -- 联盟创建房间
    }

    return createRoomType
end

-- 房间邀请方式
function ClubConstant:getRoomInviationType()
    local roomInviationType = 
    {
        FRIEND_QUICK_CREATE = 1, -- 好友立即组局
        FRIEND_INVITED = 2, -- 房间内好友邀请
        ANOTHER_ROOM_INVITED = 3, -- 再来一局邀请
        CLUB_MEMBER_INVITED = 4, -- 房间内俱乐部成员邀请
    }

    return roomInviationType
end

-- 活动类型
function ClubConstant:getClubActivityId()
    local clubActivityId =
    {
        LEADER_BOARD = 400010,		-- 俱乐部排行榜活动
    }

    return clubActivityId
end

return ClubConstant