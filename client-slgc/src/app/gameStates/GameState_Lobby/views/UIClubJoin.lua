local csbPath = "ui/csb/mengya/club/UIClubMain.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UITableViewEx = game.UITableViewEx
local UIClubJoinLeftItem = import("items.UIClubJoinLeftItem")
local UIClubJoinMyClubItem = import("items.UIClubJoinMyClubItem")
local UIClubJoin = class("UIClubJoin", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIClubJoin:init()
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIClubJoinLeftItem,handler(self,self._onItemTabClick))
    self._pageContent = Util:seekNodeByName(self,"pageContent","ccui.PageView")

    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))

    local node = Util:seekNodeByName(self,"scrollListClub","ccui.ScrollView")
    self._scrollListClub = UITableViewEx.extend(node,UIClubJoinMyClubItem,handler(self,self._onMyClubItemClick))
    self._scrollListClub:perUnitNums(2)
    self._scrollListClub:setDeltUnit(15)
    self._scrollListClub:setDeltUnitFlix(15)
end

function UIClubJoin:_onMyClubItemClick()
    game.GameFSM:getInstance():enterState("GameState_Club")
end

function UIClubJoin:_onBtnCloseClick()
    UIManager:getInstance():hide("views.UIClubJoin")
end

function UIClubJoin:_onItemTabClick(item,data,eventType)
    self._pageContent:setCurrentPageIndex(data.pageIndex - 1)
end

function UIClubJoin:onShow()
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

function UIClubJoin:onHide()
    
end

function UIClubJoin:needBlackMask()
    return true
end

return UIClubJoin