local csbPath = "ui/csb/Activity/Comeback2/UIComebackInvite.csb"
local super = require("app.game.ui.UIBase")
local SHARE_ICON = "art/activity/pullNew.jpg"

local UIComebackInvite = class("UIComebackInvite", super, function () return kod.LoadCSBNode(csbPath) end)
-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIComebackRewardItem = class("UIComebackRewardItem")

function UIComebackRewardItem:ctor( uiroot , data, idx)
    self._uiroot = uiroot
    self.idx = idx

    self:_initialize()
    self:setData(data)
end

function UIComebackRewardItem:_initialize()
    self._rewardIcon = seekNodeByName(self._uiroot, "Image_Reward", "ccui.ImageView")
    self._rewardText = seekNodeByName(self._uiroot, "Text_Reward", "ccui.TextBMFont")
    self._btnReward  = seekNodeByName(self._uiroot, "Button_Receive", "ccui.Button")
    self._flagReceive = seekNodeByName(self._uiroot, "hasReceivedFlag", "ccui.ImageView")
    self._scheduleText = seekNodeByName(self._uiroot, "TextSchedule", "ccui.TextBMFont")
    self._examine = seekNodeByName(self._uiroot, "hasReceivedFlag_0", "ccui.ImageView")
    self._outofdata = seekNodeByName(self._uiroot, "TextSchedule", "ccui.TextBMFont")
end

function UIComebackRewardItem:getData()
    return self._data
end

function UIComebackRewardItem:setData( applicationInfo )
    self._data = applicationInfo
    PropReader.setIconForNode(self._rewardIcon,"art/activity/lcyhl/img_hbt_lcy.png")
    self._rewardText:setString("+" .. applicationInfo.count .. "元")
    self._scheduleText:setString(string.format( "%s/%s人", applicationInfo.now,applicationInfo.total ))
    self._btnReward:setVisible(applicationInfo.status == 1)
    self._flagReceive:setVisible(applicationInfo.status == 2)
    self._scheduleText:setVisible(applicationInfo.status == 0)
    self._examine:setVisible(applicationInfo.status == 3)
    if applicationInfo.status == 5 then
        self._scheduleText:setVisible(true)
        self._scheduleText:setString("未通过")
    end

    if applicationInfo.status == 4 then
        self._scheduleText:setVisible(true)
        self._scheduleText:setString("已失效")
    end

    bindEventCallBack(self._btnReward, handler(self, self._onBtnReward), ccui.TouchEventType.ended)
end

function UIComebackRewardItem:_onBtnReward()
    game.service.ActivityService.getInstance():sendCACQueryPickRewardREQ(1,self.idx)
end
-------------------------------------------------------------------------------------
function UIComebackInvite:ctor()
    self._btnClose = nil
    self._btnInvite = nil
    self._rewardList = nil
    self._btnHelp = nil
end

function UIComebackInvite:init()
    self._btnClose = seekNodeByName(self, "Button_1_0", "ccui.Button")
    self._btnInvite = seekNodeByName(self, "Button_Invite", "ccui.Button")
    self._rewardList = seekNodeByName(self, "ListView_Reward", "ccui.ListView")
    self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button")
    self._panelModel = seekNodeByName(self, "Panel_2", "ccui.Layout")
    self._panelSpModel = seekNodeByName(self, "Panel_2_sp", "ccui.Layout")

    self._panelModel:removeFromParent()
    self._panelModel:retain()
    self._panelModel:setVisible(false)

    self._panelSpModel:removeFromParent()
    self._panelSpModel:retain()
    self._panelSpModel:setVisible(false)    

    self:_registerCallback()
end

function UIComebackInvite:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite, handler(self, self._onBtnShareClick), ccui.TouchEventType.ended)
end

function UIComebackInvite:onShow( ... )
    local args = { ... }
    self._data = args[1]
    self._rewardList:removeAllItems()
    for idx,member in ipairs(self._data.rewards) do
        local item = nil
        if idx ~= #self._data.rewards then
            item = self._panelModel:clone()
        else
            item = self._panelSpModel:clone()
        end
        item:setVisible(true)
        local cell = UIComebackRewardItem.new(item,member,idx)
        self._rewardList:addChild(item)
    end
end

function UIComebackInvite:refreshData(data)
    self._data = data
    self._rewardList:removeAllItems()
    for idx,member in ipairs(self._data.rewards) do
        local item = nil
        if idx ~= #self._data.rewards then
            item = self._panelModel:clone()
        else
            item = self._panelSpModel:clone()
        end
        item:setVisible(true)
        local cell = UIComebackRewardItem.new(item,member,idx)
        self._rewardList:addChild(item)
    end
end


function UIComebackInvite:_onBtnShareClick()

	local activityService = game.service.ActivityService.getInstance()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local unionId = activityService:getUnionId()
    local area = game.service.LocalPlayerService:getInstance():getArea()
	local channelId = game.plugin.Runtime.getChannelId() ~= 0 and game.plugin.Runtime.getChannelId() or 100000
	local startTime = activityService:activityTime(net.protocol.activityType.WEIXIN_SHARE)
	if Macro.assetTrue(startTime == nil) then return end
    local shareUrl = config.UrlConfig.getComebackInviteUrl()
    
    local localPlayerService = game.service.LocalPlayerService:getInstance()
    local roleId = localPlayerService:getRoleId()
    local area = localPlayerService:getArea()
	local activityId = net.protocol.activityType.WEIXIN_SHARE
	-- 下载二维码
    local data =
    {
        enter = share.constants.ENTER.SHARE_PULLNEW,
        wxInfo = {
            redirectUrl = shareUrl,
            appId = config.UrlConfig.getAppId(),
            state = table.concat({ area, roleId, unionId, channelId, startTime.startTime}, "*"),
            pos = {x = 320, y = 180, scale = 0.7}
        },
        sourcePath = SHARE_ICON,
    }    
    
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.comebackInvite_invite_click)
    share.ShareWTF.getInstance():share(data.enter, { data }, function()
    end)
end

function UIComebackInvite:_onClickHelp()
	-- str = string.format(str, self._rewardInfo[self._currentPageId].gongZhongHao)
	local str = [[
邀请人奖励：

1.邀请好友回归游戏，在活动界面点击立即邀请分享活动图片至微信，受邀玩家微信扫码可以与邀请者建立绑定关系；
2.七天内未登录，且曾打牌至少8局以上的玩家，可被邀请；
3.被邀请玩家登录游戏完成8局好友桌牌局，邀请者可获得红包奖励；
4.红包奖励可关注微信公众号“聚友互动”，点击“领红包”、“提现”领取红包；
5.活动期间，最多可邀请6位新玩家，邀请玩家数越多，奖励越丰厚，合计50元红包；
	]]
	UIManager:getInstance():show('UITurnCardHelp', str)
end

function UIComebackInvite:_onClose()
    UIManager:getInstance():destroy("UIComebackInvite")
end

function UIComebackInvite:needBlackMask()
	return true;
end

function UIComebackInvite:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIComebackInvite:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

function UIComebackInvite:dispose()
    self._panelModel:release()
    self._panelModel = nil
    self._panelSpModel:release()
    self._panelSpModel = nil
end

return UIComebackInvite