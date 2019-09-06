local SHARE_IMAGE_ID_MIN = 1
local SHARE_IMAGE_ID_MAX = 3
local SHARE_IMAGE_PATH = {
    [1] = 'art/newshare/share_1.jpg',
    [2] = 'art/newshare/share_2.jpg',
    [3] = 'art/newshare/share_3.jpg',
}
local super = require("app.game.service.activity.ActivityServiceBase")
local ComebackActivityService = class("ComebackActivityService", super)

function ComebackActivityService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.ACCBackShareRES.OP_CODE, self, self._onACCBackShareRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackInfoOrdinaryUserRES.OP_CODE, self, self._onACCBackInfoOrdinaryUserRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackSignRES.OP_CODE, self, self._onACCBackSignRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackInfoClubManagerRES.OP_CODE, self, self._onACCBackInfoClubManagerRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackCheckBindUserRES.OP_CODE, self, self._onACCBackCheckBindUserRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackExtractCardRES.OP_CODE, self, self._onACCBackExtractCardRES)
    requestManager:registerResponseHandler(net.protocol.ACCBackClubDelaySYN.OP_CODE, self, self._onACCBackClubDelaySYN)

    -- 是否在活动的延迟领奖时间内
    self._isInFinalRewardTime = false
    -- 签到数据的缓存
    self._checkInBuffer = nil
    -- 经理数据的缓存
    self._managerBuffer = nil
end

function ComebackActivityService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function ComebackActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 目前有 （经理分享） （老玩家签到后的分享、普通玩家分享） 分为两类
-- 只有经理走经理分享， 其他一并走  非经理分享
-- 回流每日分享
function ComebackActivityService:sendCACBackShareREQ(isManager)
    isManager = isManager == true and true or false
    net.NetworkRequest.new(net.protocol.CACBackShareREQ, self:getServerId()):setBuffer({
        isManager = isManager
    }):execute()
end

-- 回流每日分享回应
function ComebackActivityService:_onACCBackShareRES(response)
    -- 这里只判断是否成功，不做提示
    if response:isSuccessful() then
        local isManagerRequest = response:getRequest():getBuffer().isManager or false
        local buffer = response:getBuffer()
        local itemId = buffer.itemId
        local info = PropReader.getPropById(itemId) or {}
        local name = info.name or ""
        local count = buffer.count
        local content, btns, iconPath
        -- 根据是否是经理的分享请求显示不同的界面
        if isManagerRequest then
            iconPath = info.icon or ""
            content = string.format(config.STRING.ACTIVITY_COMEBACK_SHARE_SUCCESS_MANAGER_FORMAT, name, count)
            btns = {
                {
                    text = config.STRING.ACTIVITY_COMEBACK_SHARE_BTN_TEXT_1,
                    onClick = function()
                        self:comebackShare(isManagerRequest)
                    end
                }
            }
        else
            -- 不是经理显示确认就可以了
            content = string.format(config.STRING.ACTIVITY_COMEBACK_SHARE_SUCCESS_FORMAT, name, count)
            btns = { {
                text = "确定"
            } }
        end

        UIManager:getInstance():show("UIComeback_Dialog", {
            content = content,
            btns = btns,
            iconPath = iconPath,
        })
    end
end

-- 普通用户活动信息请求
function ComebackActivityService:sendCACBackInfoOrdinaryUserREQ(extraData)
    net.NetworkRequest.new(net.protocol.CACBackInfoOrdinaryUserREQ, self:getServerId()):setExtraData(extraData):execute()
end

