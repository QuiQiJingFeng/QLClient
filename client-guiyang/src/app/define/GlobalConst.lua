-------------------
-- 全局常量，枚举
-------------------
local ns = namespace("game.globalConst")

--  数据统计,CK点击统计；REQ协议请求统计；DR时长统计
local  StatisticNames = 
{
    Req_Club_History        = "Req_Club_History",           -- 请求亲友圈战绩
    CK_Club_Dis_Room        = "CK_Club_Dis_Room",           -- 亲友圈强制解散房间
    CK_Play_Dis_Room        = "CK_Play_Dis_Room",           -- 亲友圈强制解散房间（游戏内）
    CK_History_Playback     = "CK_History_Playback",        -- 回放统计常量
    CK_History_Detail       = "CK_History_Detail",          -- 战绩第二界面统计常量
    CK_History_Share        = "CK_History_Share",           -- 战绩分享统计常量
    CK_Setting_Update       = "CK_Setting_Update",          -- 新版本提示统计常量
    CK_Club_ActingCreate    = "CK_Club_ActingCreate",       -- 亲友圈代开房间统计

    RoomID_Join_fail        = "RoomID_Join_fail",           -- 通过输入房间号进入房间失败的事件数
    RoomID_Share            = "RoomID_Share",               -- 房间内分享房间号到微信的事件数
    Join_false              = "Join_false",                 -- 统计每日加入房间失败的事件数
    ClubMembers             = "ClubMembers",                -- 统计每日点击成员按钮的事件数
    ClubRecord              = "ClubRecord",                 -- 统计每日点击战绩按钮的事件数
    ClubDialogue            = "ClubDialogue",               -- 统计每日点击对话按钮的事件数
    ClubAdministration      = "ClubAdministration",         -- 统计每日点击管理按钮的事件数
    ChangeClub              = "ChangeClub",                 -- 统计每日点击切换亲友圈按钮的事件数
    Club_My_Apply           = "Club_My_Apply",              -- 统计每日点击我的申请按钮的事件数
    Club_Establish          = "Club_Establish",             -- 统计每日点击创建按钮的事件数
    Club_Time               = "Club_Time",                  -- 统计每日点击时间条的事件数
    Club_Time_Query         = "Club_Time_Query",            -- 统计每日点击时间滚轮内查询按钮的事件数
    Club_Data_Modify        = "Club_Data_Modify",           -- 统计每日点击资料板内修改按钮的事件数
    Club_Regulations        = "Club_Regulations",           -- 统计每日点击玩法按钮的事件数
    Club_Details            = "Club_Details",               -- 统计每日点击详情按钮的事件数
    Club_EditNotice         = "Club_EditNotice",            -- 统计每日亲友圈公告编辑按钮的事件数
    SETUP_CLICK             = "SETUP_CLICK",                -- 统计每日点击设置按钮的事件数
    SETUP_TAB_CLICK         = "SETUP_TAB_CLICK",            -- 统计【亲友圈设置】页签点击次数
    Club_Leaderboard        = "Club_Leaderboard",           -- 统计点击俱乐部排行榜钮的事件数

    Club_Member_soushurukuang = "Club_Member_soushurukuang", -- 统计亲友圈成员列表【搜索输入框】点击
    Club_Member_sousuo      = "Club_Member_sousuo",         -- 统计亲友圈成员列表【搜索】按钮点击
    Club_Zhanji_Change      = "Club_Zhanji_Change",         -- 统计战绩页面【更改】按钮点击
    Club_Zhanji_Change_shurukuang = "Club_Zhanji_Change_shurukuang", -- 统计战绩页面更改条件弹窗分数输入框点击
    Club_Zhanji_Change_riqi = "Club_Zhanji_Change_riqi",    -- 统计战绩页面更改条件弹窗更改日期按钮点击
    Club_Zhanji_soushurukuang = "Club_Zhanji_soushurukuang", -- 统计战绩页面搜索输入框点击
    Club_Zhanji_sousuo      = "Club_Zhanji_sousuo",         -- 统计战绩页面搜索【确定】按钮点击
    Club_Member_Invite      = "Club_Member_Invite",         -- 统计亲友圈成员列表邀请的加号点击
    Club_Member_Invite_shurukuang = "Club_Member_Invite_shurukuang", -- 统计亲友圈成员列表邀请输入框点击
    Club_Member_Invite_button = "Club_Member_Invite_button", -- 统计亲友圈成员列表邀请按钮点击
    Club_Member_Invite_Wechat = "Club_Member_Invite_Wechat", -- 统计亲友圈成员列表微信邀请点击
    Club_Member_Invite_Pengyouquan = "Club_Member_Invite_Pengyouquan", -- 统计亲友圈成员列表朋友圈邀请点击

    -- 亲友圈活动统计
    Club_Activity           = "Club_Activity",              -- 统计活动按钮的点击次数
    Club_Red_Open           = "Club_Red_Open",              -- 统计红包的点击次数已领取
    Club_Red                = "Club_Red",                   -- 统计红包的点击次数未领取
    Club_Red_Mark           = "Club_Red_Mark",              -- 统计红包页签的点击次数
    Club_Lottery_Mark       = "Club_Lottery_Mark",          -- 统计抽奖页签的点击次数
    Room_Activity           = "Room_Activity",              -- 统计牌桌内活动按钮点击次数
    Club_Receive            = "Club_Receive",               -- 统计领取按钮的点击次数
    Club_Receive_Award      = "Club_Receive_Award",         -- 统计领取奖励按钮点击次数
    Club_Red_Share          = "Club_Red_Share",             -- 统计红包分享次数
    Club_Lottery            = "Club_Lottery",               -- 统计抽奖按钮的点击次数
    Club_Stencil_Play       = "Club_Stencil_Play",          -- 亲友圈模版玩法
    Club_Stencil_Add        = "Club_Stencil_Add",           -- 亲友圈添加模版玩法
    Club_Stencil_Delete     = "Club_Stencil_Delete",        -- 亲友圈删除模版玩法
    Club_Buy                = "Club_Buy",                   -- 亲友圈房卡【购买】按钮的点击
    Club_Buy_Bedaili        = "Club_Buy_Bedaili",           -- 亲友圈【成为代理】按钮的点击
    Club_Buy_Dailihoutai    = "Club_Buy_Dailihoutai",       -- 亲友圈【代理后台】按钮的点击
    Club_Activity_System    = "Club_Activity_System",       -- 亲友圈活动系统按钮点击
    the_button_of_creat_room_quickly = "the_button_of_creat_room_quickly", -- 玩家看到的一键开房
    the_button_of_Template = "the_button_of_Template", -- 经理创建房间模板
    Club_Room_Online_Invite = "Club_Room_Online_Invite", -- 俱乐部房间在线邀请
    Club_RoomInfo_Online_Invite = "Club_RoomInfo_Online_Invite", -- 俱乐部房间信息在线邀请
    Club_Online_Invite = "Club_Online_Invite", -- 在线邀请
    Club_Online_Receive = "Club_Online_Receive", -- 在线邀请接受
    Club_Online_Ignore = "Club_Online_Ignore", --在线邀请忽略
    Club_Online_Close = "Club_Online_Close", -- 在线邀请关闭
    Button_Early_Start = "Button_Early_Start", --提前开局

    -- 俱乐部小组
    Club_Create_Group_Btn = "Club_Create_Group_Btn_new", -- 创建
    Club_Group_Out = "Club_Group_Out_new", -- 踢出
    Club_Group_Import = "Club_Group_Import_new", -- 亲友圈导入
    Club_Group_Invite = "Club_Group_Invite_new", -- 邀请成员
    Click_ClubGroup = "Click_ClubGroup_new", -- 俱乐部小组按钮

    click_club_recommend_copy = "click_club_recommend_copy", -- 统计亲友圈复制按钮的点击次数
    club_submit_applications = "club_submit_applications",  -- 统计亲友圈提交按钮的点击次数
    click_club_recommend_check_invitation = "click_club_recommend_check_invitation", -- 统计亲友圈查看邀请的点击次数
    club_stop_recieving_invitation = "club_stop_recieving_invitation", -- 统计亲友圈停止接受邀请的点击次数
    club_change_into_full_member = "club_change_into_full_member", -- 统计亲友圈变为正式成员的点击次数
    club_change_into_associated_member = "club_change_into_associated_member", -- 统计亲友圈变为准成员的点击次数
    click_club_recommend_check = "click_club_recommend_check", -- 用户点击已接受邀请，查看“邀请信息”
    click_club_recommend_receive = "click_club_recommend_receive", -- 用户点击邀请列表界面内的“接受”
    click_club_recommend_manager_invite = "click_club_recommend_manager_invite", -- 群主点击“邀请”
    click_club_recommend_manager_introduction = "click_club_recommend_manager_introduction", -- 新玩家推荐界面说明按钮

    Campaign_Entrance       = "Campaign_Entrance",          -- 统计每日点击比赛场按钮的事件数
    Campaign_HistoryRecord  = "Campaign_HistoryRecord",     -- 统计每日点击比赛场获奖记录的事件数
    Campaign_Flaunt         = "Campaign_Flaunt",            -- 统计每日点击比赛场获奖记录内炫耀一下的事件数
    Campaign_ShareReward    = "Campaign_ShareReward",       -- 统计每日点击比赛场获奖记录内分享领取的事件数
    Campaign_DiplomaShare    = "Campaign_DiplomaShare",     -- 统计每日点击比赛场奖状内分享按钮事件数
    Campaign_DiplomaReward    = "Campaign_DiplomaReward",   -- 统计每日点击比赛场奖状内分享领取按钮事件数
    Campaign_Detail         = "Campaign_Detail",            -- 统计每日点击比赛场比赛详情的事件数
    Campaign_GetMoney       = "Campaign_GetMoney",            -- 统计每日点击比赛场领取红包的事件数
    Campaign_GetMoney_Copy  = "Campaign_GetMoney_Copy",     -- 统计每日点击比赛场领取红包界面复制按钮事件数
    Campaign_HonorWall      = "Campaign_HonorWall",         -- 统计每日点击比赛场荣誉墙按钮事件数
    Campaign_HonorWallDetail = "Campaign_HonorWall_Detail",         -- 统计每日点击比赛场荣誉墙内详情按钮事件数
    Campaign_Detail_Desktop_Dali = "Campaign_Detail_Desktop_Dali",    -- 统计点击比赛场MTT牌桌内点击比赛详情的数量
    Campaign_Detail_Desktop_Rank = "Campaign_Detail_Desktop_Rank",    -- 统计点击比赛场积分牌桌内点击打立比赛详情的数量
    Campaign_Join_Campaign_Tip = "Campaign_Join_Campaign_Tip",    -- 统计点击比赛场报名了，比赛开始后弹出提示用户加入比赛弹窗加入的数量
    Campaign_Join_Campaign_Tip_Cancle = "Campaign_Join_Campaign_Tip_Cancle",    -- 统计点击比赛场报名了，比赛开始后弹出提示用户加入比赛弹窗放弃的数量
    Campaign_Giveup_Arena       = "Campaign_Giveup_Arena",          -- 统计每日点击比赛场按钮的事件数
    Campaign_JoinFrom_Detail       = "Campaign_JoinFrom_Detail",          -- 统计每日从详情加入房间个数
    Campaign_AddCard_Hall       = "Campaign_AddCard_Hall",          -- 统计每日比赛场点击加房卡个数
    Campaign_AddTicket_Hall       = "Campaign_AddTicket_Hall",          -- 统计每日比赛场点击加赛券个数
    Campaign_Ticket_BackPack      = "Campaign_Ticket_BackPack",         -- 统计每日比赛场门票背包点击个数

    club_submit_applications = "club_submit_applications",  -- 统计好友圈提交按钮的点击次数
    club_check_the_invitation = "club_check_the_invitation", -- 统计好友圈查看邀请的点击次数
    club_stop_recieving_invitation = "club_stop_recieving_invitation", -- 统计好友圈停止接受邀请的点击次数
    club_change_into_full_member = "club_change_into_full_member", -- 统计好友圈变为正式会员的点击次数
    club_change_into_associated_member = "club_change_into_associated_member", -- 统计好友圈变为见习会员的点击次数


    Club_Head_Click         = "club_image_click",           -- 统计俱乐部头像被点击次数
    Club_Edit_Click         = "club_edit_click",            -- 统计编辑资料点击次数
    Club_Manager_Click      = "club_manage_click",          -- 统计管理后台点击次数
    Club_Data_Click         = "club_data_click",            -- 统计数据统计点击次数
    Club_PlayingLaw_Click   = "club_playinglaw_click",      -- 统计玩法设定点击次数
    Club_RapidRoomLaw_Click = "club_yijiankaifang_click",   -- 统计一件开发设定次数
    Club_Alltable_On_Click  = "alltable_on",                -- 统计显示已开局牌桌次数
    Club_Alltable_Off_Click = "alltable_off",               -- 统计关闭显示已开局牌桌次数
    Club_Frozen_On_Click    = "club_frozen_on",             -- 冻结亲友圈开
    Club_Frozen_Off_Click   = "club_frozen_off",            -- 冻结亲友圈关
    Club_Dissolved_Click    = "club_dissolved_click",       -- 解散亲友圈按钮点击
    Club_Leave_Room_Click   = "club_leave_room_click",      -- 离开俱乐部房间按钮点击
    Club_Room_Info_Invite_Click = "club_room_info_invite_click", --俱乐部信息界面按邀请钮点击

    Club_Leaderboard_Find_UI = "Club_Leaderboard_Find_UI", -- 统计俱乐部排行榜分数筛选界面显示
    Club_Leaderboard_Find = "Club_Leaderboard_Find",        -- 统计俱乐部排行榜分数筛选界面查询点击次数
    Club_Leaderboard_Previous = "Club_Leaderboard_Previous", -- 统计俱乐部排行榜分数筛选界面上一步点击次数
    Club_Leaderboard_Score = "Club_Leaderboard_Score",      -- 统计俱乐部排行榜分数筛选界面分数输入次数


    -- 主界面
    icon_share                      = "icon_share",                     -- 分享按钮
    Hshare                          = "Hshare",                         -- 活动分享
    icon_military_exploits          = "icon_military_exploits",         -- 战绩按钮
    icon_the_way_of_play_game       = "icon_the_way_of_play_game",      -- 玩法按钮
    icon_setting                    = "icon_setting",                   -- 设置按钮
    icon_the_gift_coupon            = "icon_the_gift_coupon",           -- 礼券商城
    icon_be_a_agent                 = "icon_be_a_agent",                -- 成为代理
    icon_the_mall                   = "icon_the_mall",                  -- 商城购买
    icon_not_certification          = "icon_not_certification",         -- 实名认证(未认证)
    icon_certification              = "icon_certification",             -- 实名认证
    icon_feedback                   = "icon_feedback",                  -- 反馈
    mail_click                      = "mail_click",                     -- 邮件
    announcement_click              = "announcement_click",             -- 公告
    active_notification_click       = "active_notification_click",      -- 活动
    ResultPhoto_Save                = "ResultPhoto_Save",               -- 用户保存战绩到相册
    zhaomu_click                    = "zhaomu_click",                   -- 点击招募图标的次数
    zhaomu_copy_click               = "zhaomu_copy_click",              -- 点击复制微信
    zhaomu_zhuanqian_click          = "zhaomu_zhuanqian_click",         -- 立刻赚钱按钮
    icon_huo_dong_mian_ban          = "huo_dong_mian_ban",              -- 活动面板

    -- 设置打点
    discard_stay_on                 = "discard_stay_on",                -- 出牌放大开
    discard_stay_off                = "discard_stay_off",               -- 出牌放大关
    click_discard_on                = "click_discard_on",               -- 单击出牌开
    click_discard_off               = "click_discard_off",              -- 单击出牌关
    desktop_classical               = "desktop_classical",              -- 桌布 经典
    desktop_eyeProtectionGreen      = "desktop_eyeProtectionGreen",     -- 桌布 护眼绿
    desktop_bluenavy                = "desktop_bluenavy",               -- 桌布 藏青蓝
    setting_cardblue                = "setting_cardblue_new",               -- 牌面 蓝
    setting_cardgreen               = "setting_cardgreen_new",              -- 牌面 绿
    setting_cardbrown               = "setting_cardbrown_new",              -- 牌面 棕色
    setting_is3D_on                 = "setting_is3D_on",                -- 3D 开
    setting_is3D_off                = "setting_is3D_off",               -- 3D 关
    setting_classic_on              = "setting_classic_on_new",           -- 经典模式 开
    setting_classic_off             = "setting_classic_off_new",          -- 经典模式 关

    -- 分享统计
    Resultshare_to_Wfriend          = "Resultshare_to_Wfriend",         -- 结算分享好友
    Resultshare_to_Group            = "Resultshare_to_Group",           -- 结算分享朋友圈
    Resultshare_to_System           = "Resultshare_to_System",          -- 结算系统分享
    
    icon_main_share_friends         = "main_share_friends",             -- 主界面分享分享给好友按钮
    icon_main_share_circle          = "main_share_circle",              -- 主界面分享分享到朋友圈按钮
    icon_main_share_safe            = "main_share_safe",                -- 主界面分享安全分享按钮

    icon_game_share_friends         = "game_share_friends",             -- 游戏中分享分享给好友按钮
    icon_game_share_circle          = "game_share_circle ",             -- 游戏中分享分享到朋友圈按钮
    icon_game_share_safe            = "game_share_safe",                -- 游戏中分享安全分享按钮

    icon_history_share_friends      = "history_share_friends",          -- 战绩中分享安全分享按钮
    icon_history_share_circle       = "history_share_circle",           -- 战绩中分享安全分享按钮
    icon_history_share_safe         = "history_share_safe",             -- 战绩中分享安全分享按钮

    icon_main_share_safe_new        = "main_share_safe_new",            -- 主界面分享安全分享按钮
    icon_game_share_safe_new        = "game_share_safe_new",            -- 游戏中分享安全分享按钮
    icon_history_share_safe_new     = "history_share_safe_new",         -- 战绩中分享安全分享按钮

    icon_main_share_activity        = "main_share_activity",            -- 主界面中分享活动按钮
    icon_share_page_share           = "share_page_share",               -- 分享活动界面分享按钮

    Version_2_TD                    =   "Version_2_TD_",                -- 给td传版本号，用于提审测试td

    ReadyHand_Number                = "ReadyHand_Number",                        -- 上听次数
    HearingTips                     = "HearingTips",                    -- 听牌提示
    OnClick_TingTipsBtn_new         = "OnClick_TingTipsBtn_new",            -- 点听牌提示的按钮
    Ting_Tips_More                  = "Ting_Tips_More",                 -- 点听牌最多的哪张
    Ting_Tips_Less                  = "Ting_Tips_Less",

    LoginFix_Click                  = "LoginFix_Click",                 -- 登录页修复游戏
    SetupFix_Click                  = "SetupFix_Click",                 -- 设置页修复游戏
    DownloadError_Click             = "DownloadError_Click",            -- 游戏下载出错
    the_button_of_update_now        = "the_button_of_update_now",       -- 立即更新 
    the_button_of_update_later      = "the_button_of_update_later",     -- 稍后更新

    RoundReport_Details             = "RoundReport_Details", --算分详情
    RoomCard_Details                = "RoomCard_Details", --牌局详情
    RoundReport_RoomCard            = "RoundReport_RoomCard", -- 算分详情界面查看牌桌点击次数
    RoomCard_RoomCard               = "RoomCard_RoomCard", -- 牌局详情界面查看牌桌点击次数
    RoundReport_Continue            = "RoundReport_Continue", -- 牌局详情界面继续点击次数
    RoomCard_Continue               = "RoomCard_Continue", -- 算分详情界面继续点击次数
    Last_Cards                      = "Last_Cards", -- 剩余牌按钮点击次数

    Gamble_CLICK                    = "Gamble_CLICK",       --竞彩按钮点击次数
    Week_Sign_CLICK                 = "Week_Sign_CLICK",       --七日签到点击次数

    NewShare_Friend                 = "NewShare_Friend",       --新分享到朋友点击
    NewShare_Circle                 = "NewShare_Circle",       --新分享到好友圈点击
    NewShare_Award                  = "NewShare_Award_",       --新分享奖励领取
    NewShare_Help                   = "NewShare_Help",       --新分享帮助点击


    TurnCard_CLICK                  = "TurnCard_CLICK",     --翻牌点击
    TurnCard_Rull_CLICK             = "TurnCard_rull_CLICK",    --翻牌规则点击
    TurnCard_My_Award_CLICK         = "TurnCard_my_award_CLICK",    --翻牌活动奖品品点击
    TurnCard_Chance_CLICK           = "TurnCard_chance_CLICK",    --翻牌规则点击
    TurnCard_Turn_CLICK             = "TurnCard_turn_CLICK",    --翻牌活动翻牌
    TurnCard_Mission_CLICK          = "TurnCard_mission_CLICK", --任务跳转点击
    try_leave_gold_battle           = "try_leave_gold_battle",    -- 尝试离开金币场
    leave_gold_battle               = "leave_gold_battle",        --确定离开金币场

    LuckyDraw_CLICK                 = "LuckyDraw_CLICK",    --幸运抽奖点击
    LuckyDraw_ToBeanShop            = "LuckyDraw_toBeanShop",   --去金豆商店
    LuckyDraw_ToCardShop            = "LuckyDraw_toCardShop",   --去房卡商店

    PhoneActivity_CLICK             = "PhoneActivity_CLICK",    --绑定手机号领奖

    Daily_Share_Get_Gold            = "Daily_Share_Get_Gold", -- 分享得金币

    Gold_Click_Share_Large_Hu_Normal = "Gold_Click_Share_Large_Hu_Normal", -- 大胡分享普通按钮
    Gold_Click_Share_Large_Hu_Reward = "Gold_Click_Share_Large_Hu_Reward",-- 大胡分享有礼按钮
    Gold_Click_Share_Large_Hu_Back   = "Gold_Click_Share_Large_Hu_Back", -- 大胡分享返回
    Gold_Click_Share_Large_Hu_Continue = "Gold_Click_Share_Large_Hu_Continue",-- 大胡分享继续
    Room_Invite_Click               = "room_invite_click",          -- 房间邀请按钮点击
    Application_Dissolution         = "Application_dissolution",    -- 申请解散房间
    Determining_Dissolution         = "Determining_Dissolution",    -- 确定解散
    Dissolution_Reason              = "Dissolution_Reason",         -- 解散原因详情
    CK_CopyAgentWeiXin              = "CK_CopyAgentWeiXin",         -- 复制代理微信号

    MonthSign_Cllick                = "MonthSign_Click",        --月签到点击

    Change_Frame_Click              = "Change_Frame_Click", -- 头像商城
    Bind_DingTalk                   = "Bind_DingTalk", -- 绑定钉钉
    Bind_Phone                      = "Bind_Phone", --绑定手机
    Account_Recovery                = "Account_Recovery", -- 帐号找回
    Login_Method                    = "Login_Method", -- 更多登录方式
    Login_DingTalk                  = "Login_DingTalk", -- 钉钉登录
    Login_Phone                     = "Login_Phone", -- 手机登录
    Login_Wechat                    = "Login_Wechat", -- 微信登录

    Click_Firend                    = "Click_Firend", --大厅好友icon
    Click_Firend_Agree              = "Click_Firend_Agree", -- 好友申请同意按钮
    Click_Firend_Refuse             = "Click_Firend_Refuse", -- 好友申请忽略按钮
    Click_Firend_Search             = "Click_Firend_Search", -- 添加好友搜索按钮
    Click_Firend_Invite             = "Click_Firend_Invite", -- 好友立即组局按钮
    Click_Firend_Delete             = "Click_Firend_Delete", -- 好友删除按钮
    Click_Room_Friend               = "Click_Room_Friend", -- 房间内好友邀请
    Click_Room_Refuse               = "Click_Room_Refuse", -- 弹窗忽略按钮
    Click_Room_Receive              = "Click_Room_Receive", -- 弹窗接受按钮
    Click_Club_AddFriend            = "Click_Club_AddFriend", -- 俱乐部添加好友按钮
    Click_Room_AddFriend            = "Click_Room_AddFriend", -- 房间内添加好友按钮
    Click_Recommend_AddFriend       = "Click_Recommend_AddFriend", -- 好友推荐添加好友按钮
    Click_Club_MemberInfo_Record    = "Click_Club_MemberInfo_Record", -- 俱乐部玩家信息界面战绩按钮

    Button_Legend                   = "Button_Legend",  --点击传奇
    Button_Legend_HALL              = "Button_Legend_HALL",  --点击传奇_大厅按钮
    Button_Legend_Notice            = "Button_Legend_Notice",  --点击传奇_滚动通知
    Button_Legend_ActivityPage      = "Button_Legend_ActivityPage",  --点击传奇_活动栏
    Button_Legend_DissWinTip        = "Button_Legend_DissWinTip",    --点击传奇_解散成功提示框

    Button_Dasheng                   = "Button_Dasheng",  --点击大圣觉醒_大厅按钮
    Button_Dasheng_Acitivity         = "Button_Dasheng_Acitivty", --点击大圣觉醒_活动栏

    Button_Moyu = "Button_Moyu", --点击大圣觉醒_大厅按钮
    Button_Moyu_Acitivity = "Button_Moyu_Acitivty", --点击大圣觉醒_活动栏
    Button_Moyu_DissWinTip = "Button_Moyu_DissWinTip",        -- 点击大圣觉醒_解散成功提示框

    SingleRoundShare                = "SingleRoundShare",            -- 单局分享回放码的次数
    LookReplayRound                 = "LookReplayRound",              -- 查看回放次数

    
    Continue_Share                  = "Continue_share",     --点击继续分享
    NoMore_Notice                   = "NoMore_Notice",      --不再提示
    Button_Room_Rule                = "Button_Room_Rule", -- 房间规则
    Button_Auto_Hu_Click_new            = "Button_Auto_Hu_Click_new", -- 点击自动胡牌按钮
    Button_Auto_Hu_Cancle_new           = "Button_Auto_Hu_Cancle_new",-- 点击取消自动胡牌按钮

    -- 金币场猜鸡牌
    Gold_Gamble_Click_Main          = "Gold_Gamble_Click_Main", -- 猜鸡牌主按钮
    Gold_Gamble_Click_Stop          = "Gold_Gamble_Click_Stop", -- 停止竞猜
    Gold_Gamble_Click_Bet_1         = "Gold_Gamble_Click_Bet_1", -- 第一个下注按钮
    Gold_Gamble_Click_Bet_2         = "Gold_Gamble_Click_Bet_2", -- 第二个下注按钮
    Gold_Gamble_Click_Change        = "Gold_Gamble_Click_Change", -- 切换下注方案

    lobby_account_find              = "lobby_account_find",      --大厅老账号找回
    update_get_card                 = "update_get_card",        --更新送房卡
    personal_center_account_find    = "personal_center_account_find" ,   --个人中心老账号找回
    get_account_verification_code   = "get_account_verification_code",       --验证码获取
    account_verification_code_copy  = "account_verification_code_copy",     -- 复制
    jump_to_new_app                 = "jump_to_new_app",                    -- 前往新版
    jump_to_old_app                 = "jump_to_old_app",                    -- 前往旧版
    jump_to_new_app_at_once         = "jump_to_new_app_at_once",            -- 立即下载新版本
    paste_account_verification_code = "paste_account_verification_code",    -- 粘贴
    bind_old_account                = "bind_old_account",                   -- 一键找回

    -- club离线推送
    btn_club_push_willing           = "btn_club_push_willing",              -- 愿意
    btn_club_push_notWilling        = "btn_club_push_notWilling",           -- 不愿意
    btn_club_push_refuse            = "btn_club_push_refuse",               -- 坚决拒收
    btn_club_push_hesitate          = "btn_club_push_hesitate",             -- 我在想想
    btn_club_push_open              = "btn_club_push_open",                 -- 去开启
    clubPushSettingClick_on         = "clubPushSettingClick_on",            -- 设置离线推送开
    clubPushSettingClick_off        = "clubPushSettingClick_off",           -- 设置离线推送关

    -- 回流活动
    Activity_Comeback_Share_Image_ = "Activity_Comeback_Share_Image_", -- 分享图片 需要手动再加一个 image id
    Click_BuYu                      = "Click_BuYu", -- 大厅的捕鱼跳转按钮

    Redpack_Click                   = "redpack_click",       --拆红包活动点击

    collectionActivityRule          = "collectionActivityRule", -- 集赞活动规则
    collectionActivityReceive       = "collectionActivityReceive", -- 集赞活动领取房卡
    collectionActivityShare         = "collectionActivityShare", -- 集赞活动分享
    comebackInvite_invite_click     = "comebackInvite_invite_click", --邀新回流活动邀请按钮

    show_tuisong                    = "show_tuisong",    --弹出推送
    open_tuisong                    = "open_tuisong",     --点击打开推送
    close_tuisong                   = "close_tuisong",      --关闭推送
    not_open_tuisong                = "not_open_tuisong",   --没有开启推送

    click_nianbao                   = "click_nianbao",      --点击年报
    share_nianbao                   = "share_nianbao",      --分享年报


    first_in_update_ios             = "first_in_update_ios",     --首次进入游戏
    first_in_login_ios              = "first_in_login_ios",     --首次进入登录界面
    first_in_game_ios               = "first_in_game_ios",      --首次进入游戏
    first_in_update_android         = "first_in_update_android",     --首次进入游戏
    first_in_login_android          = "first_in_login_android",     --首次进入登录界面
    first_in_game_android           = "first_in_game_android",      --首次进入游戏

    Click_Wen_Juan_Main             = "Click_Wen_Juan", -- 点击问卷按钮
    Click_Wen_Juan_Link             = "Click_Wen_Juan_Link", -- 问卷跳转

    erdingguai_homepage             = "erdingguai_homepage",    --二丁拐回首页按钮
    erdingguai_friendCircle         = "erdingguai_friendCircle", --二丁拐前往亲友圈按钮

    Click_Mingpian                  = "Click_Mingpian",      --点击名片（复制战绩）

    Click_Welfare                   = "Click_Welfare",       --点击每日福利
    Show_DissmissAdvert             = "Show_DissmissAdvert", --显示俱乐部第一局中途解散广告

    Individual_Record_Click         = "Individual_Record_Click", --联盟内点击成员的战绩按钮
    CK_SuperLeague_Dis_Room        = "CK_SuperLeague_Dis_Room", --盟主点击详情弹出解散房间
    CK_SuperLeague_Dis_Room_Ok     = "CK_SuperLeague_Dis_Room_Ok ", --盟主解散房间点击ok
   
    CK_SuperLeague_Play_Dis_Room        = "CK_SuperLeague_Play_Dis_Room",  -- 盟主牌局内强制解散房间（游戏内）       
    CK_SuperLeague_Mem_Invite        = "CK_SuperLeague_Mem_Invite",  -- 联盟群主邀请成员
    CK_SuperLeague_Invite_ByID        = "CK_SuperLeague_Invite_ByID",  -- 联盟群主通过玩家ID邀请玩家
    CK_SuperLeague_Invite_ByWechat        = "CK_SuperLeague_Invite_ByWechat",  -- 联盟群主通过微信邀请
    CK_SuperLeague_Invite_KeyBoard        = "CK_SuperLeague_Invite_KeyBoard",  -- 联盟群主自定义键盘的邀请按钮点击
    Suc_SuperLeague_Invite        = "Suc_SuperLeague_Invite",  -- 联盟群主邀请成功统计
    CK_SuperLeague_RoomInfo_Watch = "CK_SuperLeague_RoomInfo_Watch", --联盟盟主通过房间详情点击观战按钮统计
    CK_SuperLeague_headicon_Watch = "CK_SuperLeague_headicon_Watch", --联盟盟主通过牌桌头像观战数量
}

 
-- 统计Emoj表情发出的人数以及人次
ns.ChatEmojTimes = {
    Emoj_index_1 = "Emoj_1_new",
    Emoj_index_2 = "Emoj_2_new",
    Emoj_index_3 = "Emoj_3_new",
    Emoj_index_4 = "Emoj_4_new",
    Emoj_index_5 = "Emoj_5_new",
    Emoj_index_6 = "Emoj_6_new",
    Emoj_index_7 = "Emoj_7_new",
    Emoj_index_8 = "Emoj_8_new",
    Emoj_index_9 = "Emoj_9_new",
    Emoj_index_10 = "Emoj_10_new",
    Emoj_index_11 = "Emoj_11_new",
    Emoj_index_12 = "Emoj_12_new",
    Emoj_index_13 = "Emoj_13_new",
    Emoj_index_14 = "Emoj_14_new",
    Emoj_index_15 = "Emoj_15_new",
    Emoj_index_16 = "Emoj_16_new",
    Emoj_index_17 = "Emoj_17_new",
    Emoj_index_18 = "Emoj_18_new",
    Emoj_index_19 = "Emoj_19_new",
    Emoj_index_20 = "Emoj_20_new",
}

