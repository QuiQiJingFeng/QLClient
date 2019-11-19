local csbPath = "ui/csb/mengya/club/UIClubHistoryRecord.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UIClubHistoryRecordItem = import("items.UIClubHistoryRecordItem")
local EDITBOX_INPUT_MODE_NUMERIC = 2

local UIClubHistoryRecord = class("UIClubHistoryRecord", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIClubHistoryRecord:ctor()
    
end

function UIClubHistoryRecord:init()
    --返回
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    --战绩显示模块
    local node = Util:seekNodeByName(self,"scrollListHistory","ccui.ScrollView")
    self._scrollListHistory = UITableView.extend(node,UIClubHistoryRecordItem)
    self._btnPre = Util:seekNodeByName(self,"btnPre","ccui.Button")
    self._btnNext = Util:seekNodeByName(self,"btnNext","ccui.Button")
    Util:bindTouchEvent(self._btnPre,handler(self,self._onBtnPreClick))
    Util:bindTouchEvent(self._btnNext,handler(self,self._onBtnNextClick))

    --查看回放
    self._btnViewPlayBack = Util:seekNodeByName(self,"btnViewPlayBack","ccui.Button")
    Util:bindTouchEvent(self._btnViewPlayBack,handler(self,self._onBtnViewPlayBackClick))
    
    --搜索模块
    self._panelSearch = Util:seekNodeByName(self,"panelSearch","ccui.Layout")
    self._panelSearchOriginY = self._panelSearch:getPositionY()
    local node = Util:seekNodeByName(self,"txtFieldRoomNumber","ccui.TextField")
    self._txtFieldRoomNumber = Util:replaceTextFieldToEditBox(Util:seekNodeByName(self,"txtFieldRoomNumber","ccui.TextField"))
    self._txtFieldRoomNumber:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
    self._btnClear = Util:seekNodeByName(self,"btnClear","ccui.Button")
    self._btnSearch = Util:seekNodeByName(self,"btnSearch","ccui.Button")
    self._txtFieldRoomNumber:registerScriptEditBoxHandler(handler(self,self._onTextFieldRoomNumberClick))
    Util:bindTouchEvent(self._btnClear,handler(self,self._onBtnClearClick))
    Util:bindTouchEvent(self._btnSearch,handler(self,self._onBtnSearchClick))
    
    --筛选模块
    self._btnFilter = Util:seekNodeByName(self,"btnFilter","ccui.Button")
    self._txtFilterDetail = Util:seekNodeByName(self,"txtFilterDetail","ccui.Text")
    Util:bindTouchEvent(self._btnFilter,handler(self,self._onBtnFilterClick))

end

--[[筛选模块]]
function UIClubHistoryRecord:_onBtnFilterClick()
    UIManager:getInstance():show("UIClubHistoryFilter")
end

--[[搜索模块]]
function UIClubHistoryRecord:_onTextFieldRoomNumberClick(eventName,pSender)
    if eventName == "began" then
        self._panelSearch:setPositionY(self._panelSearchOriginY + display.height/2)
    elseif eventName == "ended" then
        self._panelSearch:setPositionY(self._panelSearchOriginY)
    end
end
function UIClubHistoryRecord:_onBtnClearClick()
    self._txtFieldRoomNumber:setText("")
end
function UIClubHistoryRecord:_onBtnSearchClick()
    --筛选
end


--[[战绩模块]]
function UIClubHistoryRecord:_onBtnPreClick()
    
end

function UIClubHistoryRecord:_onBtnNextClick()
    
end

--[[查看他人回放]]
function UIClubHistoryRecord:_onBtnViewPlayBackClick()
    
end

--[[返回]]
function UIClubHistoryRecord:_onBtnBackClick()
    UIManager:getInstance():hide("views.UIClubHistoryRecord")
end

function UIClubHistoryRecord:onShow()
    self._scrollListHistory:updateDatas({ {},{},{},{},{},{},{},{},{}})
end

function UIClubHistoryRecord:isFullScreen()
    return true
end

return UIClubHistoryRecord