-- 普通用户活动信息应答
function ComebackActivityService:_onACCBackInfoOrdinaryUserRES(response)
    if response:checkIsSuccessful() then
        -- 说明是每日自动弹出请求
        local buffer = response:getBuffer()
        if response:getRequest():getExtraData() == true then
            -- 每次自动弹出，但不是签到的，就不用管了
            if not buffer.task then
                return
            end
        end

        if buffer.task then
            self._checkInBuffer = buffer
            UIManager:getInstance():show("UIComeback_WeeklyCheckIn")
            self:dispatchEvent({ name = "EVENT_ACTIVITY_COMEBACK_SIGN_COUNT_SYN", data = { signCount = buffer.signCount } })
        else
            UIManager:getInstance():show("UIComeback_Dialog", {
                content = config.STRING.ACTIVITY_COMEBACK_INVITE_CONTENT_1,
                btns = {
                    {
                        text = config.STRING.ACTIVITY_COMEBACK_INVITE_TEXT_1,
                        onClick = function()
                            self:comebackShare(false)
                        end,
                    }
                }
            })
        end
    end
end

-- 请求签到
function ComebackActivityService:sendCACBackSignREQ()
    net.NetworkRequest.new(net.protocol.CACBackSignREQ, self:getServerId()):execute()
end

-- 回应签到
function ComebackActivityService:_onACCBackSignRES(response)
    if response:checkIsSuccessful() then
        if self._checkInBuffer then
            self._checkInBuffer.todaySigned = true
        end
        local rewardInfo = self:getCheckInRewardBySignCount(response:getBuffer().signCount)
        local iconPath = PropReader.getPropById(rewardInfo.itemId).icon
        UIManager:getInstance():show("UIComeback_Dialog", {
            title = config.STRING.ACTIVITY_COMEBACK_SIGN_SUCCESS_TITLE,
            content = config.STRING.ACTIVITY_COMEBACK_SIGN_SUCCESS_CONTENT,
            iconPath = iconPath,
            btns = {
                {
                    text = "分享",
                    onClick = function()
                        self:comebackShare(false)
                    end
                }
            }
        })
        self:dispatchEvent({ name = "EVENT_ACTIVITY_COMEBACK_SIGN_COUNT_SYN", data = { signCount = response:getBuffer().signCount } })
    end
end

-- 俱乐部经理活动信息请求
function ComebackActivityService:sendCACBackInfoClubManagerREQ(extraData)
    net.NetworkRequest.new(net.protocol.CACBackInfoClubManagerREQ, self:getServerId()):setExtraData(extraData):execute()
end

-- 俱乐部经理活动信息回应
function ComebackActivityService:_onACCBackInfoClubManagerRES(response)
    if response:checkIsSuccessful() then
        local buffer = response:getBuffer()
        self._managerBuffer = buffer
        if response:getRequest():getExtraData() == true then
            UIManager:getInstance():show("UIComeback_ClubManager_Welcome", buffer)
        else
            self._increaseCard = buffer.increaseCard
            UIManager:getInstance():show("UIComeback_ClubManager_Lights", buffer)
        end
    end
end

-- 查询经理邀请到的回流用户
function ComebackActivityService:sendCACBackCheckBindUserREQ()
    net.NetworkRequest.new(net.protocol.CACBackCheckBindUserREQ, self:getServerId()):execute()
end

-- 回应经理邀请到的回流用户
function ComebackActivityService:_onACCBackCheckBindUserRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIComeback_ClubManager_BindPlayers", {
            increaseCard = self._increaseCard,
            names = response:getBuffer().nickname
        })
    end
end

-- 提取房卡数量请求
function ComebackActivityService:sendCACBackExtractCardREQ()
    net.NetworkRequest.new(net.protocol.CACBackExtractCardREQ, self:getServerId()):execute()
end

-- 提取房卡数量回应
function ComebackActivityService:_onACCBackExtractCardRES(response)
    if response:checkIsSuccessful() then
        self:dispatchEvent({ name = "EVENT_ACTIVITY_COMEBACK_EXTRACT_CARD_SUCCEED", data = response:getBuffer().card });
        UIManager:getInstance():show("UIComeback_Dialog", {
            content = config.STRING.ACTIVITY_COMEBACK_GET_CARD_SUCCESS,
            btns = {
                {
                    text = "分享",
                    onClick = function()
                        self:comebackShare(true)
                    end
                }
            }
        })
    end
