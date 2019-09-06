local csbPath = app.UIClubDataStatisticsCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UIClubDataStatisticsItem = app.UIClubDataStatisticsItem
local UIClubDataStatistics = class("UIClubDataStatistics", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubDataStatistics:ctor()
    
end

function UIClubDataStatistics:init()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))
    self._txtTitleMark = Util:seekNodeByName(self,"txtTitleMark","ccui.Text")
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIClubDataStatisticsItem,handler(self,self._onItemClick))

    self._pageContent = Util:seekNodeByName(self,"pageContent","ccui.PageView")

    self._panelTimeFilter = Util:seekNodeByName(self,"panelTimeFilter","ccui.Layout")
end

function UIClubDataStatistics:_onItemClick(item,data,eventType)
    if data.titleMark then
        self._txtTitleMark:setString(data.titleMark)
    end
    if data.ignoreTimeFilter then
        self._panelTimeFilter:setVisible(false)
    else
        self._panelTimeFilter:setVisible(true)
    end
    

    self._pageContent:setCurrentPageIndex(data.pageIndex - 1)
end

function UIClubDataStatistics:_onBtnBackClick()
    UIManager:getInstance():hide("UIClubDataStatistics")
end

function UIClubDataStatistics:needBlackMask()
	return false
end

function UIClubDataStatistics:isFullScreen()
    return true
end

function UIClubDataStatistics:onShow()
    local datas = {
        [1] = {name = "牌局数",selected = false,titleMark="牌局数",pageIndex = 1},
        [2] = {name = "大赢家次数",selected = false,titleMark="大赢家次数",pageIndex = 1},
        [3] = {name = "积分积累",selected = false,titleMark="积分累计",pageIndex = 1},
        [4] = {name = "赢分积累",selected = false,titleMark="赢分累计",pageIndex = 1},
        [5] = {name = "数据日报",selected = false,pageIndex = 2,ignoreTimeFilter = true},
    }
    self._scrollListLeft:updateDatas(datas)
    local selectIdx = 1
    local item = self._scrollListLeft:getCellByIndex(selectIdx)
    self:_onItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

return UIClubDataStatistics