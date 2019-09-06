
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local UIElemRoomItem = class("UIElemRoomItem")
local Constants = require("app.gameMode.mahjong.core.Constants")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ITEM_COUNT = 4
local DEFAULT_ICON = "club4/img_frame0.png"
local DEFAULT_ICON = "club/img_tableplayer1_club.png"
local FILE_TYPE = "playericon"
local _pendingHeadIconTasks = {}
local RoomColor = {
    {r = 255, g = 255, b = 255},     -- 未开局（白色）
    {r = 255, g = 242, b = 155},     -- 提前开局（蓝色）
    {r = 255, g = 242, b = 155},       -- 已满（红色）
}

function UIElemRoomItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemRoomItem)
    self:_initialize()
    return self
end

function UIElemRoomItem:_initialize()
    self._objItem = seekNodeByName(self, "Panel_Rooms", "ccui.Layout")

    self._rooms = {}
    for i = 1, ITEM_COUNT do
        self._rooms[i]= seekNodeByName(self, "Panel_Room_" .. i , "ccui.Layout")
        self._rooms[i]:setVisible(false)
    end
end

function UIElemRoomItem:setData(val)
     -- 创建房间的item默认不显示

    for i = 1, ITEM_COUNT do
        local roomInfo = val[i]
        self._rooms[i]:setVisible(true)
        if roomInfo == 1 or roomInfo == nil then
            self._rooms[i]:setVisible(false)
        elseif roomInfo.isSimple  then
            self:_updateSimpleData(self._rooms[i], roomInfo)            
        else
            self:_updataItemData(self._rooms[i],roomInfo)
        end
    end
end

-- 更新简单数据
function UIElemRoomItem:_updateSimpleData(room, data)
    for i = 1, 4 do
        local player = room:getChildByName("Panel_Player_"..i)
        local imageMask = player:getChildByName("Image_Mask")   -- 蒙灰
        local imageWait = player:getChildByName("Image_Status") -- 等待中
        local btnWatch = player:getChildByName("Button_Watch")  -- 观战
        local btnJoin = player:getChildByName("Button_Join")    -- 加入
        local imageHead = player:getChildByName("Image_Head")   -- 头像
        if i <= data.maxPlayer then            
            imageMask:setVisible(false)   
            imageWait:setVisible(false)  
            btnWatch:setVisible(false)   
            btnJoin:setVisible(false) 
            -- 注册加入事件
            bindEventCallBack(btnJoin, function()
                self:_onClickJoin(data)
            end, ccui.TouchEventType.ended)

            if i <= data.playerCount then       

                -- 开局玩家头像都会有一层蒙灰
                if data.hasStartBattle then
                    imageMask:setVisible(true)
                end
                -- 没满人时，显示默认头像
                -- imageHead:setTexture(DEFAULT_ICON)
                imageHead:loadTexture(DEFAULT_ICON)
                imageHead:setScale(1.0)
                -- 显示加入
            else
                btnJoin:setVisible(true)
                if game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() then
                    btnJoin:setTouchEnabled(false)
                end
            end
        else
             -- 超出最大人数，隐藏多余的玩家信息
            player:setVisible(false)
        end
    end

    local text = ""
    local textRule = room:getChildByName("Text_Rule")
    if data.hasStartBattle then
        text = "已开局"
        textRule:setColor(cc.c4b(RoomColor[3].r, RoomColor[3].g, RoomColor[3].b, 255))
    else
        text = "未开局"
        textRule:setColor(cc.c4b(RoomColor[1].r, RoomColor[1].g, RoomColor[1].b, 255))
    end
    -- 极速模式icon
    textRule:setString(text)
    
    -- 详情点击事件
    room:getChildByName("Button_Details"):setVisible(false)
    room:getChildByName("Image_Status"):setVisible(false)

    