-- 统计加入房间的方式(用于服务器做BI数据统计)
ns.JOIN_ROOM_STYLE = {
	InputRoomNumber     = "JoinRoom_RoomID",                -- 通过输入房间号进入房间
	MagicWindow         = "JoinRoom_MW",                    -- 通过魔窗进入房间
	CopyRoomNumber      = "JoinRoom_Copy",                  -- 通过拷贝房间号进入房间
    Watch               = "JoinRoom_Watch",                 -- 通过观战进入房间
    ClickTable          = "JoinRoom_ClickTable",            -- 通过点击亲友圈牌桌进入房间
    ClickButton         = "JoinRoom_ClickButton",           -- 通过点击亲友圈加入按钮进入房间
    Campaign            = "JoinRoom_Campaign",              -- 通过比赛进入房间
    Gold                = "JoinRoom_Gold",                  -- 通过金币场进入房间
    ClubRoomInvite      = "ClubRoomInvite",                 -- 俱乐部房间邀请
    FriendRoomInvite    = "FriendRoomInvite",               -- 好友房间邀请
    FriendList          = "FriendList",                     -- 好友立即组局
    ClubCreateRoom      = "ClubCreateRoom",                 -- 俱乐部创建房间
    HallCreateRoom      = "HallCreateRoom",                 -- 大厅创建房间
    Renewal             = "Renewal",                        -- 再来一局
    LeagueCreateRoom    = "LeagueCreateRoom",               -- 联盟创建房间
}

