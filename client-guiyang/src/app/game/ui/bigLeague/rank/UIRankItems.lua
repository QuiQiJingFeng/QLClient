--[[
    UIMatchRankItem,UILotteryRankItem,UIClubRankItem, nil, UIMemberMatchItem, UIMemberLotteryItem}
    排行榜ListView各控件
    UITeamRankItem:联盟团队排名，序号1
    UIFireRankItem:联盟活跃排名，序号2
    UIMemberRankItem:参赛人数排行,序号3
    UIMatchRankItem:比赛场次排行,序号4
    UILottertRankItem:抽奖排行,序号5
    UIMemberMatchMatchItem:团队排行,序号6
    没有序号7,7位俱乐部概况
    UIMemberMatchItem：成员场次排行,序号8
    UIMemberLotteryItem，成员抽奖排行，序号9
]]
local UITeamRankItem = class("UITeamRankItem")

function UITeamRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UITeamRankItem)
    self:_initialize()
    return self
end

function UITeamRankItem:_initialize()
end

function UITeamRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName))     --盟主名
    item:getChildByName("Text_AllScore"):setString(math.round(info.allScore * 100) / 100)       --总积分
    item:getChildByName("Text_WinScore"):setString(math.round(info.winScore * 100) / 100)       --优胜分
    item:getChildByName("Text_FireScore"):setString(math.round(info.fireScore * 100) / 100)     --火力值
    local btn = item:getChildByName("Button_Like")
    if info.like then
        btn:getChildByName("BitmapFontLabel_3"):setString("取消")
    else
        btn:getChildByName("BitmapFontLabel_3"):setString("点赞")
    end
    btn:addClickEventListener(function()   
        -- self._bigLeagueService:sendCCLClickLikeREQ(self._bigLeagueService:getLeagueData():getLeagueId(), )
        if not info.like then
            UIManager:getInstance():show("UIBigLeagueLikeTip", info, info._day)
        else
            local service = game.service.bigLeague.BigLeagueService:getInstance()
            service:sendCCLClickLikeREQ(service:getLeagueData():getLeagueId(), info.clubId, game.service.TimeService:getInstance():getStartTime(info._day) * 1000,false)
        end
    end)

    item:getChildByName("Text_Like"):setVisible(false)      --已点赞
    item:setTag(info.clubId)
end



local UIFireRankItem = class("UIFireRankItem")

function UIFireRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIFireRankItem)
    self:_initialize()
    return self
end

function UIFireRankItem:_initialize()
end

function UIFireRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName,6))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName,6))     --盟主名
    item:getChildByName("Text_AllScore"):setString(math.round(info.allScore * 100) / 100)       --总积分
    item:getChildByName("Text_WinScore"):setString(math.round(info.winScore * 100) / 100)       --优胜分
    item:getChildByName("Text_FireScore"):setString(math.round(info.fireScore * 100) / 100)     --火力值
    item:setTag(info.clubId)
end


local UIMemberRankItem = class("UIMemberRankItem")

function UIMemberRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIMemberRankItem)
    self:_initialize()
    return self
end

function UIMemberRankItem:_initialize()
end

function UIMemberRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName))     --盟主名
    item:getChildByName("Text_MemberCount"):setString(info.memberCount)     --盟主名
    item:setTag(info.clubId)
end


local UIMatchRankItem = class("UIMatchRankItem")

function UIMatchRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIMatchRankItem)
    self:_initialize()
    return self
end

function UIMatchRankItem:_initialize()
end

function UIMatchRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName))     --盟主名
    item:getChildByName("Text_RoomCount"):setString(info.roomCount)     --盟主名
    item:setTag(info.clubId)
end



local UILotteryRankItem = class("UILotteryRankItem")

function UILotteryRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UILotteryRankItem)
    self:_initialize()
    return self
end

function UILotteryRankItem:_initialize()
end

function UILotteryRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName))     --盟主名
    item:getChildByName("Text_LotteryCount"):setString(info.lotteryCount)     --盟主名
    item:setTag(info.clubId)
end


local UIClubRankItem = class("UIClubRankItem")

function UIClubRankItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIClubRankItem)
    self:_initialize()
    return self
end

function UIClubRankItem:_initialize()
end

function UIClubRankItem:setData(info)
    local item = self
    item:getChildByName("Text_LeagueName"):setString(getInterceptString(info.clubName))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_LeagueId"):setString("ID:"..info.clubId)   --联盟Id
    item:getChildByName("Text_OwnerName"):setString(getInterceptString(info.managerName))     --盟主名
    item:getChildByName("Text_AllScore"):setString(math.round(info.allScore * 100) / 100)       --总积分
    item:getChildByName("Text_WinScore"):setString(math.round(info.winScore * 100) / 100)       --优胜分
    item:getChildByName("Text_InitScore"):setString(math.round((info.allScore - info.winScore) * 100) / 100)
    item:getChildByName("Text_FireScore"):setString(math.round(info.fireScore * 100) / 100)     --火力值
    item:setTag(info.clubId)

end



local UIMemberMatchItem = class("UIMemberMatchItem")

function UIMemberMatchItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIMemberMatchItem)
    self:_initialize()
    return self
end

function UIMemberMatchItem:_initialize()
end

function UIMemberMatchItem:setData(info)
    local item = self
    item:getChildByName("Text_MemberName"):setString(getInterceptString(info.name))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_MemberId"):setString(""..info.roleId)   --联盟Id
    item:getChildByName("Text_RoomCount"):setString(""..info.roomCount)     --盟主名

end


local UIMemberLotteryItem = class("UIMemberLotteryItem")

function UIMemberLotteryItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIMemberLotteryItem)
    self:_initialize()
    return self
end

function UIMemberLotteryItem:_initialize()
end

function UIMemberLotteryItem:setData(info)
    local item = self
    item:getChildByName("Text_MemberName"):setString(getInterceptString(info.name))   --联盟名
    item:getChildByName("BM_Rank"):setString("".. info.idx)                  --排名
    item:getChildByName("Text_MemberId"):setString(""..info.roleId)   --联盟Id
    item:getChildByName("Text_LotteryCount"):setString(""..info.lotteryCount)     --盟主名
end

-- return {nil ,UITeamRankItem, UIFireRankItem,UIMemberRankItem,UIMatchRankItem,UILotteryRankItem,UIClubRankItem, nil, UIMemberMatchItem, UIMemberLotteryItem}
return {UITeamRankItem, UIFireRankItem,UIMemberRankItem,UIMatchRankItem,UILotteryRankItem,UIClubRankItem, nil, UIMemberMatchItem, UIMemberLotteryItem}