end
-- 更新数据
function UIElemRoomItem:_updataItemData(room , data)
    for i = 1, 4 do
        local player = room:getChildByName("Panel_Player_"..i)
        local imageMask = player:getChildByName("Image_Mask")   -- 蒙灰
        local imageWait = player:getChildByName("Image_Status") -- 等待中
        local btnWatch = player:getChildByName("Button_Watch")  -- 观战
        local btnJoin = player:getChildByName("Button_Join")    -- 加入
        local imageHead = player:getChildByName("Image_Head")   -- 头像
        if i <= data.playerMax then      
            player:setVisible(true)      
            imageMask:setVisible(false)   
            imageWait:setVisible(false)  
            btnWatch:setVisible(false)   
            btnJoin:setVisible(false) 

            -- 注册观战事件
            bindEventCallBack(btnWatch, function()
                self:_onClickWatching(data.roomId)
            end, ccui.TouchEventType.ended)
            -- 注册加入事件
            bindEventCallBack(btnJoin, function()
                self:_onClickJoin(data)
            end, ccui.TouchEventType.ended)

            if i <= #data.players then
                -- 有的图片不是96*96的
                if string.find(data.players[i].head, "/0", -2) then
                    data.players[i].head = string.sub(data.players[i].head, 1, -3) .. "/96"
                end
                game.util.PlayerHeadIconUtil.setIcon(imageHead, data.players[i].head)


                -- 开局玩家头像都会有一层蒙灰
                if data.hasStartBattle then
                    imageMask:setVisible(true)
                    if bit.band(data.players[i].status, Constants.PlayerStatus.WAITING) ~= 0 then
                        -- 显示等待状态
                        imageWait:setVisible(true)
                    else
                        -- 显示观战(联盟盟主才能显示)
                         local isBoss = game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague()
                         player:getChildByName("Button_Watch"):setVisible(isBoss)
                    end
                end
            else
                -- 没满人时，显示默认头像
                -- imageHead:setTexture(DEFAULT_ICON)
                imageHead:loadTexture(DEFAULT_ICON)
                imageHead:setScale(1.0)
                -- 显示加入
                btnJoin:setVisible(true)
                if game.service.bigLeague.BigLeagueService:getInstance():getIsSuperLeague() then
                    btnJoin:setTouchEnabled(false)
                end
            end
        else
             -- 超出最大人数，隐藏多余的玩家信息
            player:setVisible(false)
        end
    end

    -- 玩法显示
    local roomSettingInfo = RoomSettingInfo.new(data.gameplay.gameplays, data.gameplay.roundType)
    local gameTypeZHName = data.gameplay.name
    local roundCount = roomSettingInfo:getRoundCountNumber() or 0


    local text = ""
    local textRule = room:getChildByName("Text_Rule")
    if data.hasStartBattle then
        if data.playerMax ~= #data.players then
            text = string.format("%s\n%s\n%d/%d局", "提前开局", gameTypeZHName, data.finishRoundCount, roundCount)
            textRule:setColor(cc.c4b(RoomColor[2].r, RoomColor[2].g, RoomColor[2].b, 255))
        else
            text = string.format("%s\n%s\n%d/%d局", "已开局", gameTypeZHName, data.finishRoundCount, roundCount)
            textRule:setColor(cc.c4b(RoomColor[3].r, RoomColor[3].g, RoomColor[3].b, 255))
        end
    else
        text = string.format("%s\n%s\n%d局", "未开局", gameTypeZHName, roundCount)
        textRule:setColor(cc.c4b(RoomColor[1].r, RoomColor[1].g, RoomColor[1].b, 255))
    end
    -- 极速模式icon
    textRule:setString(text)
    
    room:getChildByName("Image_Status"):setVisible(roomSettingInfo:isFastModeOpen())
    
    -- 详情点击事件
    room:getChildByName("Button_Details"):setVisible(true)
    bindEventCallBack(room:getChildByName("Button_Details"), function () self:_onClickRoomInfo(data) end, ccui.TouchEventType.ended)
end

-- 观战
function UIElemRoomItem:_onClickWatching(roomId)
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end

    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_headicon_Watch)
    game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.Watch, true);
end

-- 加入房间
function UIElemRoomItem:_onClickJoin(data)
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end

    local roundCount, gamePlays = game.service.club.ClubService.getInstance():getClubRoomService():getRoomRule()
    if #gamePlays == 0 or data.gameplay.gameplays[1] == gamePlays[1] then
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
        return
    end

    local str = string.format("检测到您上次完成的牌局玩法是%s，当前牌桌玩法是%s，是否继续进入房间？", RoomSettingInfo.new(gamePlays, roundCount):getZHArray()[1], RoomSettingInfo.new(data.gameplay.gameplays, data.gameplay.roundType):getZHArray()[1])
    UIManager:getInstance():show("UIClubRuleTips", str, 5, function ()
        game.service.RoomCreatorService.getInstance():queryBattleIdReq(data.roomId, game.globalConst.JOIN_ROOM_STYLE.ClickTable)
    end)
end

-- 创建房间
function UIElemRoomItem:_onClickCreateRoom(data)
    local club = game.service.club.ClubService.getInstance():getClub(data.clubId)
    if club.data ~= nil and bit.band(club.data.switches, ClubConstant:getClubSwitchType().FROZEN_ROOM) > 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips(config.STRING.UICLUBROOM_STRING_100)
        return
    end

    -- 获取预设玩法
    local presetGameplays = club and club.data and club.data.presetGameplays or {}
    -- 获取禁用玩法
    local banGameplays = club and club.data and club.data.banGameplays or {}
    
    UIManager:getInstance():show("UICreateRoom", data.clubId, ClubConstant:getGamePlayType().normal, banGameplays)
end

-- 显示房间信息
function UIElemRoomItem:_onClickRoomInfo(roomInfo)
    -- 统计点击详情按钮的事件数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Details);
    UIManager:getInstance():show("UIBigLeagueRoomInfo", roomInfo)
end


return UIElemRoomItem