end

-- 分享
function ComebackActivityService:comebackShare(isManager)
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local areaId = game.service.LocalPlayerService.getInstance():getArea()
    local isManagerNum = isManager == true and 1 or 0
    local imageId = math.random(SHARE_IMAGE_ID_MIN, SHARE_IMAGE_ID_MAX)
    local data = {
        enter = share.constants.ENTER.COMEBACK,
        wxInfo = {
            appId = config.UrlConfig.getAppId(),
            redirectUrl = config.UrlConfig.getComebackActivityUrl(),
            state = table.concat({ areaId, roleId, isManagerNum, imageId }, "*")
        },
        sourcePath = SHARE_IMAGE_PATH[imageId] or SHARE_IMAGE_PATH[1]
    }
    share.ShareWTF.getInstance():share(data.enter, { data }, function()
        self:sendCACBackShareREQ(isManager)
        game.service.TDGameAnalyticsService.getInstance():onEvent(game.globalConst.StatisticNames.Activity_Comeback_Share_Image_ .. imageId)
    end)
end

function ComebackActivityService:getIsInFinalRewardTime()
    return self._isInFinalRewardTime
end

function ComebackActivityService:_onACCBackClubDelaySYN(response)
    self._isInFinalRewardTime = true
    self:dispatchEvent({ name = "EVENT_ACTIVITY_COMEBACK_FINAL_REWARD_TIME_SYN" })
end

function ComebackActivityService:managerLeaveTip(leaveCallback)
    local content
    if self:todayIsShared(true) then
        content = config.STRING.ACTIVITY_COMEBACK_MANAGER_LEAVE_TIP_TODAY_SHARED
    else
        content = config.STRING.ACTIVITY_COMEBACK_MANAGER_LEAVE_TIP_TODAY_NO_SHARE
    end
    UIManager.getInstance():show("UIComeback_Dialog", {
        content = content,
        btns = {
            {
                text = config.STRING.ACTIVITY_COMEBACK_MANAGER_LEAVE_TEXT_1,
                onClick = leaveCallback
            },
            {
                text = config.STRING.ACTIVITY_COMEBACK_MANAGER_LEAVE_TEXT_2,
                onClick = function()
                    -- 显示了这个界面则一定是 manager
                    self:comebackShare(true)
                end
            },
        }
    })
end

function ComebackActivityService:getCheckInRewardBySignCount(signCount)
    if self._checkInBuffer then
        local ret = self._checkInBuffer.reward[signCount]
        if signCount == #self._checkInBuffer.reward then
            return ret, self._checkInBuffer.prize
        else
            return ret
        end
    end
end

function ComebackActivityService:getCheckInMaxSignCount()
    if self._checkInBuffer then
        return #self._checkInBuffer.reward
    end
    return 0
end

function ComebackActivityService:getSignedCount()
    if self._checkInBuffer then
        return self._checkInBuffer.signCount
    end
end

function ComebackActivityService:getTodayIsCheckIn()
    if self._checkInBuffer then
        return self._checkInBuffer.todaySigned
    end
    return false
end

function ComebackActivityService:checkAutoShow(sceneName)
    -- 每次首日登录，自动弹出回流签到
    if game.service.ActivityService:getInstance():isActivitieswithin(net.protocol.activityType.COMEBACK) then
        if storageTools.AutoShowStorage.isNeedShow(self.class.__cname .. "|" .. sceneName) then
            if sceneName == "UIClubRoom" then
                self:sendCACBackInfoClubManagerREQ(true)
            elseif sceneName == "UIMain" then
                self:sendCACBackInfoOrdinaryUserREQ(true)
            end
        end
    end
end

function ComebackActivityService:todayIsShared(isManager)
    if isManager == true and self._managerBuffer then
        return self._managerBuffer.todayShared
    elseif isManager == false and self._checkInBuffer then
        return self._checkInBuffer.todayShared
    else
        return false
    end
end

return ComebackActivityService