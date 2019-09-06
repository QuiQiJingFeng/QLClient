local csbPath = app.UIClubMainCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UITableViewEx = app.UITableViewEx
local UIClubMainLeftItem = app.UIClubMainLeftItem
local UIClubMainMyClubItem = app.UIClubMainMyClubItem
local UIClubMain = class("UIClubMain", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubMain:init()
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIClubMainLeftItem,handler(self,self._onItemTabClick))
    self._pageContent = Util:seekNodeByName(self,"pageContent","ccui.PageView")

    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))

    local node = Util:seekNodeByName(self,"scrollListClub","ccui.ScrollView")
    self._scrollListClub = UITableViewEx.extend(node,UIClubMainMyClubItem,handler(self,self._onMyClubItemClick))
    self._scrollListClub:perUnitNums(2)
    self._scrollListClub:setDeltUnit(15)
    self._scrollListClub:setDeltUnitFlix(15)
end

function UIClubMain:_onMyClubItemClick()
    app.GameFSM:getInstance():enterState("GameState_Club")
end

function UIClubMain:_onBtnCloseClick()
    UIManager:getInstance():hide("UIClubMain")
end

function UIClubMain:_onItemTabClick(item,data,eventType)
    self._pageContent:setCurrentPageIndex(data.pageIndex - 1)
end

function UIClubMain:onShow()
    local datas = {
        {name = "加入亲友圈",pageIndex = 1},
        {name = "创建亲友圈",pageIndex = 2},
        {name = "我的亲友圈",pageIndex = 3}
    }
    self._scrollListLeft:updateDatas(datas)

    local selectIdx = 1
    local item = self._scrollListLeft:getCellByIndex(selectIdx)
    self:_onItemTabClick(item,datas[selectIdx],ccui.TouchEventType.ended)


    self._scrollListClub:updateDatas({ {},{},{},{},{},{},{},{},{},{},{},{} })
end

function UIClubMain:onHide()
    
end

function UIClubMain:needBlackMask()
    return true
end

return UIClubMain