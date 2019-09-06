local UI_PATH = "app.game.ui."

local UIClub_PATH = "app.game.ui.club."

local UICampaign_PATH = "app.game.ui.campaign."

local UIGift_PATH = "app.game.ui.gift."
local UIBackpack_PATH = "app.game.ui.backpack."
local UIGold_PATH = "app.game.ui.gold."

local UIMall_PATH = "app.game.ui.mall."

local UISHARE_PATH = "app.game.share."
local UIGamble_PATH = "app.game.ui.gamble."

local UIAgent_PATH = "app.game.ui.agent."

local UIActivity_PATH = "app.game.ui.activity."

local UIFriend_PATH = "app.game.ui.friend."
local UIBigLeague_PATH = "app.game.ui.bigLeague."

local UI_CONFIG = {
    UIConnectionMessageBox 	    = UI_PATH .. "UIConnectionMessageBox",
    UISplash 					= UI_PATH .. "UISplash",
    UILaunch	 				= UI_PATH .. "UILaunch",
    UIPhoneLogin  				= UI_PATH .. "UIPhoneLogin",
    UIMain   					= UI_PATH .. "UIMain",
    UIHelp   					= UI_PATH .. "UIHelp",
    UIShare  					= UI_PATH .. "UIShare",
    UIShareSystem  				= UI_PATH .. "UIShareSystem",
    UIShareWTF  				= UISHARE_PATH .. "UIShareWTF",
    UIShareWTF_chaoshan  		= UISHARE_PATH .. "UIShareWTF_chaoshan",
    UIShareDing					= UISHARE_PATH .. "UIShareDing",
    UIShareFindWx				= UISHARE_PATH .. "UIShareFindWx",
    UISetting       			= UI_PATH .. "UISetting",
    UISetting2       			= UI_PATH .. "UISetting2",
    UITipPanel       			= UI_PATH .. "UITipPanel",
    UICreateRoom    			= UI_PATH .. "UICreateRoom",
    UIJoinRoom    				= UI_PATH .. "UIJoinRoom",
    UIBattle  	    			= UI_PATH .. "UIBattle",
    UIReconnectTips	 			= UI_PATH .. "UIReconnectTips",
    UIRoundReportPage 			= UI_PATH .. "UIRoundReportPage",
    UIFinalReport				= UI_PATH .. "UIFinalReport",
    UIAward			            = UI_PATH .. "UIAward",
    UIMahjongSelector   		= UI_PATH .. "UIMahjongSelector",
    UIMarqueeTips 				= UI_PATH .. "UIMarqueeTips",
    UIAdvancedMarqueeTips 		= UI_PATH .. "UIAdvancedMarqueeTips",
    UIEarlyStartVote 			= UI_PATH .. "UIEarlyStartVote",
    UIApplyVote 				= UI_PATH .. "UIApplyVote",
    UIDissmissAdvert 			= UI_PATH .. "UIDissmissAdvert",
    UIChatPanel         		= UI_PATH .. "UIChatPanel",
    UINotice					= UI_PATH .. "UINotice",
    UIPlayback          		= UI_PATH .. "UIPlayback",
    UIHistoryRecord				= UI_PATH .. "UIHistoryRecord",
    UIHistoryDetail 			= UI_PATH .. "UIHistoryDetail",
    UICardsInfo         		= UI_PATH .. "UICardsInfo",
    UIPlayerScene_btns			= UI_PATH .. "UIPlayerScene_btns",
    UIAgreement					= UI_PATH .. "UIAgreement",
    UIDiamondShop				= UI_PATH .. "UIDiamondShop",
    UIGps               		= UI_PATH .. "UIGps",
    UIShop 						= UI_PATH .. "UIShop",
    UI_Talking          		= UI_PATH .. "UI_Talking",
    UIQuickJoin					= UI_PATH .. "UIQuickJoin",
    UIRoundReportPage2 			= UI_PATH .. "UIRoundReportPage2",
    UIMoneyTree 				= UI_PATH .. "UIMoneyTree",
    UIMoneyTreeAward			= UI_PATH .. "UIMoneyTreeAward",
    UIMoneyTreeMyAwardRecord	= UI_PATH .. "UIMoneyTreeMyAwardRecord",
    UIEvaluate 					= UI_PATH .. "UIEvaluate",
    UISelectDistrict			= UI_PATH .. "UISelectDistrict",
    UIGuide						= UI_PATH .. "UIGuide",
    UIAnswer					= UI_PATH .. "UIAnswer",
    UIBindPhoneActivity 		= UI_PATH .. "UIBindPhoneActivity",
    UIOpenTuisong				= UI_PATH .. "UIOpenTuisong",

    UIPlayerScene_watch_btns 	= UI_PATH .. "UIPlayerScene_watch_btns",
    UISharePolite 				= UI_PATH .. "UISharePolite",
    UICertification    			= UI_PATH .. "UICertification",
    UIChangeNotice              = UI_PATH .. "UIChangeNotice",
    UIUpdateBS					= UI_PATH .. "UIUpdateBS",
--	UITestJPush					= UI_PATH .. "UITestJPush",
	UIPlayerScene_watch_btns 	= UI_PATH .. "UIPlayerScene_watch_btns",
    UISharePolite 				= UI_PATH .. "UISharePolite",
    UILanguage 					= UI_PATH .. "UILanguage",
    UIRuleBox					= UI_PATH .. "UIRuleBox",
    UIPayMethod					= UI_PATH .. "UIPayMethod",
    UIMallTips                  = UI_PATH .. "mall.UIMallTips",
    UISuperMall 				= UI_PATH .. "mall.UISuperMall",
    UIMallReward_Phone			= UI_PATH .. "mall.UIMallReward_Phone",
    UIMallReward_Address		= UI_PATH .. "mall.UIMallReward_Address",
    UIMallBill					= UI_PATH .. "mall.UIMallBill",
    UIMallQuickCharge			= UI_PATH .. "mall.UIMallQuickCharge",
    UIMallCampaignTicket		= UI_PATH .. "mall.UIMallCampaignTicket",
    UIPurchaseSelect			= UI_PATH .. "mall.subPage.UIPurchaseSelect",
    UITimeDelay                 = UI_PATH .. "UITimeDelay",
    UIWaiting					= UI_PATH .. "UIWaiting",
    UITopTipsAnim				= UI_PATH .. "UITopTipsAnim",
    UIAutoDiscardTips			= UI_PATH .. "UIAutoDiscardTips",
    UITurnCard 					= UI_PATH .. "UITurnCard",
    UITurnCardAward 			= UI_PATH .. "UITurnCardAward",
    UITurnCardHelp 				= UI_PATH .. "UITurnCardHelp",
    UITurnCardChance 			= UI_PATH .. "UITurnCardChance",
    UITurnCardItem				= UI_PATH .. "UITurnCardItem",

    UINewShare					= UI_PATH .. "newshare.UINewShare",
    UINewShareItem				= UI_PATH .. "newshare.UINewShareItem",
    UINewShareHelp				= UI_PATH .. "newshare.UINewShareHelp",
    UINewShareFindWx			= UI_PATH .. "newshare.UINewShareFindWx",

    UIWeekSign 					= UI_PATH .. "weeksign.UIWeekSign",
    UIWeekSignHelp				= UI_PATH .. "weeksign.UIWeekSignHelp",
    UIWeekSignItem				= UI_PATH .. "weeksign.UIWeekSignItem",

    UIMonthSign 				= UI_PATH .. "monthsign.UIMonthSign",
    UIMonthSignItem				= UI_PATH .. "monthsign.UIMonthSignItem",
    UIMonthSignTips 			= UI_PATH .. "monthsign.UIMonthSignTips",
    UIElemItem					= UI_PATH .. "element.UIElemItem",

    UIShareLogo					= UI_PATH .. "UIShareLogo",
    UIActivityList				= UI_PATH .. "UIActivityList",
    UIGpsNew					= UI_PATH .. "UIGpsNew",
    UIAgreementOnLogin			= UI_PATH .. "UIAgreementOnLogin",
    UIFreeCard					= UI_PATH .. "UIFreeCard",
    UIQuestionnaire            = UI_PATH .. "UIQuestionnaire",
    UIMainSceneShare            = UI_PATH .. "UIMainSceneShare",
    UICardsInfo_new				= UI_PATH .. "UICardsInfo_new",
    UILastCrads					= UI_PATH .. "UILastCrads",
    UIAccountAssociation		= UI_PATH .. "UIAccountAssociation",
    UIReport					= UI_PATH .. "UIReport",
    UIReportList				= UI_PATH .. "UIReportList",
    UIReportMain				= UI_PATH .. "UIReportMain",
    UIReportLED					= UI_PATH .. "UIReportLED",
    UIConnectionMessageBox      = UI_PATH .. "UIConnectionMessageBox",

	-- message
	UIMessageMain				= UI_PATH .. "message.UIMessageMain",
    UIMail						= UI_PATH .. "message.UIMail",
    UIReceiveMailAttachment		= UI_PATH .. "message.UIReceiveMailAttachment",

	-- login
	UILogin  					= UI_PATH .. "login.UILogin",
    UILoginMethod  				= UI_PATH .. "login.UILoginMethod",

	-- playerInfo
	UIPlayerinfo2   	 		= UI_PATH .. "playerInfo.UIPlayerinfo2",
    UIPlayerinfo3				= UI_PATH .. "playerInfo.UIPlayerinfo3",
    UIBuyExpression				= UI_PATH .. "playerInfo.UIBuyExpression",
    UIPersonalCenter   	 		= UI_PATH .. "playerInfo.UIPersonalCenter",
    UIOfflineRoomInfo           = UI_PATH .. "UIOfflineRoomInfo",
	
	--lottery draw
	UILuckyDraw 				= UI_PATH .. "luckydraw.UILuckyDraw",
    UILuckyDrawItem 			= UI_PATH .. "luckydraw.UILuckyDrawItem",
    UILuckyDrawTenItems			= UI_PATH .. "luckydraw.UILuckyDrawTenItems",
    UILuckyDrawHelp				= UI_PATH .. "luckydraw.UILuckyDrawHelp",
    UILuckyDrawAward			= UI_PATH .. "luckydraw.UILuckyDrawAward",
    UILuckyDrawToShop			= UI_PATH .. "luckydraw.UILuckyDrawToShop",
    UILuckyDrawGetHongbao		= UI_PATH .. "luckydraw.UILuckyDrawGetHongbao",

	-- open redpack
	UIRedpackOpen 				= UI_PATH .. "redpack.UIRedpackOpen",
	UIRedpackDetail				= UI_PATH .. "redpack.UIRedpackDetail",
	UIRedpackFriends			= UI_PATH .. "redpack.UIRedpackFriends",
	UIRedpackHelp 				= UI_PATH .. "redpack.UIRedpackHelp",
	UIRedpackMine 				= UI_PATH .. "redpack.UIRedpackMine",
	UIRedpackCall 				= UI_PATH .. "redpack.UIRedpackCall",
	UIRedpackQuit 				= UI_PATH .. "redpack.UIRedpackQuit",
	UIRedpackShareComplete 		= UI_PATH .. "redpack.UIRedpackShareComplete",
	UIRedpackVerify				= UI_PATH .. "redpack.UIRedpackVerify",
	UIRedpackWithDraw			= UI_PATH .. "redpack.UIRedpackWithDraw",
	UIRedpackNewPlayer			= UI_PATH .. "redpack.UIRedpackNewPlayer",
	UIRedpackShare				= UI_PATH .. "redpack.UIRedpackShare",
	UIRedpackWay				= UI_PATH .. "redpack.UIRedpackWay",
	UIRedpackOtherAward			= UI_PATH .. "redpack.UIRedpackOtherAward",

	-- friend
	UIFriendMain				= UIFriend_PATH .. "UIFriendMain",
    UIFriendRoomInvite			= UIFriend_PATH .. "UIFriendRoomInvite",
    UIFriendRoomInviteList		= UIFriend_PATH .. "UIFriendRoomInviteList",

	--club
	UIClubInvitation			= UIClub_PATH .. "UIClubInvitation",
    UIClubWeChatInvited			= UIClub_PATH .. "UIClubWeChatInvited",
    UIClubSelectSearchTime		= UIClub_PATH .. "UIClubSelectSearchTime",
    UIClubTask					= UIClub_PATH .. "UIClubTask",
    UIClubIntroduction			= UIClub_PATH .. "UIClubIntroduction",
    UIClubEditNotice			= UIClub_PATH .. "UIClubEditNotice",
    UIClubRedPacket				= UIClub_PATH .. "UIClubRedPacket",
    UIClubRedBox				= UIClub_PATH .. "UIClubRedBox",
    UIClubReward				= UIClub_PATH .. "UIClubReward",
    UIClubRecommend				= UIClub_PATH .. "UIClubRecommend",
    UIClubInformation			= UIClub_PATH .. "UIClubInformation",
    UIClubEnterPlayerInfo		= UIClub_PATH .. "UIClubEnterPlayerInfo",
    UIClubDataReview			= UIClub_PATH .. "UIClubDataReview",
    UIClubInfo					= UIClub_PATH .. "UIClubInfo",
    UIClubRuleTips              = UIClub_PATH .. "UIClubRuleTips",

	--clubRecord
	UIClubHistoryPage     			= UIClub_PATH .. "record.UIClubHistoryPage",
    UIClubHistoryFilter     		= UIClub_PATH .. "record.UIClubHistoryFilter",
    UIClubHistoryDateSet     		= UIClub_PATH .. "record.UIClubHistoryDateSet",
    UIClubPersonalRecord			= UIClub_PATH .. "record.UIClubPersonalRecord",
    UIClubDissmisRoomReasonForm 	= UIClub_PATH .. "record.UIClubDissmisRoomReasonForm",
    UIClubDissmisRoomReasonResult 	= UIClub_PATH .. "record.UIClubDissmisRoomReasonResult",

	-- clubCreate
	UIClubRecommend_Help		= UIClub_PATH .. "create.UIClubRecommend_Help",
    UIClubMain					= UIClub_PATH .. "create.UIClubMain",
    UIClubRecommend_Invitation	= UIClub_PATH .. "create.UIClubRecommend_Invitation",
    UIClubCreate2				= UIClub_PATH .. "create.UIClubCreate2",
    UIClubList2					= UIClub_PATH .. "create.UIClubList2",

	--clubActivity
	UIClubActivityMain			= UIClub_PATH .. "activity.UIClubActivityMain",
    UIClubActivityInfo			= UIClub_PATH .. "activity.UIClubActivityInfo",
    UIClubActivityCreate		= UIClub_PATH .. "activity.UIClubActivityCreate",
    UIClubActivityTime			= UIClub_PATH .. "activity.UIClubActivityTime",
    UIClubZhuoJi			    = UIClub_PATH .. "activity.UIClubZhuoJi",
    UIClubZhuoJiHelp			= UIClub_PATH .. "activity.UIClubZhuoJiHelp",
    UIClubZhuoJiReward			= UIClub_PATH .. "activity.UIClubZhuoJiReward",
    UILeaderboardActivityMain	= UIClub_PATH .. "activity.leaderboard.UILeaderboardActivityMain",
    UIClubRewardCollection		= UIClub_PATH .. "activity.leaderboard.UIClubRewardCollection",
    UIClubRewardInfo			= UIClub_PATH .. "activity.leaderboard.UIClubRewardInfo",
    UIClubActivityDescription	= UIClub_PATH .. "activity.UIClubActivityDescription",
    UIClubRetainBlessing		= UIClub_PATH .. "activity.UIClubRetainBlessing",
    UIClubRetainSign			= UIClub_PATH .. "activity.UIClubRetainSign",
    UIClubActivityKoi			= UIClub_PATH .. "activity.koi.UIClubActivityKoi",

	-- clubMember
	UIClubMemberPage			= UIClub_PATH .. "member.UIClubMemberPage",
    UIClubMemberPage_Member		= UIClub_PATH .. "member.UIClubMemberPage_Member",
    UIClubMemberPage_Manager	= UIClub_PATH .. "member.UIClubMemberPage_Manager",
    UIClubMemberSetting			= UIClub_PATH .. "member.UIClubMemberSetting",
    UIClubMember_Remark			= UIClub_PATH .. "member.UIClubMember_Remark",
    UIClubMemberInfo			= UIClub_PATH .. "member.UIClubMemberInfo",

	-- clubRoom
	UIClubRoom					= UIClub_PATH .. "room.UIClubRoom",
    UIClubRoomInfo				= UIClub_PATH .. "room.UIClubRoomInfo",
    UIClubRoomInviteList		= UIClub_PATH .. "room.UIClubRoomInviteList",
    UIClubRoomInvite			= UIClub_PATH .. "room.UIClubRoomInvite",
    UIClubRuleSelecting			= UIClub_PATH .. "room.UIClubRuleSelecting",
    UIClubRuleSetting			= UIClub_PATH .. "room.UIClubRuleSetting",

	-- clubManager
	UIClubManager				= UIClub_PATH .. "manager.UIClubManager",

	-- clubGroup
	UIClubGroupMain				= UIClub_PATH .. "group.UIClubGroupMain",
    UIClubGroupImportList		= UIClub_PATH .. "group.UIClubGroupImportList",
    UIClubGroupLeaderInfo		= UIClub_PATH .. "group.UIClubGroupLeaderInfo",
    UIClubGroupChoice			= UIClub_PATH .. "group.UIClubGroupChoice",
    UIClubGroupMemberInfo		= UIClub_PATH .. "group.UIClubGroupMemberInfo",
	
	-- clubLeaderboard
	UIClubLeaderboardMain		= UIClub_PATH .. "leaderboard.UIClubLeaderboardMain",
    UIClubLeaderboardTime		= UIClub_PATH .. "leaderboard.UIClubLeaderboardTime",
    UIClubLeaderboardFind		= UIClub_PATH .. "leaderboard.UIClubLeaderboardFind",

	-- clubGuidance
    UIClubPushGuidance			= UIClub_PATH .. "guidance.UIClubPushGuidance",
	
	-- campaign
	UITrusteeship				= UICampaign_PATH .. "UITrusteeship",
    UICampaignWait				= UICampaign_PATH .. "UICampaignWait",
    UICampaignWaitToStart		= UICampaign_PATH .. "UICampaignWaitToStart",
    UICampaignHonorWall   		= UICampaign_PATH .. "UICampaignHonorWall",
    UICampaignRoundDetail		= UICampaign_PATH .. "UICampaignRoundDetail",
    UICampaignHonorDetail		= UICampaign_PATH .. "UICampaignHonorDetail",
    UICampaignStartTip			= UICampaign_PATH .. "UICampaignStartTip",

	-- campaign hall
	UICampaignCreate			= UICampaign_PATH .. "campaignHall.UICampaignCreate",
    UICampaignDetail			= UICampaign_PATH .. "campaignHall.UICampaignDetail",
    UICampaignResults			= UICampaign_PATH .. "campaignHall.UICampaignResults",
    UICampaignMain				= UICampaign_PATH .. "campaignHall.UICampaignMain",

	-- campaign battle
	UICampaignPromotion			= UICampaign_PATH .. "campaignBattle.UICampaignPromotion",
    UICampaignAnimPanel			= UICampaign_PATH .. "campaignBattle.anim.UICampaignAnimPanel",

	-- campaign  utils
	UICampaignSharePage			= UICampaign_PATH .. "campaignFunc.UICampaignSharePage",
    UICampaignDetailPage		= UICampaign_PATH .. "campaignFunc.UICampaignDetailPage",
    UICampaignRoundReport		= UICampaign_PATH .. "campaignFunc.UICampaignRoundReport",
    UICampaignGuide             = UICampaign_PATH .. "campaignFunc.UICampaignGuide",
    UICampaignGuideEntry       = UICampaign_PATH .. "campaignFunc.UICampaignGuideEntry",

	-- selfbuild campaign
	UICampaignCreate_Club		= UICampaign_PATH .. "selfbuild.UICampaignCreate_Club",
    UICampaignCreateConfirm_Club= UICampaign_PATH .. "selfbuild.UICampaignCreateConfirm_Club",
    UICampaignCreateDesc_Club	= UICampaign_PATH .. "selfbuild.UICampaignCreateDesc_Club",
    UICampaignResult_Club		= UICampaign_PATH .. "selfbuild.UICampaignResult_Club",
    UITimePickRoller            = UICampaign_PATH .. "selfbuild.UITimePickRoller",
    UICampaignHistory_Club		= UICampaign_PATH .. "selfbuild.UICampaignHistory_Club",
    UICampaignDetailPage_Club	= UICampaign_PATH .. "selfbuild.UICampaignDetailPage_Club",

	-- gift
	UIGiftTextField				= UIGift_PATH .. "UIGiftTextField",
    UIGiftDetail				= UIGift_PATH .. "UIGiftDetail",
    UIGiftList   				= UIGift_PATH .. "UIGiftList",
    UIGiftRegress				= UIGift_PATH .. "UIGiftRegress",
    UIGiftNewPlayer				= UIGift_PATH .. "UIGiftNewPlayer",
    UIGetGiftSuccess			= UIGift_PATH .. "UIGetGiftSuccess",

	-- backpack
	UIBackpackDetail			= UIBackpack_PATH .. "UIBackpackDetail",
    UIVoucherDetail				= UIBackpack_PATH .. "UIVoucherDetail",
    UIBackpack					= UIBackpack_PATH .. "UIBackpack",
    UIBackpackGiftDetail		= UIBackpack_PATH .. "UIBackpackGiftDetail",
    UIBackpackConsumable		= UIBackpack_PATH .. "UIBackpackConsumable",

	--gold
	UIGoldMain					= UIGold_PATH.."UIGoldMain",
    UIGoldHelp 					= UIGold_PATH.."UIGoldHelp",
    UIGoldBrokeHelp 			= UIGold_PATH.."UIGoldBrokeHelp",
    UIGoldBegin 				= UIGold_PATH.."UIGoldBegin",
    UIGoldMatch					= UIGold_PATH.."UIGoldMatch",
    UIGoldRoundReport			= UIGold_PATH.."UIGoldRoundReport",
    UIGoldLeaveTip				= UIGold_PATH.."UIGoldLeaveTip",
    UIGoldPlayerInfo			= UIGold_PATH.."UIGoldPlayerInfo",
    UIGoldGamble                = UIGold_PATH .. "UIGoldGamble",
    UIGoldShareRoundResult		= UIGold_PATH.."UIGoldShareRoundResult",
    UIGoldShareRoundResult_ShareNode		= UIGold_PATH.."UIGoldShareRoundResult_ShareNode",
    UIGoldShareRoundResultTips  = UIGold_PATH.."UIGoldShareRoundResultTips",
	-- gold quick charge
	UIGoldQuickCharge_Result 	= UIGold_PATH.."quick_charge.UIGoldQuickCharge_Result",
    UIGoldQuickCharge_Normal 	= UIGold_PATH.."quick_charge.UIGoldQuickCharge_Normal",
    UIGoldQuickCharge_Upgrade 	= UIGold_PATH.."quick_charge.UIGoldQuickCharge_Upgrade",
    UIGoldQuickCharge_Luck 		= UIGold_PATH.."quick_charge.UIGoldQuickCharge_Luck",
    UIGoldQuickCharge_Luck_Downgrade 		= UIGold_PATH.."quick_charge.UIGoldQuickCharge_Luck_Downgrade",

    UIHeadMall					= UIMall_PATH .. "headmall.UIHeadMall",
    UIBuyHeadSelect				= UIMall_PATH .. "headmall.UIBuyHeadSelect",
    UIHeadConfirm				= UIMall_PATH .. "headmall.UIHeadConfirm",
    

	-- gamble
	UIGambleMain				= UIGamble_PATH.."UIGambleMain",
    UIGambleTips				= UIGamble_PATH.."UIGambleTips",
    UIGambleHelp				= UIGamble_PATH.."UIGambleHelp",

    UIActivity_ShareGetGold = UIActivity_PATH .. "UIActivity_ShareGetGold",

    UIAccountBindForNew  			= UI_PATH .. "UIAccountBindForNew",
    UIAccountBindForOld  			= UI_PATH .. "UIAccountBindForOld",
    UIAccountBindCode  				= UI_PATH .. "UIAccountBindCode",



    UIPropDetail				= UI_PATH .. "prop.UIPropDetail",
    UIPropProgressBar			= UI_PATH .. "prop.UIPropProgressBar",


	-- agent
	UIRecruit					= UIAgent_PATH .. "UIRecruit",
    UIAgentApply				= UIAgent_PATH .. "UIAgentApply",
    UIAgentHasApply				= UIAgent_PATH .. "UIAgentHasApply",
    UIRecruit2					= UIAgent_PATH .. "UIRecruit2",

	--��Ϧ�
	UIQiXiTwoGay				= UIActivity_PATH .. "qixi.UIQiXiTwoGay",
    UIQiXiCharge				= UIActivity_PATH .. "qixi.UIQiXiCharge",
    UIQiXiRewardGet				= UIActivity_PATH .. "qixi.UIQiXiRewardGet",
    UIQiXiRewardGet2			= UIActivity_PATH .. "qixi.UIQiXiRewardGet2",
    UIQiXiHelp					= UIActivity_PATH .. "qixi.UIQiXiHelp",

    UICommonRules				= UI_PATH .. "UICommonRules",
    UIH5Login				    = UI_PATH .. "UIH5Login",
    UIGoldenEggs				= UI_PATH .. "UIGoldenEggs",
    UIReplay				    = UI_PATH .. "UIReplay",
    UIShareReplayCode			= UI_PATH .. "UIShareReplayCode",

    UIGuoQing					= UIActivity_PATH .. "guoqing.UIGuoQing",

    UIShuang11					= UIActivity_PATH .. "shuang11.UIShuang11",

    UISpringFestivalInvitedOld = UIActivity_PATH .. "springInvited.UISpringFestivalInvitedOld",
    UISpringFestivalInvitedNew = UIActivity_PATH .. "springInvited.UISpringFestivalInvitedNew",
    UISpringFestivalInvitedHelp = UIActivity_PATH .. "springInvited.UISpringFestivalInvitedHelp",
    UISpringFestivalNoEnoughChance = UIActivity_PATH .. "springInvited.UISpringFestivalNoEnoughChance",
    UISpringFestivalMyGift = UIActivity_PATH .. "springInvited.UISpringFestivalMyGift",
    UISpringFestivalGetReward = UIActivity_PATH .. "springInvited.UISpringFestivalGetReward",
    UISpringFestivalSharePage = UIActivity_PATH .. "springInvited.UISpringFestivalSharePage",

    -- 回流活动
    UIComeback_Dialog =     UIActivity_PATH .. "comeback.UIComeback_Dialog",
    UIComeback_Rule =       UIActivity_PATH .. "comeback.UIComeback_Rule",
    UIComeback_WeeklyCheckIn =        UIActivity_PATH .. "comeback.checkin.UIComeback_WeeklyCheckIn",
    UIComeback_ClubManager_Lights =      UIActivity_PATH .. "comeback.manager.UIComeback_ClubManager_Lights",
    UIComeback_ClubManager_BindPlayers = UIActivity_PATH .. "comeback.manager.UIComeback_ClubManager_BindPlayers",
    UIComeback_ClubManager_Welcome =     UIActivity_PATH .. "comeback.manager.UIComeback_ClubManager_Welcome",

    UIBlessing					= UIActivity_PATH .. "shengdan.UIBlessing",
    UIChristmasPackage			= UIActivity_PATH .. "shengdan.UIChristmasPackage",
    UIChristmasSign				= UIActivity_PATH .. "shengdan.UIChristmasSign",

    -- 集码活动
    UICollectCodeMain =             UIActivity_PATH .. "collectcode.UICollectCodeMain",
    UICollectCodeCountDown =        UIActivity_PATH .. "collectcode.UICollectCodeCountDown",
    UICollectCodeResult =           UIActivity_PATH .. "collectcode.UICollectCodeResult",
    UICollectCodeMyCode_History =       UIActivity_PATH .. "collectcode.UICollectCodeMyCode_History",
    UICollectCodeMyCode_Being =     UIActivity_PATH .. "collectcode.UICollectCodeMyCode_Being",
    UICollectCodeMyCode_NoCode =    UIActivity_PATH .. "collectcode.UICollectCodeMyCode_NoCode",
    UICollectCodeRecordListDetail = UIActivity_PATH .. "collectcode.UICollectCodeRecordListDetail",
    UICollectCodeRecordList =       UIActivity_PATH .. "collectcode.UICollectCodeRecordList",
    UICollectCodeGetCodeResult =    UIActivity_PATH .. "collectcode.UICollectCodeGetCodeResult",
    UICollectCodeGetCodeTips =      UIActivity_PATH .. "collectcode.UICollectCodeGetCodeTips",
    UICollectCodeHelp =             UIActivity_PATH .. "collectcode.UICollectCodeHelp",
    UICollectCodeGuide		    = UIActivity_PATH .. "collectcode.UICollectCodeGuide",
    UICollectCodeMessageBox	    = UIActivity_PATH .. "collectcode.UICollectCodeMessageBox",

    UIActivityRule				= UIActivity_PATH .. "UIActivityRule",
    UICollectionActivity		= UIActivity_PATH .. "UICollectionActivity",
    UIDaTi		                = UIActivity_PATH .. "dati.UIDaTi",
    
    -- 回流活动2
    UIComebackInvite             = UIActivity_PATH .. "comeback2.UIComebackInvite",
    UIComebackBeInvited         = UIActivity_PATH .. "comeback2.UIComebackBeInvited",



	-- Guide
	UIGuide_UIWallet_1 = UI_PATH .. "guides.UIGuide_UIWallet_1",
    UIGuide_UIWallet_2 = UI_PATH .. "guides.UIGuide_UIWallet_2",

    UIWalletBill = UI_PATH .. "playerInfo.UIWalletBill",
    UIWalletWithdraw = UI_PATH .. "playerInfo.UIWalletWithdraw",

    UIUFOCatcherAlert = UIActivity_PATH .. "ufocatcher.UIUFOCatcherAlert",
    UIUFOCatcherChanceList = UIActivity_PATH .. "ufocatcher.UIUFOCatcherChanceList",
    UIUFOCatcherFailed = UIActivity_PATH .. "ufocatcher.UIUFOCatcherFailed",
    UIUFOCatcherHelp = UIActivity_PATH .. "ufocatcher.UIUFOCatcherHelp",
    UIUFOCatcherMain = UIActivity_PATH .. "ufocatcher.UIUFOCatcherMain",
    UIUFOCatcherSuccess = UIActivity_PATH .. "ufocatcher.UIUFOCatcherSuccess",
    UIUFOCatcherTip = UIActivity_PATH .. "ufocatcher.UIUFOCatcherTip",
    UIUFOCatcherRecord = UIActivity_PATH .. "ufocatcher.UIUFOCatcherRecord",

    UICommonHelp = UI_PATH .. "common.UICommonHelp",

    -- util
    UIKeyboard                  = "app.game.util.UIKeyboard",
    UIKeyboard2                 = "app.game.util.UIKeyboard2",
    UIKeyboard3                 = "app.game.util.UIKeyboard3",

    -- bigLeague
    UIBigLeagueMain = UIBigLeague_PATH .. "UIBigLeagueMain",
    UIBigLeagueMyScore =  UIBigLeague_PATH .. "UIBigLeagueMyScore",
    UIBigleagueEditNotice = UIBigLeague_PATH .. "UIBigleagueEditNotice",

    UIBigLeagueMask = UIBigLeague_PATH.."UIBigLeagueMask",
    UIBigLeagueHelp = UIBigLeague_PATH.."UIBigLeagueHelp",
    UIBigLeagueNameSetting = UIBigLeague_PATH .. "UIBigLeagueNameSetting",
    UIBigLeagueScoreSetting = UIBigLeague_PATH .. "UIBigLeagueScoreSetting",
    UIBigLeagueCreate = UIBigLeague_PATH .. "UIBigLeagueCreate",

    UIBigLeagueGameRuleList = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameRuleList",
    UIBigLeagueGameRuleEdit = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameRuleEdit",
    UIBigLeagueGameRuleLottery = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameRuleLottery",
    UIBigLeagueGoldSetting = UIBigLeague_PATH .. "gameRule.UIBigLeagueGoldSetting",
    UIBigLeagueGameRuleSelect = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameRuleSelect",
    UIBigLeagueGameFilter = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameFilter",
    UIBigLeagueGameInfoDetail = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameInfoDetail",
    UIBigLeagueGameHelp = UIBigLeague_PATH .. "gameRule.UIBigLeagueGameHelp",

    UIBigLeagueGamePlayStatistics = UIBigLeague_PATH .. "gameRule.UIBigLeagueGamePlayStatistics",

    UIBigLeagueList = UIBigLeague_PATH.."leagueInfo.UIBigLeagueList",
    UIBigLeagueSetting = UIBigLeague_PATH.."leagueInfo.UIBigLeagueSetting",

    UIBigLeagueManager = UIBigLeague_PATH .. "manager.UIBigLeagueManager",
    UIBigLeagueLottery = UIBigLeague_PATH .. "animation.UIBigLeagueLottery",


    UIBigLeagueMember = UIBigLeague_PATH .. "member.UIBigLeagueMember",
    UIBigLeagueMemberSetting = UIBigLeague_PATH .. "member.UIBigLeagueMemberSetting",
    UIBigLeagueMemberInfo = UIBigLeague_PATH .. "member.UIBigLeagueMemberInfo",
    UIBigLeagueMemberFind = UIBigLeague_PATH .. "member.UIBigLeagueMemberFind",
    UIBigLeagueMemberManager = UIBigLeague_PATH .. "member.UIBigLeagueMemberManager",
    UIBigLeaguePartnerInvite = UIBigLeague_PATH .. "member.UIBigLeaguePartnerInvite",
    UIBigLeagueMemberInvite = UIBigLeague_PATH .. "member.UIBigLeagueMemberInvite",

    UIBigLeagueHistory = UIBigLeague_PATH .. "record.UIBigLeagueHistory",
    
    UIBigLeagueRank = UIBigLeague_PATH.."rank.UIBigLeagueRank",
    UIBigLeagueLikeTip = UIBigLeague_PATH .. "rank.UIBigLeagueLikeTip",
    UIBigLeagueDateSet = UIBigLeague_PATH .. "rank.UIBigLeagueDateSet",
    UIBigLeagueHistoryFilter = UIBigLeague_PATH .. "rank.UIBigLeagueHistoryFilter",

    UIBigLeagueClubScore = UIBigLeague_PATH .. "score.UIBigLeagueClubScore",
    UIBigLeagueScoreDetail = UIBigLeague_PATH.."score.UIBigLeagueScoreDetail",
    UIBigLeagueScoreMain = UIBigLeague_PATH .. "score.UIBigLeagueScoreMain",
    UIBigLeagueTeamScore = UIBigLeague_PATH .. "score.UIBigLeagueTeamScore",
    UIBigLeaguePartnerScore = UIBigLeague_PATH .. "score.UIBigLeaguePartnerScore",

    UIBigLeagueScoreTips = UIBigLeague_PATH .. "room.UIBigLeagueScoreTips",
    UIBigLeagueScoreAbnormal = UIBigLeague_PATH .. "room.UIBigLeagueScoreAbnormal",
    UIBigLeagueRoomInfo = UIBigLeague_PATH .. "room.UIBigLeagueRoomInfo",

    UIBigLeagueEventStatistics = UIBigLeague_PATH .. "leagueData.UIBigLeagueEventStatistics",
    UIBigLeagueSuperData = UIBigLeague_PATH .. "leagueData.UIBigLeagueSuperData",
    UIBigLeagueManagerData = UIBigLeague_PATH .. "leagueData.UIBigLeagueManagerData",
    UIBigLeagueMemberInvite = UIBigLeague_PATH .. "member.UIBigLeagueMemberInvite",
    UIBigLeagueFireGive   =  UIBigLeague_PATH .. "UIBigLeagueFireGive",
}


