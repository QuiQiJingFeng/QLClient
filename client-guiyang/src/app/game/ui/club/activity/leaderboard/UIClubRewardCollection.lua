local csbPath = "ui/csb/Club/UIClubRewardCollection.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")

local M = class("UIClubRewardCollection", super, function() return kod.LoadCSBNode(csbPath) end)


--[[
    领取奖励界面
]]

function M:ctor()
    
end

function M:init()
    self._listRewardInfo = ListFactory.get(
        seekNodeByName(self, "ListView_rewardInfo", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData))
    
    self._imgLabel = seekNodeByName(self, "Image_pm", "ccui.ImageView")
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button")
    self._textTips = seekNodeByName(self, "Image_tiao", "ccui.Text")
    self._textTitle = seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function M:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubRewardCollection")
end

function M:_onListViewInit(listItem)
    listItem._textTime = seekNodeByName(listItem, "Text_time", "ccui.Text") -- 时间
    listItem._textClubName = seekNodeByName(listItem, "Text_clubName", "ccui.Text") -- 俱乐部名称
    listItem._textRanking = seekNodeByName(listItem, "Text_ranking", "ccui.Text") -- 排名
    listItem._textReward = seekNodeByName(listItem, "Text_reward", "ccui.Text") -- 奖励
    listItem._btnReceive = seekNodeByName(listItem, "Button_receive", "ccui.Button") -- 领取
    listItem._imgReceive = seekNodeByName(listItem, "Image_receive", "ccui.ImageView") -- 已领取
    listItem._imgReview = seekNodeByName(listItem, "Image_review", "ccui.ImageView") -- 审核中
end

function M:_onListViewSetData(listItem, data)
    listItem._textTime:setString(os.date("%m-%d", data.time / 1000))
    listItem._textClubName:setString(game.service.club.ClubService.getInstance():getShieldString(data.clubName))
    listItem._textRanking:setString(data.rank)
    listItem._textReward:setString(data.reward)
    listItem._btnReceive:setVisible(data.status == 1)
    listItem._imgReview:setVisible(data.status == 2)
    listItem._imgReceive:setVisible(data.status == 3)

    bindEventCallBack(listItem._btnReceive, function()
        -- 领取奖励
        game.service.club.ClubService.getInstance():getClubActivityService():sendCCLPickClubRankRewardREQ(data.clubId, self._id, data.rankType)
    end, ccui.TouchEventType.ended)
end

function M:onShow(id)
    self._id = id
    self._textTitle:setString(string.format("%s奖励", id == 1 and "群主" or "成员"))
    self._listRewardInfo:deleteAllItems()
    game.service.club.ClubService.getInstance():getClubActivityService():addEventListener(
        "EVENT_CLUB_RANK_REWARD_LIST",
        handler(self, self._onEventClubRankRewardList),
    self)

    game.service.club.ClubService.getInstance():getClubActivityService():addEventListener(
        "EVENT_CLUB_RANK_REWARD_INFO_CHANGE",
        handler(self, self._onRewardInfoChange),
        self)

    game.service.club.ClubService.getInstance():getClubActivityService():sendCCLQueryRankRewardListREQ(id)
end

function M:_onEventClubRankRewardList(event)
    self._listRewardInfo:deleteAllItems()
    self._textTips:setVisible(true)
    if #event.rankRewardList < 1 then
        return
    end
    self._textTips:setVisible(false)

    -- 排序
    table.sort(event.rankRewardList, function(a, b)
        if a.rankType == b.rankType then
            return a.time > b.time
        end
        return a.rankType > b.rankType
    end)

    for _, rewardInfo in ipairs(event.rankRewardList) do
        self._listRewardInfo:pushBackItem(rewardInfo)
    end
end

-- 更新领取状态
function M:_onRewardInfoChange(event)
    local itemIdx, data = self:_indexOfInvitation(event.clubId, event.rankType)
    if Macro.assertFalse(itemIdx ~= false) then
        data.status = event.status
        -- 红包特殊处理一下
        if event.status == 2 then
            local areaId = game.service.LocalPlayerService:getInstance():getArea()
            local weChat = MultiArea.getNoPublic(areaId)
            local text = string.format("审核提交成功。聚友工作人员将会在一个工作日内确认您的信息，为您发放奖励，请您关注公众号“%s”领取您的红包奖励；", weChat)
            if data.needManualSend then
                weChat = MultiArea.getWeChat(areaId)
                text = string.format("恭喜您在本次活动中位列三甲，请添加客服微信号“%s”，我们的工作人员将为您发放本次活动奖励", weChat)
            end
            game.ui.UIMessageBoxMgr.getInstance():show(
                text,
                {"复制", "取消"},
                function() 
                    if game.plugin.Runtime.setClipboard(weChat) == true then
                        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
                        cc.Application:getInstance():openURL("weixin://")
                    end	
                end
            )
        end
        self._listRewardInfo:updateItem(itemIdx, data)
    end
end

-- 查找item
function M:_indexOfInvitation(clubId, rankType)
    for idx, item in ipairs(self._listRewardInfo:getItemDatas()) do
        if item.clubId == clubId and item.rankType == rankType then
            return idx, item
        end
    end

    return false;
end

function M:onHide()
    game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
    self._listRewardInfo:deleteAllItems()
end

function M:needBlackMask()
    return true
end

function M:closeWhenClickMask()
    return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M