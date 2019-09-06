local csbPath = "ui/csb/Gold/UIGoldBegin.csb"
local super = require("app.game.ui.UIBase")
local UIGoldBegin = class("UIGoldBegin", super, function() return kod.LoadCSBNode(csbPath) end)
local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade

function UIGoldBegin:ctor()
	
end

function UIGoldBegin:needBlackMask()
	return true
end


function UIGoldBegin:init()
	self._text = seekNodeByName(self, "TextRoomInfo", "ccui.Text")

	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)
end


function UIGoldBegin:onShow()
	

	--获取当前金币房间类型
	local goldService = game.service.GoldService.getInstance()
	local roomGrade = goldService:getCurrentRoomGrade()
	if Macro.assetTrue(roomGrade == 0, "获取当前金币房间类型失败") then
		UIManager.getInstance():hide("UIGoldBegin")
		return
	end
	--播放动画
	self._action:gotoFrameAndPlay(0, false)
    --根据显示的类型设置收取的服务费
    local roomInfo = goldService:getRoomInfo(roomGrade)
	if roomInfo then
        self._text:setString(string.format("底分:%d\n服务费:%d\n最低入场:%d", roomInfo.bottomScore, roomInfo.roomService, roomInfo.minGold))
    else
        self._text:setString("")
    end
	--动画完成后隐藏界面
	scheduleOnce(function() UIManager.getInstance():hide("UIGoldBegin") end, 1.2)
end

function UIGoldBegin:onHide()
	
end

function UIGoldBegin:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end


return UIGoldBegin 