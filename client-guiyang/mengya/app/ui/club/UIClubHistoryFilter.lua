local csbPath = app.UIClubHistoryFilterCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UIClubHistoryFilter = class("UIClubHistoryFilter", super, function() return app.Util:loadCSBNode(csbPath) end)
local EDITBOX_INPUT_MODE_NUMERIC = 2
function UIClubHistoryFilter:ctor()
    
end

function UIClubHistoryFilter:init()
    self._btnCancel = Util:seekNodeByName(self,"btnCancel","ccui.Button")
    self._btnConfirm = Util:seekNodeByName(self,"btnConfirm","ccui.Button")
    Util:bindTouchEvent(self._btnCancel,handler(self,self._onBtnCancelClick))
    Util:bindTouchEvent(self._btnConfirm,handler(self,self._onBtnConfirmClick))

    self._txtFieldMinScore = Util:replaceTextFieldToEditBox(Util:seekNodeByName(self,"txtFieldMinScore","ccui.TextField"))
    self._txtFieldMinScore:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
    --是否只看中途解散
    self._cbxOnlyDestroy = Util:seekNodeByName(self,"cbxOnlyDestroy","ccui.CheckBox")
    --是否只看牌局中的房间
    self._cbxOnlyInRoom = Util:seekNodeByName(self,"cbxOnlyInRoom","ccui.CheckBox")
    
    --时间筛选
    self._txtDateBegin = Util:seekNodeByName(self,"txtDateBegin","ccui.Text")
    self._txtDateEnd = Util:seekNodeByName(self,"txtDateEnd","ccui.Text")
    self._btnChangeBegin = Util:seekNodeByName(self,"btnChangeBegin","ccui.Button")
    self._btnSelectTimeBegin = Util:seekNodeByName(self,"btnSelectTimeBegin","ccui.Button")
    self._btnChangeEnd = Util:seekNodeByName(self,"btnChangeEnd","ccui.Button")
    self._btnSelectTimeEnd = Util:seekNodeByName(self,"btnSelectTimeEnd","ccui.Button")
    Util:bindTouchEvent(self._btnChangeBegin,handler(self,self._onBtnChangeBeginClick))
    Util:bindTouchEvent(self._btnSelectTimeBegin,handler(self,self._onBtnChangeBeginClick))
    Util:bindTouchEvent(self._btnChangeEnd,handler(self,self._onBtnChangeEndClick))
    Util:bindTouchEvent(self._btnSelectTimeEnd,handler(self,self._onBtnChangeEndClick))
end

function UIClubHistoryFilter:_onBtnChangeBeginClick()
    UIManager:getInstance():show("UIClubDateSelect",function(data) 
        self._beginTime = data.time
        local strBeginTime = Util:getFormatDate("%Y-%m-%d",data.time)
        self._txtDateBegin:setString(strBeginTime)
    end)
end

function UIClubHistoryFilter:_onBtnChangeEndClick()
    UIManager:getInstance():show("UIClubDateSelect",function(data)
        self._endTime = data.time
        local strEndTime = Util:getFormatDate("%Y-%m-%d",data.time) 
        self._txtDateEnd:setString(strEndTime)
    end)
end


function UIClubHistoryFilter:_onBtnCancelClick()
    UIManager:getInstance():hide("UIClubHistoryFilter")
end

function UIClubHistoryFilter:_onBtnConfirmClick()
    if self._beginTime > self._endTime then
        app.ui.UIMessageTipsMgr.getInstance():showTips("开始时间不能大于结束时间") 
    end
    local isOnlyDestroy = self._cbxOnlyDestroy:isSelected()
    local isOnlyInRoom = self._cbxOnlyInRoom:isSelected()
    --发送请求
    UIManager:getInstance():hide("UIClubHistoryFilter")
end

function UIClubHistoryFilter:needBlackMask()
	return true
end

function UIClubHistoryFilter:onShow()

end

return UIClubHistoryFilter;