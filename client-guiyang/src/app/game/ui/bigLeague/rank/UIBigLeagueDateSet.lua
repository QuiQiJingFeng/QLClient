--[[
	时间选择界面，继承自俱乐部的时间选择，改了下返回函数
]]
local csbPath = "ui/csb/Club/UIClubDateChoice.csb"
local super = require("app.game.ui.club.record.UIClubHistoryDateSet")
local UIBigLeagueDateSet = class("UIBigLeagueDateSet", super)
local TOTAL_SHOW_NUM = 7
function UIBigLeagueDateSet:ctor()
end

function UIBigLeagueDateSet:_registerCheckBox(cbox, i)
	local isSelected = false
	cbox:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			isSelected = cbox:isSelected()
		elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if self._ui then			
                self._ui:_setTime(TOTAL_SHOW_NUM - i)
            else
                local ui = UIManager.getInstance():getUI('UIBigLeagueHistoryFilter')
                ui:_setTime(self._times[i])
            end
            UIManager.getInstance():hide('UIBigLeagueDateSet')
		elseif eventType == ccui.TouchEventType.canceled then
			cbox:setSelected(isSelected)
		end
	end)
end

function UIBigLeagueDateSet:_resetBtnSelected()
    self._times = self._times or {}
	for i=TOTAL_SHOW_NUM, 1, -1 do
		local dis = (TOTAL_SHOW_NUM-i)*24*60*60
		self._times[i] = self._showTime - dis
		local date = os.date("%Y-%m-%d", self._times[i])
		self['_btnDate'..i]:setSelected(date==self._selectDate)
        self['_textDate'..i]:setString(os.date("%m-%d", self._times[i]))
        self['_btnDate'..i]:setVisible(true)
    end
    
    for i = TOTAL_SHOW_NUM+1, 15 do
        self['_btnDate'..i]:setVisible(false)
    end
end

function UIBigLeagueDateSet:onShow(time, ui)
	super.onShow(self, time)
    self._ui = ui
    
    self:playAnimation_Scale()
end

function UIBigLeagueDateSet:needBlackMask()
    return true
end

function UIBigLeagueDateSet:closeWhenClickMask()
    return true
end
return UIBigLeagueDateSet