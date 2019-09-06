local csbPath = "ui/csb/Club/UIClubDateChoice.csb"
local super = require("app.game.ui.UIBase")
local UIClubHistoryDateSet = class("UIClubHistoryDateSet", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubHistoryDateSet:ctor()
end

function UIClubHistoryDateSet:_registerCheckBox(cbox, i)
	local isSelected = false
	cbox:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			isSelected = cbox:isSelected()
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			local ui = UIManager.getInstance():getUI('UIClubHistoryFilter')
            ui:_setTime(self._times[i])
            UIManager.getInstance():hide('UIClubHistoryDateSet')
		elseif eventType == ccui.TouchEventType.canceled then
			cbox:setSelected(isSelected)
		end
	end)
end

function UIClubHistoryDateSet:init()
    for i=1,15 do
        self['_btnDate'..i]= seekNodeByName(self, "CheckBox_Date_"..i,      "ccui.CheckBox")
        self:_registerCheckBox(self['_btnDate'..i], i)
        self['_textDate'..i]             = self['_btnDate'..i]:getChildByName('BitmapFontLabel_3')
    end
end


function UIClubHistoryDateSet:_resetBtnSelected()
	self._times = self._times or {}
	for i=15, 1, -1 do
		local dis = (15-i)*24*60*60
		self._times[i] = self._showTime - dis
		local date = os.date("%Y-%m-%d", self._times[i])
		self['_btnDate'..i]:setSelected(date==self._selectDate)
		self['_textDate'..i]:setString(os.date("%m-%d", self._times[i]))
	end
end

function UIClubHistoryDateSet:onShow(time)
    self._showTime = kod.util.Time.now()
    local date = os.date("%Y-%m-%d", time)
    self._selectDate = date
    self:_resetBtnSelected()
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubHistoryDateSet:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

function UIClubHistoryDateSet:onHide()
end
return UIClubHistoryDateSet