-- 统计常用语次数
-- ns.COMMON_LANGUAGE ={
--     phrase01       = "phrase01",           -- 打张牌给我碰嘛
--     phrase02       = "phrase02",           -- 我这个牌硬是闯到鬼了
--     phrase03       = "phrase03",           -- 麻将有首歌，上碰下自摸
--     phrase04       = "phrase04",           -- 你弹簧手是不是？快点出
--     phrase05       = "phrase05",           -- 菩萨菩萨，给我摸个咔咔
--     phrase06       = "phrase06",           -- 想哭都哭不出来
--     phrase07       = "phrase07",           -- 必须点个赞
--     phrase08       = "phrase08",           -- 套路好深哦
-- }

local CampaignConst = {
    START_WATCH_CAMPAIGN_LIST = 1,     --开始关注赛事列表
    STOP_WATCH_CAMPAIGN_LIST  = 0     --取消关注赛事列表
}
ns.StatisticNames = StatisticNames;
ns.CampaignConst = CampaignConst;

 --phoneMgr args
ns.phoneMgr =
{
    phonebind=1,
    phonechange=2,
    clubBindPhone = 3,
    phonelogin=4
}


------------------------------------------------------ BI -----------------------------------------------------------------
-- 分享类型
ns.shareType = 
{
    Main_Share = 1, -- 大厅分享
    Friend_Share = 2, -- 朋友分享
    Group_Share = 3, -- 朋友圈分享
    Activity_Share = 4, -- 活动分享
    System_Share = 5, -- 系统分享
    MainScene_Share = 6, -- 免费领房卡分享
    Agent_Button = 7, -- 成为代理
}

-- bi统计分享内容
ns.getBIStatistics = function(type)
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local tiem = game.service.TimeService:getInstance():getCurrentTime()
	local url = string.format("http://talking-data.bi.mahjong.nbigame.com:8080/data_listener/listen/btn_event.do?player_id=%d&ts=%d&button=%d", roleId, tiem, type)
	kod.util.Http.sendRequest(url, {}, nil, "POST")
end

--房间类型
ns.roomType = {
    none = 0x0000,
    gold = 0x1000,
    -- 0xFXXX为客户端自行定义的
    normal = 0xF001,
    campaign = 0XF002,
    club = 0xF003,
    league =0xF004,
    replay = 0xFFFF,
}

-- 玩家所处大厅类型 client only
ns.LobbyType = {
    None = 0x0000,
    Normal = 0x0F01,
    Gold = 0x0F02,
    Campaign = 0x0F03,
    Club = 0x0F04,
}

ns.Chuanqi_BI_Time = 20