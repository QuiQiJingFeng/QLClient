local csbPath = "ui/csb/BigLeague/UIBigLeagueMember_Partner.csb"
---@class UIBigLeagueMember_Partner:UIBase
local UIBigLeagueMember_Partner = class("UIBigLeagueMember_Partner", function() return cc.CSLoader:createNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

function UIBigLeagueMember_Partner:ctor(parent)
    self._parent = parent

    self._reusedListPartner = ListFactory.get(
            seekNodeByName(self, "ListView_Partner", "ccui.ListView"),
            handler(self, self._onListViewInit),
            handler(self, self._onListViewSetData)
    )
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListPartner:setScrollBarEnabled(false)
end

function UIBigLeagueMember_Partner:_onListViewInit(listView)
    listView.textName = seekNodeByName(listView, "Text_Name", "ccui.Text") -- 昵称
    listView.textId = seekNodeByName(listView, "Text_Id", "ccui.Text") -- Id
    listView.textPeoples = seekNodeByName(listView, "Text_Peoples", "ccui.Text") -- 人数
    listView.textScore = seekNodeByName(listView, "Text_Score", "ccui.Text") -- 分数
    listView.btnOperating = seekNodeByName(listView, "Button_Operating", "ccui.Button") -- 操作
    listView.btnMember = seekNodeByName(listView, "Button_Member", "ccui.Button") -- 成员
    listView.btnAddPoints = seekNodeByName(listView, "Button_AddPoints", "ccui.Button") -- 加分
    listView.btnMinusPoints = seekNodeByName(listView, "Button_MinusPoints", "ccui.Button") -- 减分
end

function UIBigLeagueMember_Partner:_onListViewSetData(listView, val)
    listView.textName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.nickname))
    listView.textId:setString(val.roleId)
    listView.textScore:setString(math.round(val.gameScore * 100) / 100)
    listView.textPeoples:setString(val.memberCount)

    bindEventCallBack(listView.btnMember, function ()
        UIManager:getInstance():show("UIBigLeagueMember", val.roleId, self._bigLeagueService:getLeagueData():getMemberType().MEMBER_PARTNER)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnOperating, function()
        -- 根据item的位置改变setting界面显示位置
        local x, y = listView.btnOperating:getPosition()
        local pos = listView.btnOperating:getParent():convertToWorldSpace(cc.p(x, y))
        UIManager:getInstance():show("UIBigLeagueMemberSetting", pos, val, "UIBigLeagueMember_Partner")
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listView.btnAddPoints, function ()
        self:_setAdjustmentScore(val, "+")
    end, ccui.TouchEventType.ended)
    bindEventCallBack(listView.btnMinusPoints, function ()
        self:_setAdjustmentScore(val, "-")
    end, ccui.TouchEventType.ended)
end

function UIBigLeagueMember_Partner:_setAdjustmentScore(data, symbol)
    local str = string.format("参赛分可用%s", math.round(self._bigLeagueService:getLeagueData():getCurrentScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "调整分数", "请输入调整分数", str, true, symbol, function (score)
        self._bigLeagueService:sendCCLModifyPartnerScoreREQ(
                self._bigLeagueService:getLeagueData():getLeagueId(),
                self._bigLeagueService:getLeagueData():getClubId(),
                data.roleId,
                self._bigLeagueService:getLeagueData():getMemberType().PARTNER - 1,-- 类型（1:经理给搭档调整，2：搭档给搭档成员调整）
                score
        )
    end)
end

function UIBigLeagueMember_Partner:updataMemberInfo(roleId)
    if roleId == 0 then
        local isSort = self._parent:getisSort()
        local memberInfo = self._bigLeagueService:getLeagueData():getMemberInfo()
        if isSort then
            table.sort(memberInfo, function (a, b)
                if a.roomCount == b.roomCount then
                    if a.status == b.status then
                        if  ClubConstant:getClubTitleSort(a.title) == ClubConstant:getClubTitleSort(b.title) then
                            return a.joinClubTime < b.joinClubTime
                        end
                        return ClubConstant:getClubTitleSort(a.title) > ClubConstant:getClubTitleSort(b.title)
                    end
                    return a.status < b.status
                end
                return a.roomCount > b.roomCount
            end)
        end

        self:upadtaListViewInfo(memberInfo)
    else
        -- 玩家列表数据更新
        local itemIdx = self:_indexOfApplicationItem(roleId)
        if itemIdx ~= false then
            local member = self._bigLeagueService:getLeagueData():getMemberById(roleId)
            if member == nil then
                self._reusedListPartner:deleteItem(itemIdx)
            else
                self._reusedListPartner:updateItem(itemIdx, member)
            end
        end
    end
end

function UIBigLeagueMember_Partner:_indexOfApplicationItem(roleId)
    for idx,item in ipairs(self._reusedListPartner:getItemDatas()) do
        if item.roleId == roleId then
            return idx
        end
    end

    return false;
end

function UIBigLeagueMember_Partner:upadtaListViewInfo(memberInfo)
    self._reusedListPartner:deleteAllItems()
    for _, member in ipairs(memberInfo) do
        self._reusedListPartner:pushBackItem(member)
    end
end

function UIBigLeagueMember_Partner:show()
    self:setVisible(true)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
end

function UIBigLeagueMember_Partner:hide()
    self:setVisible(false)
end

return UIBigLeagueMember_Partner