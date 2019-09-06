local csbPath = "ui/csb/Mail/UIApplicationPage2.csb"
local super = require("app.game.ui.UIBase")
---@class UIApplicationPage2:UIBase
local UIApplicationPage2 = class("UIApplicationPage2", function() return cc.CSLoader:createNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local STATUS_TYPE = {
    "art/club/imgt_3.png",
    "art/club/imgt_1.png",
    "art/club/imgt_2.png",
}

function UIApplicationPage2:ctor()
    self._textPrompt = seekNodeByName(self, "Text_tiao", "ccui.Text")

    self._reusedListApplication = ListFactory.get(
            seekNodeByName(self, "ListView_Application", "ccui.ListView"),
            handler(self, self._onListViewInit),
            handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListApplication:setScrollBarEnabled(false)
end

function UIApplicationPage2:show(parent)
    self:setVisible(true)
    self:setPosition(0, 0)
    self._parent = parent

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._bigLeagueService:sendCCLQueryApprovalREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_APPROVAL", handler(self, self._upadtaListView), self)

    self:_upadtaListView()
end

function UIApplicationPage2:_upadtaListView()
    self._reusedListApplication:deleteAllItems()

    if #self._bigLeagueService:getLeagueData():getApprovalInfo() < 1 then
        self._textPrompt:setVisible(true)
        return
    end

    self._textPrompt:setVisible(false)

    for _, approval in ipairs(self._bigLeagueService:getLeagueData():getApprovalInfo()) do
        self._reusedListApplication:pushBackItem(approval)
    end
end

-- 查找item
function UIApplicationPage2:_indexOfApplicationItem(roleId)
    for idx,item in ipairs(self._reusedListApplication:getItemDatas()) do
        if item.roleId == roleId then
            return idx
        end
    end

    return false;
end

function UIApplicationPage2:_onListViewInit(listView)
    listView.imgLeagueIcon = seekNodeByName(listView, "Image_Icon", "ccui.ImageView") -- 联盟头像
    listView.textLeagueName = seekNodeByName(listView, "Text_LeagueName", "ccui.Text") -- 联盟名称
    listView.textLeagueId = seekNodeByName(listView, "Text_LeagueId", "ccui.Text") -- 联盟Id
    listView.textOwner = seekNodeByName(listView, "Text_Owner", "ccui.Text") -- 盟主
    listView.textLeaguerCount = seekNodeByName(listView, "Text_LeaguerCount", "ccui.Text") -- 联盟人数
    listView.btnRefuse = seekNodeByName(listView, "Button_Refuse", "ccui.Button") -- 拒绝
    listView.btnAgree = seekNodeByName(listView, "Button_Agree", "ccui.Button") -- 同意
    listView.imgStatus = seekNodeByName(listView, "Image_Status", "ccui.ImageView") -- 状态
end

function UIApplicationPage2:_onListViewSetData(listView, val)
    listView.imgLeagueIcon:loadTexture(game.service.club.ClubService:getInstance():getClubIcon(val.clubIcon))
    listView.textLeagueName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.clubName))
    listView.textLeagueId:setString(string.format("ID:%s", val.clubId))
    listView.textOwner:setString(val.managerName)
    listView.textLeaguerCount:setString(val.memberCount)

    listView.btnRefuse:setVisible(val.status == 1)
    listView.btnAgree:setVisible(val.status == 1)
    listView.imgStatus:setVisible(val.status ~= 1)

    listView.imgStatus:loadTexture(STATUS_TYPE[val.status])

    bindEventCallBack(listView.btnAgree, function ()
        self._bigLeagueService:sendCCLApprovalREQ(self._bigLeagueService:getLeagueData():getLeagueId(), val.clubId, true, val.clubName)
    end , ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnRefuse, function ()
        self._bigLeagueService:sendCCLApprovalREQ(self._bigLeagueService:getLeagueData():getLeagueId(), val.clubId, false, val.clubName)
    end , ccui.TouchEventType.ended)
end

function UIApplicationPage2:hide()
    self._reusedListApplication:deleteAllItems()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIApplicationPage2