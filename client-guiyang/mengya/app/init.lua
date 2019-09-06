local app = {}
local meta = {}
local conf = {}
cc.exports.app = app
meta.__index = function(tb,key)
    local path = conf[key]
    if string.find(path,".csb") then
        return conf[key]
    else
        return require(conf[key])
    end
end
setmetatable(app,meta)
--common
conf["Util"] = "mengya.app.util.Util"
conf["Logger"] = "mengya.app.manager.log.Logger"
--network
conf["NetWork"] = "mengya.app.manager.network.NetWork"

conf["ConfigManager"] = "mengya.app.manager.config.ConfigManager"
conf["UIAnimationManager"] = "mengya.app.manager.animation.UIAnimationManager"
conf["AudioManager"] = "mengya.app.manager.audio.AudioManager"



--gamestate
conf["GameFSM"] = "mengya.app.manager.fsm.GameFSM"
conf["GameStateBase"] = "mengya.app.manager.fsm.GameStateBase"
conf["GameState_Splash"] = "mengya.app.game.gameState.GameState_Splash"
conf["GameState_Update"] = "mengya.app.game.gameState.GameState_Update"
conf["GameState_InGame"] = "mengya.app.game.gameState.GameState_InGame"

conf["GameState_Login"] = "mengya.app.game.gameState.GameState_Login"
conf["GameState_Lobby"] = "mengya.app.game.gameState.GameState_Lobby"
conf["GameState_Club"] = "mengya.app.game.gameState.GameState_Club"


--================================================
--=================   UI 相关   ==================
--================================================
--通用UI
conf["UIManager"] = "mengya.app.manager.ui.UIManager"
conf["UIBase"] = "mengya.app.manager.ui.UIBase"
conf["UITableView"] = "mengya.app.manager.ui.UITableView"
conf["UITableViewEx"] = "mengya.app.manager.ui.UITableViewEx"
conf["UITableViewListEx"] = "mengya.app.manager.ui.UITableViewListEx"
conf["UITableViewCell"] = "mengya.app.manager.ui.UITableViewCell"
conf["UIFreeList"] = "mengya.app.manager.ui.UIFreeList"
conf["UIFreeListItem"] = "mengya.app.manager.ui.UIFreeListItem"
conf["UICheckBoxGroup"] = "mengya.app.manager.ui.UICheckBoxGroup"
conf["UITipManager"] = "mengya.app.manager.ui.UITipManager"



--闪屏界面
conf["UISplash"] = "mengya.app.ui.UISplash"
conf["UISplashCsb"] = "ui/csb/mengya/UISplash.csb"

--启动界面(更新界面)
conf["UILaunch"] = "mengya.app.ui.UILaunch"
conf["UILaunchCsb"] = "ui/csb/mengya/UILaunch.csb"

--登陆界面
conf["UILogin"]  = "mengya.app.ui.UILogin"
conf["UILoginCsb"]  = "ui/csb/mengya/UILogin.csb"

--更多登陆方式界面
conf["UILoginMore"] = "mengya.app.ui.UILoginMore"
conf["UILoginMoreCsb"] = "ui/csb/mengya/UILoginMore.csb"

--手机登录
conf["UIPhoneLogin"] = "mengya.app.ui.UIPhoneLogin"
conf["UIPhoneLoginCsb"] = "ui/csb/mengya/UIPhoneLogin.csb"

--主界面
conf["UIMain"] = "mengya.app.ui.UIMain"
conf["UIMainCsb"] = "ui/csb/mengya/UIMain.csb"
conf["UIMainRightListItem"] = "mengya.app.ui.UIMainRightListItem"



--商店界面
conf["UIShop"] = "mengya.app.ui.UIShop"
conf["UIShopCsb"] = "ui/csb/mengya/UIShop.csb"

conf["UIShopItem"] = "mengya.app.ui.UIShopItem"
conf["UIShopLeftItem"] = "mengya.app.ui.UIShopLeftItem"

--个人中心
conf["UIPersonalCenter"] = "mengya.app.ui.UIPersonalCenter"
conf["UIPersonalCenterCsb"] = "ui/csb/mengya/UIPersonalCenter.csb"
conf["UIPersonalCenterLeftItem"] = "mengya.app.ui.UIPersonalCenterLeftItem"

--头像商城
conf["UIHeadFrameShop"] = "mengya.app.ui.UIHeadFrameShop"
conf["UIHeadFrameShopCsb"] = "ui/csb/mengya/headFrameShop/UIHeadFrameShop.csb"
conf["UIHeadFrameShopItem"] = "mengya.app.ui.UIHeadFrameShopItem"


--创建房间
conf["UICreateRoom"] = "mengya.app.ui.UICreateRoom"
conf["UICreateRoomCsb"] = "ui/csb/mengya/UICreateRoom.csb"
conf["UICreateRoomLeftItem"] = "mengya.app.ui.UICreateRoomLeftItem"
conf["UIRoomSetting"] = "mengya.app.manager.ui.roomsetting.UIRoomSetting"
conf["UISettingCheckBox"] = "mengya.app.manager.ui.roomsetting.UISettingCheckBox"

--禁用房间规则
conf["UIReverseRoom"] = "mengya.app.ui.UIReverseRoom"
conf["UIReverseRoomCsb"] = "ui/csb/mengya/UIReverseRoom.csb"
conf["UIReverseRoomLeftItem"] = "mengya.app.ui.UIReverseRoomLeftItem"
conf["UIReverseSetting"] = "mengya.app.manager.ui.roomsetting.UIReverseSetting"

--创建/加入/进入俱乐部界面
conf["UIClubMain"] = "mengya.app.ui.club.UIClubMain"
conf["UIClubMainCsb"] = "ui/csb/mengya/club/UIClubMain.csb"
conf["UIClubMainLeftItem"] = "mengya.app.ui.club.UIClubMainLeftItem"
conf["UIClubMainMyClubItem"] = "mengya.app.ui.club.UIClubMainMyClubItem"

--俱乐部主界面
conf["UIClubRoom"] = "mengya.app.ui.club.UIClubRoom"
conf["UIClubRoomCsb"] = "ui/csb/mengya/club/UIClubRoom.csb"
conf["UIClubRoomItem"] = "mengya.app.ui.club.UIClubRoomItem"
conf["UIClubRoomPlaceItem"] = "mengya.app.ui.club.UIClubRoomPlaceItem"


--俱乐部成员界面
conf["UIClubMember"] = "mengya.app.ui.club.UIClubMember"
conf["UIClubMemberCsb"] = "ui/csb/mengya/club/UIClubMember.csb"
conf["UIClubMemberItem"] = "mengya.app.ui.club.UIClubMemberItem"

--俱乐部公告编辑界面
conf["UIClubEditNotice"] = "mengya.app.ui.club.UIClubEditNotice"
conf["UIClubEditNoticeCsb"] = "ui/csb/mengya/club/UIClubEditNotice.csb"

--俱乐部房间信息界面
conf["UIClubRoomInfo"] = "mengya.app.ui.club.UIClubRoomInfo"
conf["UIClubRoomInfoCsb"] = "ui/csb/mengya/club/UIClubRoomInfo.csb"

--俱乐部成员邀请
conf["UIClubMemberInvite"] = "mengya.app.ui.club.UIClubMemberInvite"
conf["UIClubMemberInviteCsb"] = "ui/csb/mengya/club/UIClubMemberInvite.csb"

--俱乐部历史战绩
conf["UIClubHistoryRecord"] = "mengya.app.ui.club.UIClubHistoryRecord"
conf["UIClubHistoryRecordCsb"] = "ui/csb/mengya/club/UIClubHistoryRecord.csb"
conf["UIClubHistoryRecordItem"] = "mengya.app.ui.club.UIClubHistoryRecordItem"

--俱乐部历史战绩筛选
conf["UIClubHistoryFilter"] = "mengya.app.ui.club.UIClubHistoryFilter"
conf["UIClubHistoryFilterCsb"] = "ui/csb/mengya/club/UIClubHistoryFilter.csb"


--俱乐部时间选择器
conf["UIClubDateSelect"] = "mengya.app.ui.club.UIClubDateSelect"
conf["UIClubDateSelectCsb"] = "ui/csb/mengya/club/UIClubDateSelect.csb"
conf["UIClubDateItem"] = "mengya.app.ui.club.UIClubDateItem"

--俱乐部消息界面
conf["UIClubMessage"] = "mengya.app.ui.club.email.UIClubMessage"
conf["UIClubMessageCsb"] = "ui/csb/mengya/club/email/UIClubMessage.csb"
conf["UIClubMessageLeftItem"] = "mengya.app.ui.club.email.UIClubMessageLeftItem"
conf["UIClubMessageOperation"] = "mengya.app.ui.club.email.UIClubMessageOperation"
conf["UIClubMessageOperationItem"] = "mengya.app.ui.club.email.UIClubMessageOperationItem"
conf["UIClubMessageApproving"] = "mengya.app.ui.club.email.UIClubMessageApproving"
conf["UIClubMessageApprovingItem"] = "mengya.app.ui.club.email.UIClubMessageApprovingItem"
conf["UIClubMessageNotice"] = "mengya.app.ui.club.email.UIClubMessageNotice"
conf["UIClubMessageEmail"] = "mengya.app.ui.club.email.UIClubMessageEmail"
conf["UIClubMessageEmailItem"] ="mengya.app.ui.club.email.UIClubMessageEmailItem"


--俱乐部管理界面
conf["UIClubManager"] = "mengya.app.ui.club.UIClubManager"
conf["UIClubManagerCsb"] = "ui/csb/mengya/club/UIClubManager.csb"
conf["UIClubManagerItem"] = "mengya.app.ui.club.UIClubManagerItem"

--切换俱乐部界面
conf["UIClubList"] = "mengya.app.ui.club.UIClubList"
conf["UIClubListCsb"] = "ui/csb/mengya/club/UIClubList.csb"
conf["UIClubListItem"] = "mengya.app.ui.club.UIClubListItem"

--俱乐部成员信息界面
conf["UIClubMemberInfo"] = "mengya.app.ui.club.UIClubMemberInfo"
conf["UIClubMemberInfoCsb"] = "ui/csb/mengya/club/UIClubMemberInfo.csb"

---俱乐部成员设置
conf["UIClubMemberSetting"] = "mengya.app.ui.club.UIClubMemberSetting"
conf["UIClubMemberSettingCsb"] = "ui/csb/mengya/club/UIClubMemberSetting.csb"
conf["UIClubMemberSettingItem"] = "mengya.app.ui.club.UIClubMemberSettingItem"

--俱乐部数据统计
conf["UIClubDataStatistics"] = "mengya.app.ui.club.UIClubDataStatistics"
conf["UIClubDataStatisticsCsb"] = "ui/csb/mengya/club/UIClubDataStatistics.csb"
conf["UIClubDataStatisticsItem"] = "mengya.app.ui.club.UIClubDataStatisticsItem"

--金币场
conf["UIGoldMain"] = "mengya.app.ui.gold.UIGoldMain"
conf["UIGoldMainCsb"] = "ui/csb/mengya/gold/UIGoldMain.csb"
