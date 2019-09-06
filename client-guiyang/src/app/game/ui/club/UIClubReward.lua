local csbPath = "ui/csb/Club/UIClubReward.csb" --ui文件
local super = require("app.game.ui.UIBase")

local UIClubReward = class("UIClubReward",super,function () return kod.LoadCSBNode(csbPath) end )

--构造函数
function UIClubReward:ctor()
	--这里可以写成员的声明等
	self._reward = nil
	self._btnRewardClose = nil
	self._imgRewardImg = nil
	self._btnShare = nil
	self._btnGet = nil

	self._noReward = nil
	self._noRewardClose = nil
end

--析构函数
function UIClubReward:destroy()
	--释放内存
end

--初始化函数
function UIClubReward:init()
	--这里可以写成员的定义等
	self._reward = seekNodeByName(self, "Panel_1", "ccui.Layout")
	self._btnRewardClose = seekNodeByName(self, "Button_Close_Clubcj", "ccui.Layout")
	self._imgRewardImg = seekNodeByName(self, "Image_2_0", "ccui.ImageView")
	self._btnShare = seekNodeByName(self, "Button_share", "ccui.Button")
	self._btnGet = seekNodeByName(self, "Button_share_0", "ccui.Button")

	self._noReward = seekNodeByName(self, "Panel_2", "ccui.Layout")
	self._btnNoRewardClose = seekNodeByName(self, "Button_Close_noreward", "ccui.Layout")
	self._textContent = seekNodeByName(self, "Text_1", "ccui.Text")

	bindEventCallBack(self._btnRewardClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnNoRewardClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)

	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnGet, handler(self, self._onClickGet), ccui.TouchEventType.ended)

	self._animation =  cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._animation)
end

--显示函数
function UIClubReward:onShow(is, roomCard)
	--界面显示逻辑
	if is then
		self._reward:setVisible(true)
		self._noReward:setVisible(false)
		self._animation:gotoFrameAndPlay(0, false)
	else
		self._reward:setVisible(false)
		self._noReward:setVisible(true)
		if roomCard == 0 then
			self._textContent:setVisible(false)
		else
			self._textContent:setVisible(true)
			self._textContent:setString(string.format(config.STRING.UICLUBREWARD_STRING_100, roomCard))
		end
	end
end

--隐藏函数
function UIClubReward:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIClubReward:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubReward:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

--是否需要遮罩
function UIClubReward:needBlackMask()
	return true;
end

--关闭时操作
function UIClubReward:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIClubReward:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIClubReward:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
function UIClubReward:_onClickClose()
	UIManager:getInstance():hide("UIClubReward")
end

function UIClubReward:_onClickShare()
    share.ShareWTF.getInstance():share(share.constants.ENTER.CLUB_REWARD_ACTIVITY)
end

function UIClubReward:_onClickGet()
    game.service.GiftService:getInstance():queryGoods()
end

return UIClubReward;
