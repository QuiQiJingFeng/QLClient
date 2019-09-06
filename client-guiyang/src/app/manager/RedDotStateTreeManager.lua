local ns = namespace("manager")

local M = class("RedDotStateTreeManager")
ns.RedDotStateTreeManager = M

--[[
    红点的状态树
]]

local RedDotKey =
{
    -- 俱乐部排行榜经理奖励按钮
    CLUB_RANK_MANGER_REWARD = "ClubRankManagerReward",
    -- 俱乐部排行榜成员奖励按钮
    CLUB_RANK_MEMBER_REWARD = "ClubRankMemberReward",
    GOD_OF_WEALTH = "GodOfWealth",
    -- 钱包状态变化
    WALLET = "wallet",
    -- 俱乐部锦鲤活动红点
    KOI_FISH_ACTIVITY = "KoiFishActivity",
}

-- 绑定父子关系
local RedDotParent =
{
    CLUB_RANK_REWARD = {RedDotKey.CLUB_RANK_MANGER_REWARD, RedDotKey.CLUB_RANK_MEMBER_REWARD},
}

local _instance = nil
function M.create()
    if _instance ~= nil then
        return false;
    end

    _instance = M.new();
	_instance:initialize()
    return true;
end

function M:initialize()

end

function M.getInstance()
    return _instance;
end

function M:ctor()
	self._redDotData = {}
end

function M.destroy()
    if _instance == nil then
        return;
    end

    _instance:dispose();
    _instance = nil;
end

function M:dispose()
    self._redDotData = {}
end

-- status:红点的状态值（>0 则显示红点，<=0 则不显示红点）
function M:setRedDotData(redDots)
    local redDotKeys = {}
    local isChange = false
    for _, data in ipairs(redDots) do
        local redDot = self._redDotData[data.key]
        if redDot ~= nil then
            -- 判断当前的红点状态是否改变
            if (redDot > 0) ~= (data.status > 0) then
                redDotKeys[data.key] = data.status
                isChange = true
            end
        else
            isChange = true
        end
        self._redDotData[data.key] = data.status
    end

    -- redDotKeys:防止界面红点太多可以根据类型去逐一刷新，一般界面红点不会太多
    if isChange then
        game.service.LocalPlayerService:getInstance():dispatchEvent({name = "EVENT_RED_DOT_CHANGE", redDotKeys = redDotKeys})
    end
end

function M:changeRedDotData(whichone,status)
    if self._redDotData[whichone] ~= nil then
        self._redDotData[whichone] = status
    end

    game.service.LocalPlayerService:getInstance():dispatchEvent({name = "EVENT_RED_DOT_CHANGE", redDotKeys = self._redDotData})
end

function M:getRedDotKey()
    return RedDotKey
end

function M:getRedDotParent()
    return RedDotParent
end

-- 判断子节点红点显示
function M:isVisible(key)
    local value = self._redDotData[key] or 0
    return value > 0
end

-- 判断父节点红点显示
function M:isVisibleParent(key)
    local childrens = key or {}
    for _, children in ipairs(childrens) do
        -- 只要有一个子节点显示红点,父节点就显示
        if self:isVisible(children) then
            return true
        end
    end

    return false
end