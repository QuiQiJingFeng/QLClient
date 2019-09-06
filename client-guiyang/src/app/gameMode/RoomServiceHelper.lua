local Constants = require("app.gameMode.mahjong.core.Constants")
local room = require("app.game.ui.RoomSettingHelper")
local cls = class("RoomServiceHelper")

function cls:ctor()
end

-- 当做静态类来看待吧，没有self的
function cls.getInstance()
    if cls._instance == nil then
        cls._instance = cls.new()
    end
    return cls._instance
end

function cls.exit2Lobby()
    game.service.RoomService.getInstance():quitRoom()
end

function cls.exit2Lobby_Acting()
    game.ui.UIMessageBoxMgr.getInstance():show("返回大厅将离开座位，但房间依旧保留，是否继续？", { "确定", "取消" }, function()
        game.service.RoomService.getInstance():quitRoom(false)
    end)
end

function cls.dismissRoom()
    -- android提审（应用宝）
    if device.platform == "android" and GameMain.getInstance():isReviewVersion() then
        game.ui.UIMessageBoxMgr.getInstance():show("是否确定解散该房间？", { "确定", "取消" }, function()
            game.service.RoomService.getInstance():quitRoom()
        end)
    else
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.ROOMSERVICEHELPER_STRING_100, { "确定", "取消" }, function()
            game.service.RoomService.getInstance():quitRoom()
        end)
    end
end

function cls.copyRoomId()
    local rules = cls:_getRoomRulesStr()
    -- 默认分享给好友
    local url = config.GlobalConfig.getShareUrl()
    local msg = "房号[" .. game.service.RoomService:getInstance():getRoomId() .. "], " .. rules .. "下载地址:" .. url .. "（复制此条消息打开游戏，可直接进入房间，安卓暂时无法使用此功能）"
    game.plugin.Runtime.setClipboard(msg)
    game.service.WeChatService:getInstance():openWXApp()
    game.service.TDGameAnalyticsService.getInstance():onEvent("CLICKED_COPY_ROOMID")
end

function cls.wechatInvite()
    --talkdata打点
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Room_Invite_Click)
    -- 将分享内容，整理到一张UI上面，再将此UI渲染到一个纹理
    local tip = config.GlobalConfig.getShareInfo()[1]
    if game.service.RoomService:getInstance():getRoomClubId() ~= 0 then
        local clubId = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
        local club = game.service.club.ClubService.getInstance():getClub(clubId)
        -- 玩家在亲友圈房间内被群主踢掉就会报错
        if club ~= nil then
            tip = club.info.clubName
        end
    end
    local title = "房号:[" .. game.service.RoomService:getInstance():getRoomId() .. "]"
    local roomRuleStr = cls:_getRoomRulesStr()
    local content = kod.util.String.getMaxLenString(roomRuleStr, 76) .. "..."

    local data =     {
        enter = share.constants.ENTER.ROOM_INFO,
        tip = tip,
        title = title,
        content = content
    }
    local msg = title .. ", " .. content .. "开搓! 现在就等你哦!"
    local url_data = {
        enter = share.constants.ENTER.ROOM_INFO,
        shareInfo = tip,
        shareContent = msg
    }
    share.ShareWTF.getInstance():share(share.constants.ENTER.ROOM_INFO, { data, data, data })

end

function cls:_getRoomRulesStr()
    -- showRoomRules
    local ret = ""
    local roomSettings = game.service.RoomService:getInstance():getRoomSettings()
    local res = room.RoomSettingHelper.manageRuleLabels(roomSettings)
    for i = 1, #res do
        ret = ret .. res[i] .. ","
    end

    return ret
end


function cls.startGame(sender)
    local roomId = game.service.RoomService:getInstance():getRoomId()
    game.service.RoomService:getInstance():sendCBStartBattleInAdvanceREQ(roomId)

    -- local status = Constants.PlayerStatus.START
    -- game.service.RoomService:getInstance():updateStatus(status)
end

-- function cls.isLocalPlayer()
-- end
return cls