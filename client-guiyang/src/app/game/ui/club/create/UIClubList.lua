local csbPath = "ui/csb/Club/UIClubList.csb"
local super = require("app.game.ui.UIBase")

--[[
    我的亲友圈列表
]]

-- 每个亲友圈的背景
local clubImg = {
    "art/club4/img_clubck5.png",
    "art/club4/img_clubck4.png",
    "art/club4/img_clubck3.png",
    "art/club4/img_clubck2.png",
    "art/club4/img_clubck1.png",
}

--  每个亲友圈Id的颜色
local clubIdColor = {
    {r = 155, g = 246, b = 249},
    {r = 255, g = 185, b = 62},
    {r = 198, g = 177, b = 255},
    {r = 255, g = 160, b = 131},
    {r = 148, g = 255, b = 196},
}

--  每个亲友圈名称的颜色
local clubNameColor = {
    {r = 9, g = 57, b = 108},
    {r = 152, g = 67, b = 26},
    {r = 85, g = 54, b = 126},
    {r = 152, g = 46, b = 26},
    {r = 18, g = 119, b = 75},
}

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemClubItem = class("UIElemClubItem")

function UIElemClubItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemClubItem)
    self:_initialize()
    return self
end

function UIElemClubItem:_initialize()
    local panelItem = seekNodeByName(self, "Panel_list_Clublist", "ccui.Layout")
    self._objItem = bindNodeToTarget(panelItem)

    self._itemClub = {}
    for i = 1, 2 do
        local club = seekNodeByName(self, "Panel_" .. i .. "_0_list_Clublist", "ccui.Layout")
        self._itemClub[i] = bindNodeToTarget(club)
    end
end

-- 整体设置数据
function UIElemClubItem:setData(val)
    if self._data == val then
        return
    end

    self._data = val

    for i, data in ipairs(val) do
            -- 更新数据
        self:_updataItemData(self._itemClub[i], i, data)

        -- show亲友圈牌桌界面
        bindEventCallBack(self._objItem["Panel_" .. i .."_0_list_Clublist"], function()
            local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
            localStorageClubInfo:setClubId(data.info.clubId)
            game.service.club.ClubService.getInstance():saveLocalStorageClubInfo(localStorageClubInfo)
            game.service.club.ClubService.getInstance():enterClub()
        end, ccui.TouchEventType.ended)
    end

    -- 当只有一个item时
    if #val == 1 then
        self._objItem["Panel_2_0_list_Clublist"]:setVisible(false)
    end
end

-- 亲友圈数据
function UIElemClubItem:_updataItemData(itemClub, idx, clubInfo)
    local imgClubIcon   = itemClub.Image_head_list_Clublist     -- 亲友圈图标
    local clubName      = itemClub.Text_name_list_Clublist      -- 亲友圈名字
    local clubId        = itemClub.Text_ID_list_Clublist        -- 亲友圈id
    local imgRedDot     = itemClub.Image_red_1_0_list_Clublist  -- 红点
    local itemClubImg   = self._objItem["Panel_" .. idx .."_0_list_Clublist"] -- 亲友圈panel显示

    local name = game.service.club.ClubService.getInstance():getInterceptString(clubInfo.info.clubName)
    clubName:setString(name)

    -- 超过五个时候，item背景从第一个开始
    local index = clubInfo.clubIdx % 5 == 0 and 5 or clubInfo.clubIdx % 5
    --clubName:setColor(cc.c4b(clubNameColor[index].r, clubNameColor[index].g, clubNameColor[index].b, 255))

    local id = string.format("(ID:%s)", tostring(clubInfo.info.clubId))
    clubId:setString(id)
    --clubId:setColor(cc.c4b(clubIdColor[index].r, clubIdColor[index].g, clubIdColor[index].b, 255))

    -- 去掉背景的修改，新版样式不需要了
    --itemClubImg:setBackGroundImage(clubImg[index])
    imgClubIcon:loadTexture(game.service.club.ClubService.getInstance():getClubIcon(clubInfo.info.clubIcon))

    imgRedDot:setVisible(clubInfo:hasApplicationBadges() or clubInfo:hasTaskBadges())
end

local UIClubList = class("UIClubList", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubList:ctor(parent)
    self._parent = parent
    self:setPosition(0, 0)
    self._reusedListClub = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_Clublist", "ccui.ListView"), UIElemClubItem)
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListClub:setScrollBarEnabled(false)
end

function UIClubList:show()
    self:setVisible(true)
    self:_onUpdataClubList()
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_ADDED", handler(self, self._onUpdataClubList), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_DELETED", handler(self, self._onUpdataClubList), self)
end

function UIClubList:_onUpdataClubList()
    local clubList = game.service.club.ClubService.getInstance():getClubList()

    -- 清空列表
    self._reusedListClub:deleteAllItems()

    local clubs = {}

    if #clubList.clubs > 0 then
        for clubIdx, club in ipairs(clubList.clubs) do
            club.clubIdx = clubIdx
            table.insert(clubs, club)
            if #clubs == 2 then
                self._reusedListClub:pushBackItem(clubs)
                clubs = {}
            end
        end
    end

    if #clubs ~= 0 then
         self._reusedListClub:pushBackItem(clubs)
         clubs = {}
    end
end

function UIClubList:hide()
    -- 清空列表
    self._reusedListClub:deleteAllItems()
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIClubList