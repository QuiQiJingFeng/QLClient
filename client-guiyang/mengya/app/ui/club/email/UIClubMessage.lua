local csbPath = app.UIClubMessageCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UIClubMessageLeftItem = app.UIClubMessageLeftItem
local UIClubMessageOperation = app.UIClubMessageOperation
local UIClubMessageApproving = app.UIClubMessageApproving
local UIClubMessageNotice = app.UIClubMessageNotice
local UIClubMessageEmail = app.UIClubMessageEmail

local UIClubMessage = class("UIClubMessage", super, function() return app.Util:loadCSBNode(csbPath) end)

local EMAIL_TYPE = {
    OPERATION = 1,
    APPROVING = 2,
    NOTICE = 3,
    EMAIL = 4
}

function UIClubMessage:ctor()
    
end

function UIClubMessage:init()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))
    --左侧列表
    local node = Util:seekNodeByName(self,"scrollListLeft","ccui.ScrollView")
    self._scrollListLeft = UITableView.extend(node,UIClubMessageLeftItem,handler(self,self._onMessageTabClick))
    --pageView
    self._pageContent = Util:seekNodeByName(self,"pageContent","ccui.PageView")
    --初始化动态模块
    self._uiOperation = UIClubMessageOperation.new(Util:seekNodeByName(self,"panelOperation","ccui.Layout"))
    --审批模块
    self._uiApproving = UIClubMessageApproving.new(Util:seekNodeByName(self,"panelApproving","ccui.Layout"))
    --公告模块
    self._uiNotice = UIClubMessageNotice.new(Util:seekNodeByName(self,"panelNotice","ccui.Layout"))
    --邮件模块
    self._uiEmail = UIClubMessageEmail.new(Util:seekNodeByName(self,"panelEmail","ccui.Layout"))
    self._pageViews = {}
    self._pageViews[EMAIL_TYPE.OPERATION] = self._uiOperation
    self._pageViews[EMAIL_TYPE.APPROVING] = self._uiApproving
    self._pageViews[EMAIL_TYPE.NOTICE] = self._uiNotice
    self._pageViews[EMAIL_TYPE.EMAIL] = self._uiEmail
end

function UIClubMessage:_onMessageTabClick(item,data,eventType)
    --发送请求
    ----[[测试
        self._pageViews[data.pageId]:onShow()
        self._pageContent:setCurrentPageIndex(data.pageId - 1)
    --]]
end

function UIClubMessage:_onBtnBackClick()
    UIManager:getInstance():hide("UIClubMessage")
end

function UIClubMessage:_onBtnConfirmClick()
    --向服务器请求
end

function UIClubMessage:isFullScreen()
    return true
end

function UIClubMessage:onShow()

    local datas = {
        {name = "动态", pageId = EMAIL_TYPE.OPERATION, sortId = 1,selected = false,isRed = false},
        {name = "审批", pageId = EMAIL_TYPE.APPROVING, sortId = 2,selected = false,isRed = false},
        {name = "公告", pageId = EMAIL_TYPE.NOTICE, sortId = 3,selected = false,isRed = false},
        {name = "邮件", pageId = EMAIL_TYPE.EMAIL, sortId = 4,selected = false,isRed = true},
    }

    self._scrollListLeft:updateDatas(datas)

    local selectIdx = 1
    local item = self._scrollListLeft:getCellByIndex(selectIdx)
    self:_onMessageTabClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UIClubMessage:onHide()
    for _, page in ipairs(self._pageViews) do
        page:dispose()
    end
end

return UIClubMessage