local UI_CONFIG_NAMES = {
    UIConnectionMessageBox 	    = "提示界面",
    UISplash 					= "闪屏界面",
    UILaunch	 				= "更新界面",
    UIPhoneLogin  				= "手机号登陆界面",
    UIMain   					= "主界面",
    UIHelp   					= "帮助界面(玩法说明)",
    UIShare  					= "分享界面",
    UIShareSystem  				= "分享界面",
    UIShareWTF  				= "分享界面",
    UIShareWTF_chaoshan  		= "分享界面",
    UIShareDing					= "叮叮分享界面",
    UIShareFindWx				= "分享引导界面",
    UISetting       			= "设置界面",
    UISetting2       			= "设置界面",
    UITipPanel       			= UI_PATH .. "UITipPanel",
    UICreateRoom    			= "创建房间界面",
    UIJoinRoom    				= "加入房间界面",
    UIBattle  	    			= UI_PATH .. "UIBattle",
    UIReconnectTips	 			= "断线重连界面",
    UIRoundReportPage 			= "单局结算界面",
    UIFinalReport				= "总局结算界面",
    UIAward			            = "奖励弹框界面",
    UIMahjongSelector   		= "UIMahjongSelector",
    UIMarqueeTips 				= "跑马灯界面",
    UIAdvancedMarqueeTips 		= "跑马灯界面",
    UIEarlyStartVote 			= "提前开局界面",
    UIApplyVote 				= "投票界面",
    UIDissmissAdvert 			= "成功解散页面",
    UIChatPanel         		= "聊天界面",
    UINotice					= "公告界面",
    UIPlayback          		= "回放按钮界面",
    UIHistoryRecord				= "战绩界面",
    UIHistoryDetail 			= "战绩详情界面",
    UICardsInfo         		= "牌局详情界面",
    UIPlayerScene_btns			= "打牌按钮界面",
    UIAgreement					= "用户协议界面",
    UIDiamondShop				= "UIDiamondShop",
    UIGps               		= "Gps界面",
    UIShop 						= "商城界面",
    UI_Talking          		= "语音聊天界面",
    UIQuickJoin					= "快速加入界面",
    UIRoundReportPage2 			= "单局结算界面",
    UIMoneyTree 				= "摇钱树界面",
    UIMoneyTreeAward			= "摇钱树奖励界面",
    UIMoneyTreeMyAwardRecord	= "摇钱树奖励记录界面",
    UIEvaluate 					= "UIEvaluate",
    UISelectDistrict			= "UISelectDistrict",
    UIGuide						= "新手引导界面",
    UIAnswer					= "问答界面",
    UIBindPhoneActivity 		= "电话绑定界面",
    UIOpenTuisong				= "开启推送界面",

    UIPlayerScene_watch_btns 	= "观战按钮界面",
    UISharePolite 				= "分享有礼界面",
    UICertification    			= "实名认证界面",
    UIChangeNotice              = "UIChangeNotice",
    UIUpdateBS					=  "更新公告界面",
--	UITestJPush					=  "UITestJPush",
    UILanguage 					=  "区域语音选择界面",
    UIRuleBox					=  "房间信息界面",
    UIPayMethod					=  "支付选择界面",
    UIMallTips                  =  "商城提示界面",
    UISuperMall 				=  "商城界面",
    UIMallReward_Phone			=  "商城话费充值界面",
    UIMallReward_Address		=  "商城实物信息填充界面",
    UIMallBill					=  "商城礼券收支记录界面",
    UIMallQuickCharge			=  "商城金豆快速充值界面",
    UIMallCampaignTicket		=  "比赛门票界面",
    UIPurchaseSelect			=  "头像框购买界面",
    UITimeDelay                 =  "超时详情界面",
    UIWaiting					=  "提前开局玩家等待界面",
    UITopTipsAnim				=  "比赛场顶部提示界面",
    UIAutoDiscardTips			=  "底部提示界面",
    UITurnCard 					=  "翻牌活动界面",
    UITurnCardAward 			=  "翻牌活动奖励界面",
    UITurnCardHelp 				=  "翻牌活动帮助界面",
    UITurnCardChance 			=  "翻拍活动机会界面",
    UITurnCardItem				=  "翻拍活动中奖界面",

    UINewShare					=  "新分享活动界面",
    UINewShareItem				=  "新分享活动中奖界面",
    UINewShareHelp				=  "新分享活动帮助界面",
    UINewShareFindWx			=  "新分享活动引导界面",

    UIWeekSign 					=  "七日签到界面",
    UIWeekSignHelp				=  "七日签到帮助界面",
    UIWeekSignItem				=  "七日签到中奖界面",

    UIMonthSign 				=  "月签到界面",
    UIMonthSignItem				=  "月签到中奖界面",
    UIMonthSignTips 			=  "月签到补签界面",
    UIElemItem					=  "物品详情界面",

    UIShareLogo					=  "分享截屏上的logo界面",
    UIActivityList				=  "活动列表界面",
    UIGpsNew					=  "Gps界面",
    UIAgreementOnLogin			=  "用户协议界面",
    UIFreeCard					=  "分享领钻界面",
    UIQuestionnaire            =  "有奖问卷界面",
    UIMainSceneShare            =  "分享界面",
    UICardsInfo_new				=  "单局结算牌桌信息界面",
    UILastCrads					=  "剩余牌界面",
    UIAccountAssociation		=  "关联账号界面",
    UIReport					=  "举报界面",
    UIReportList				=  "封号列表界面",
    UIReportMain				=  "举报主界面",
    UIReportLED					=  "封号跑马灯界面",

	-- message
	UIMessageMain				=  "消息主界面",
    UIMail						=  "邮件界面",
    UIReceiveMailAttachment		=  "邮件领取成功界面",

	-- login
	UILogin  					=  "登录界面",
    UILoginMethod  				=  "登录方式选择界面",

	-- playerInfo
	UIPlayerinfo2   	 		=  "用户信息界面",
    UIPlayerinfo3				=  "用户信息界面",
    UIBuyExpression				=  "金豆不足界面",
    UIPersonalCenter   	 		=  "个人中心界面",
    UIOfflineRoomInfo           =  "离线房间信息界面",
	
	--lottery draw
	UILuckyDraw 				=  "幸运抽奖界面",
    UILuckyDrawItem 			=  "幸运抽奖中奖界面",
    UILuckyDrawTenItems			=  "幸运抽奖十连抽界面",
    UILuckyDrawHelp				=  "幸运抽奖帮助界面",
    UILuckyDrawAward			=  "幸运抽奖中奖记录界面",
    UILuckyDrawToShop			=  "幸运抽奖前往商城界面",
    UILuckyDrawGetHongbao		=  "幸运抽奖领取红包界面",

	-- open redpack
	UIRedpackOpen 				=  "拆红包初始界面",
	UIRedpackDetail				=  "拆红包详情界面",
	UIRedpackFriends			=  "拆红包好友界面",
	UIRedpackHelp 				=  "拆红包帮助界面",
	UIRedpackMine 				=  "拆红包我的红包界面",
	UIRedpackCall 				=  "拆红包叫好友帮拆界面",
	UIRedpackQuit 				=  "拆红包离开界面",
	UIRedpackShareComplete 		=  "拆红包好友分享成功界面",
	UIRedpackVerify				=  "拆红包认证界面",
	UIRedpackWithDraw			=  "拆红包提现界面",
	UIRedpackNewPlayer			=  "拆红包新用户界面",
	UIRedpackShare				=  "拆红包分享界面",
	UIRedpackWay				=  "拆红包方法界面",
	UIRedpackOtherAward			=  "拆红包提现界面",

	-- friend
	UIFriendMain				= "好友界面",
    UIFriendRoomInvite			= "好友游戏邀请界面",
    UIFriendRoomInviteList		= "好友邀请列表界面",

	--club
	UIClubInvitation			=  "俱乐部我的申请界面",
    UIClubWeChatInvited			=  "俱乐部邀请成员界面",
    UIClubSelectSearchTime		=  "俱乐部时间选择界面",
    UIClubTask					=  "俱乐部活动界面",
    UIClubIntroduction			=  "俱乐部介绍界面",
    UIClubEditNotice			=  "俱乐部公告编辑界面",
    UIClubRedPacket				=  "俱乐部抢到红包界面",
    UIClubRedBox				=  "俱乐部抢红包界面",
    UIClubReward				=  "俱乐部中奖界面",
    UIClubRecommend				=  "俱乐部新用户推荐界面",
    UIClubInformation			=  "俱乐部邀请信息界面",
    UIClubEnterPlayerInfo		=  "俱乐部输入玩家信息界面",
    UIClubDataReview			=  "俱乐部牌局统计界面",
    UIClubInfo					=  "俱乐部信息界面",
    UIClubRuleTips              =  "UIClubRuleTips",

	--clubRecord
	UIClubHistoryPage     			=  "俱乐部战绩界面",
    UIClubHistoryFilter     		=  "俱乐部战绩筛选界面",
    UIClubHistoryDateSet     		=  "俱乐部战绩日期选择界面",
    UIClubPersonalRecord			=  "俱乐部个人战绩界面",
    UIClubDissmisRoomReasonForm 	=  "俱乐部解散原因界面",
    UIClubDissmisRoomReasonResult 	=  "俱乐部牌局解散结果界面",

	-- clubCreate
	UIClubRecommend_Help		=  "俱乐部新手推荐界面",
    UIClubMain					=  "俱乐部主界面",
    UIClubRecommend_Invitation	=  "俱乐部邀请码界面",
    UIClubCreate2				=  "俱乐部创建界面",
    UIClubList2					=  "俱乐部列表界面",

	--clubActivity
	UIClubActivityMain			=  "俱乐部活动主界面",
    UIClubActivityInfo			=  "俱乐部活动信息界面",
    UIClubActivityCreate		=  "俱乐部活动创建界面",
    UIClubActivityTime			=  "俱乐部活动时间选择界面",
    UIClubZhuoJi			    =  "俱乐部捉鸡界面",
    UIClubZhuoJiHelp			=  "俱乐部捉鸡帮助界面",
    UIClubZhuoJiReward			=  "俱乐部捉鸡奖励界面",
    UILeaderboardActivityMain	=  "俱乐部排行榜界面",
    UIClubRewardCollection		=  "俱乐部经理奖励界面",
    UIClubRewardInfo			=  "俱乐部排行榜信息界面",
    UIClubActivityDescription	=  "俱乐部活动描述界面",
    UIClubRetainBlessing		=  "俱乐部专属礼包界面",
    UIClubRetainSign			=  "俱乐部七日签到界面",
    UIClubActivityKoi			=  "俱乐部锦鲤活动界面",

	-- clubMember
	UIClubMemberPage			=  "俱乐部成员列表界面",
    UIClubMemberPage_Member		=  "俱乐部普通成员列表界面",
    UIClubMemberPage_Manager	=  "俱乐部管理成员列表界面",
    UIClubMemberSetting			=  "俱乐部成员管理界面",
    UIClubMember_Remark			=  "俱乐部成员备注界面",
    UIClubMemberInfo			=  "俱乐部成员信息界面",

	-- clubRoom
	UIClubRoom					=  "俱乐部房间列表界面",
    UIClubRoomInfo				=  "俱乐部房间信息界面",
    UIClubRoomInviteList		=  "俱乐部房间邀请界面",
    UIClubRoomInvite			=  "俱乐部被邀请界面",
    UIClubRuleSelecting			=  "俱乐部规则选择界面",
    UIClubRuleSetting			=  "俱乐部规则设置界面",

	-- clubManager
	UIClubManager				=  "俱乐部管理界面",

	-- clubGroup
	UIClubGroupMain				=  "俱乐部小组界面",
    UIClubGroupImportList		=  "俱乐部小组导入界面",
    UIClubGroupLeaderInfo		=  "俱乐部小组管理信息界面",
    UIClubGroupChoice			=  "俱乐部小组选择界面",
    UIClubGroupMemberInfo		=  "俱乐部小组成员信息界面",
	
	-- clubLeaderboard
	UIClubLeaderboardMain		=  "俱乐部排行榜界面",
    UIClubLeaderboardTime		=  "俱乐部排行榜时间选择界面",
    UIClubLeaderboardFind		=  "俱乐部大赢家筛选界面",

	-- clubGuidance
    UIClubPushGuidance			=  "俱乐部邀请升级界面",

	
	-- campaign
	UITrusteeship				=  "比赛托管界面",
    UICampaignWait				=  "比赛场等待界面",
    UICampaignWaitToStart		=  "比赛场等待匹配界面",
    UICampaignHonorWall   		=  "比赛场奖状界面",
    UICampaignRoundDetail		=  "比赛场单轮界面",
    UICampaignHonorDetail		=  "比赛场赢家列表界面",
    UICampaignStartTip			=  "比赛场开始提示界面",

	-- campaign hall
	UICampaignCreate			=  "比赛场报名界面",
    UICampaignDetail			=  "比赛场比赛详情界面",
    UICampaignResults			=  "比赛结果界面",
    UICampaignMain				=  "比赛场主界面",

	-- campaign battle
	UICampaignPromotion			=  "比赛场晋级界面",
    UICampaignAnimPanel			=  "比赛场动画界面",

	-- campaign  utils
	UICampaignSharePage			=  "比赛场分享界面",
    UICampaignDetailPage		=  "比赛详情子界面",
    UICampaignRoundReport		=  "比赛场结算界面",
    UICampaignGuide             =  "比赛场引导界面",
    UICampaignGuideEntry       =  "比赛场引导界面",

	-- selfbuild campaign
	UICampaignCreate_Club		=  "俱乐部比赛创建界面",
    UICampaignCreateConfirm_Club=  "俱乐部比赛创建确认界面",
    UICampaignCreateDesc_Club	=  "俱乐部比赛描述界面",
    UICampaignResult_Club		=  "俱乐部比赛结果界面",
    UITimePickRoller            =  "俱乐部比赛时间选择界面",
    UICampaignHistory_Club		=  "俱乐部比赛历史界面",
    UICampaignDetailPage_Club	=  "俱乐部比赛详情",

	-- gift
	UIGiftTextField				=  "领奖界面",
    UIGiftDetail				=  "领奖详情界面",
    UIGiftList   				=  "UIGiftList",
    UIGiftRegress				=  "回归礼包界面",
    UIGiftNewPlayer				=  "新手礼包界面",
    UIGetGiftSuccess			=  "领取礼包成功界面",

	-- backpack
	UIBackpackDetail			=  "物品详情界面",
    UIVoucherDetail				=  "代金券详情界面",
    UIBackpack					=  "背包界面",
    UIBackpackGiftDetail		=  "UIBackpackGiftDetail",
    UIBackpackConsumable		=  "UIBackpackConsumable",

	--gold
	UIGoldMain					= "金币场主界面",
    UIGoldHelp 					= "金币场帮助界面",
    UIGoldBrokeHelp 			= "金币场救济金界面",
    UIGoldBegin 				= "金币场开始界面",
    UIGoldMatch					= "金币场匹配界面",
    UIGoldRoundReport			= "金币场结算界面",
    UIGoldLeaveTip				= "金币场离开提示界面",
    UIGoldPlayerInfo			= "金币场玩家信息界面",
    UIGoldGamble                =  "金币场竞猜界面",
    UIGoldShareRoundResult		= "金币场分享界面",
    UIGoldShareRoundResult_ShareNode		= "金币场分享界面",
    UIGoldShareRoundResultTips  = "金币场分享界面",
	-- gold quick charge
	UIGoldQuickCharge_Result 	= "金币场购买金币成功界面",
    UIGoldQuickCharge_Normal 	= "金币场购买金币界面",
    UIGoldQuickCharge_Upgrade 	= "金币场领取礼包界面",
    UIGoldQuickCharge_Luck 		= "金币场幸运礼包界面",
    UIGoldQuickCharge_Luck_Downgrade 		= "金币场幸运礼包界面",

    UIHeadMall					= "头像商城界面",
    UIBuyHeadSelect				= "头像购买界面",
    UIHeadConfirm				= "头像购买确认界面",
    

	-- gamble
	UIGambleMain				= UIGamble_PATH.."UIGambleMain",
    UIGambleTips				= UIGamble_PATH.."UIGambleTips",
    UIGambleHelp				= UIGamble_PATH.."UIGambleHelp",

    UIActivity_ShareGetGold =  "分享领金币界面",

    UIAccountBindForNew  			=  "老账号找回界面",
    UIAccountBindForOld  			=  "账号互通体验界面",
    UIAccountBindCode  				=  "账号绑定验证码界面",



    UIPropDetail				=  "道具详情界面",


	-- agent
	UIRecruit					= "推广员界面",
    UIAgentApply				= "推广员信息填写界面",
    UIAgentHasApply				= "已填推广员信息界面",
    UIRecruit2					= "申请推广员界面",

	--��Ϧ�
	UIQiXiTwoGay				=  "qixi.UIQiXiTwoGay",
    UIQiXiCharge				=  "qixi.UIQiXiCharge",
    UIQiXiRewardGet				=  "qixi.UIQiXiRewardGet",
    UIQiXiRewardGet2			=  "qixi.UIQiXiRewardGet2",
    UIQiXiHelp					=  "qixi.UIQiXiHelp",

    UICommonRules				=  "UICommonRules",
    UIH5Login				    =  "UIH5Login",
    UIGoldenEggs				=  "砸蛋活动界面",
    UIReplay				    =  "查看他人回放界面",
    UIShareReplayCode			=  "UIShareReplayCode",

    UIGuoQing					=  "国庆活动界面",

    UIShuang11					=  "双11活动界面",

    UISpringFestivalInvitedOld =  "springInvited.UISpringFestivalInvitedOld",
    UISpringFestivalInvitedNew =  "springInvited.UISpringFestivalInvitedNew",
    UISpringFestivalInvitedHelp =  "springInvited.UISpringFestivalInvitedHelp",
    UISpringFestivalNoEnoughChance =  "springInvited.UISpringFestivalNoEnoughChance",
    UISpringFestivalMyGift =  "springInvited.UISpringFestivalMyGift",
    UISpringFestivalGetReward =  "springInvited.UISpringFestivalGetReward",
    UISpringFestivalSharePage =  "springInvited.UISpringFestivalSharePage",

    -- 回流活动
    UIComeback_Dialog =      "回流提示界面",
    UIComeback_Rule =        "回流规则界面",
    UIComeback_WeeklyCheckIn =         "回流奖励界面",
    UIComeback_ClubManager_Lights =       "回流点灯界面",
    UIComeback_ClubManager_BindPlayers =  "回流绑定界面",
    UIComeback_ClubManager_Welcome =      "回流欢迎界面",

    UIBlessing					=  "shengdan.UIBlessing",
    UIChristmasPackage			=  "shengdan.UIChristmasPackage",
    UIChristmasSign				=  "shengdan.UIChristmasSign",

    -- 集码活动
    UICollectCodeMain =              "collectcode.UICollectCodeMain",
    UICollectCodeCountDown =         "collectcode.UICollectCodeCountDown",
    UICollectCodeResult =            "collectcode.UICollectCodeResult",
    UICollectCodeMyCode_History =        "collectcode.UICollectCodeMyCode_History",
    UICollectCodeMyCode_Being =      "collectcode.UICollectCodeMyCode_Being",
    UICollectCodeMyCode_NoCode =     "collectcode.UICollectCodeMyCode_NoCode",
    UICollectCodeRecordListDetail =  "collectcode.UICollectCodeRecordListDetail",
    UICollectCodeRecordList =        "collectcode.UICollectCodeRecordList",
    UICollectCodeGetCodeResult =     "collectcode.UICollectCodeGetCodeResult",
    UICollectCodeGetCodeTips =       "collectcode.UICollectCodeGetCodeTips",
    UICollectCodeHelp =              "collectcode.UICollectCodeHelp",
    UICollectCodeGuide		    =  "collectcode.UICollectCodeGuide",
    UICollectCodeMessageBox	    =  "collectcode.UICollectCodeMessageBox",

    UIActivityRule				=  "规则说明界面",
    UICollectionActivity		=  "UICollectionActivity",
    UIDaTi		                =  "答题有奖界面",
    
    -- 回流活动2
    UIComebackInvite             =  "回流活动界面",
    UIComebackBeInvited         =  "回流活动老玩家界面",



	-- Guide
	UIGuide_UIWallet_1 =  "钱包引导界面",
    UIGuide_UIWallet_2 =  "钱包引导界面",

    UIWalletBill =  "钱包账单界面",
    UIWalletWithdraw =  "钱包提现界面",

    UIUFOCatcherAlert = "娃娃机提示界面",
    UIUFOCatcherChanceList =  "娃娃机机会界面",
    UIUFOCatcherFailed = "娃娃机抓取失败界面",
    UIUFOCatcherHelp =  "娃娃机帮助界面",
    UIUFOCatcherMain = "娃娃机主界面",
    UIUFOCatcherSuccess = "娃娃机抓取成功界面",
    UIUFOCatcherTip =  "娃娃机提示充值界面",
    UIUFOCatcherRecord = "娃娃机中奖记录界面",

    UICommonHelp =  "通用帮助界面",

    -- util
    UIKeyboard                  = "9格键盘界面",

    -- bigLeague
    UIBigLeagueMain = "大联盟主界面",
    UIBigLeagueMyScore =  "大联盟积分详情界面",

    UIBigLeagueMask = "大联盟阴影覆盖界面",
    UIBigLeagueHelp = "大联盟帮助界面",
    UIBigLeagueNameSetting = "大联盟改名界面",
    UIBigLeagueScoreSetting = "大联盟设置积分界面",
    UIBigLeagueCreate = "大联盟创建界面",

    UIBigLeagueGameRuleList = "大联盟玩法列表界面",
    UIBigLeagueGameRuleEdit = "大联盟玩法编辑界面",
    UIBigLeagueGameRuleLottery =  "大联盟玩法抽奖设置界面",
    UIBigLeagueGoldSetting = "大联盟金币设置界面",
    UIBigLeagueGameRuleSelect = "大联盟玩法选择界面",
    UIBigLeagueGamePlayStatistics = "大联盟玩法统计界面",

    UIBigLeagueList = "大联盟联盟列表界面",
    UIBigLeagueSetting = "大联盟设置界面",

    UIBigLeagueManager = "大联盟管理界面",
    UIBigLeagueLottery = "大联盟抽奖界面",


    UIBigLeagueMember = "大联盟成员界面",
    UIBigLeagueMemberSetting = "大联盟成员设置界面",
    UIBigLeagueMemberInfo = "大联盟成员信息界面",
    UIBigLeagueMemberFind = "大联盟成员搜索界面",

    UIBigLeagueHistory = "大联盟战绩界面",
    UIBigLeagueRank = "大联盟排行榜界面",
    UIBigLeagueLikeTip = "大联盟点赞界面",
    UIBigLeagueDateSet = "大联盟日期选择界面",
    UIBigLeagueRoomInfo = "大联盟房间信息界面",
    UIBigLeagueScoreTips = "大联盟总结算分数不足提示",
    UIBigLeagueScoreAbnormal = "大联盟分数不足解散原因",

    UIBigLeagueSuperData = "大联盟超级盟主数据详情界面",
    UIBigLeagueSuperData = "大联盟盟主界面",
    UIBigLeagueEventStatistics = "大联盟超级盟主数据主界面",
    UIBigLeagueMemberInvite = "大联盟群主邀请成员",
    UIBigLeagueFireGive = "盟主活跃值赠送界面",

    UIBigLeagueGameFilter = "联盟玩法筛选界面",
    UIBigLeagueGameInfoDetail = "玩法筛选界面玩法详情",
    UIBigLeagueGameHelp = "玩法筛选说明界面",
    UIBigleagueEditNotice = "大联盟公告编辑页面",
}

function UI_CONFIG.getChineseName(name)
    return UI_CONFIG_NAMES[name] or name
end
return UI_CONFIG;