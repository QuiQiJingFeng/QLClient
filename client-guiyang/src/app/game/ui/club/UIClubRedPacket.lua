------------------------------------------------------------------
local csbPath = "ui/csb/Club/UIClubRedPacket.csb"
local super = require("app.game.ui.UIBase")
local UIClubRedPacket = class("UIClubRedPacket", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRedPacket:ctor()
    self._txtTitle = nil
    self._bmtxtReward = nil
    self._btnClose = nil
    self._txtNum = nil
    self._txtTotal = nil
    self._txtBest = nil
    self._btnShare = nil
end

--析构函数
function UIClubRedPacket:destroy()
	--释放内存
end

--初始化函数
function UIClubRedPacket:init()
	--这里可以写成员的定义等
    self._txtTitle = seekNodeByName(self, "Text_11", "ccui.Text")
    self._bmtxtReward = seekNodeByName(self, "BitmapFontLabel_reward", "ccui.TextBMFont")
    -- self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._txtNum = seekNodeByName(self, "Text_num", "ccui.Text")
    self._txtTotal = seekNodeByName(self, "Text_total", "ccui.Text")
    self._txtBest = seekNodeByName(self, "Text_best", "ccui.Text")
    self._btnShare = seekNodeByName(self, "Button_share", "ccui.Button")

    self._panelGet = seekNodeByName(self, "Panel_qd", "ccui.Layout")
    self._panelNotGet = seekNodeByName(self, "Panel_wqd", "ccui.Layout")

    self._particle = seekNodeByName(self, "Particle_1", "cc.ParticleSystemQuad")

    -- bindEventCallBack(self._btnClose, handler(self, self._onClickedClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onClickedShare), ccui.TouchEventType.ended)

    self._animAction = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._animAction)
end

--显示函数
function UIClubRedPacket:onShow(redPacket, lastStatus)
    --界面显示逻辑
    local info = {}
    info.title = redPacket.title2
    info.reward = string.format("抢到%s元", string.format("%0.2f", redPacket.gainAmount / 100))
    info.num = string.format("已领取%s/%s份",redPacket.totalCount-redPacket.remainCount, redPacket.totalCount)
    info.total = string.format("红包金额：%s", string.format("%0.2f", redPacket.totalAmount / 100))
    local name = game.service.club.ClubService.getInstance():getInterceptString(redPacket.luckyRoleName, 8)
    info.bast = string.format("手气王：%s 领到%s元", name, string.format("%0.2f", redPacket.luckyRoleGainAmount / 100))

    self._txtTitle:setString(info.title)
    self._bmtxtReward:setString(info.reward)
    self._txtNum:setString(info.num)
    self._txtTotal:setString(info.total)
    self._txtBest:setString(info.bast)

    if redPacket.remainCount == 0 then
        self._txtBest:setVisible(true)
    else
        self._txtBest:setVisible(false)
    end

    if redPacket.status == 2 then
        self._panelGet:setVisible(true)
        self._panelNotGet:setVisible(false)
    else
        self._panelGet:setVisible(false)
        self._panelNotGet:setVisible(true)
    end

    -- 如果消息前未打开的红包
    if lastStatus == 1 then
        self._animAction:gotoFrameAndPlay(0, false)
        self._particle:setVisible(true)
    else
        self._animAction:gotoFrameAndPlay(30, false)
        self._particle:setVisible(false)
    end
end

--隐藏函数
function UIClubRedPacket:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIClubRedPacket:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRedPacket:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

--是否需要遮罩
function UIClubRedPacket:needBlackMask()
	return true
end

--关闭时操作
function UIClubRedPacket:closeWhenClickMask()
	return true
end

-- 标记为Persistent的UI不会destroy
function UIClubRedPacket:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIClubRedPacket:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
-- function UIClubRedPacket:_onClickedClose()
-- 	UIManager:getInstance():hide("UIClubRedPacket")
-- end

function UIClubRedPacket:_onClickedShare()
    -- 统计红包分享次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Red_Share);

    share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_RED_ACTIVITY)
    
end

return UIClubRedPacket