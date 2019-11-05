
ƒ®

club.protocom.kodgames.message.proto.club"∞
ClubInfoPROTO
clubId (
clubName (	
invitationCode (	
	managerId (
managerName (	
status (G
banGameplays (21.com.kodgames.message.proto.club.BanGameplayPROTO
clubIcon (	
clubCreateTime	 (
hasActivity
 (
memberCount (
assistantIds (

clubNotice (	
hasLotteryActivity (
hasTask (
switches (M
presetGameplays (24.com.kodgames.message.proto.club.PresetGameplayProto
managerActivityVersion (
hasManagerActivity (
hasTreasure (
clubWhiteList (
todayPlayCount (
yesterdayPlayCount (
groupId (	
maxPresetGameplay (
leagueId (" 
CCLClubInfoREQ
clubId ("q
CLCClubInfoRES
result (
title (@
clubInfo (2..com.kodgames.message.proto.club.ClubInfoPROTO" 
CCLClubNameREQ
clubId (".
CLCClubNameRES
result (
name (	"J
CCLModifyClubInfoREQ
clubId (
clubName (	
clubIcon (	"&
CLCModifyClubInfoRES
result ("E
ClubNoticePROTO
sender (
content (	
	timestamp (""
CCLClubNoticeREQ
clubId ("e
CLCClubNoticeRES
result (A
notices (20.com.kodgames.message.proto.club.ClubNoticePROTO"6
CCLSendClubNoticeREQ
clubId (
notice (	"&
CLCSendClubNoticeRES
result ("I
CCLClubCostModifyREQ
clubId (
costType (
payType ("&
CLCClubCostModifyRES
result ("i
BanGameplayPROTO

mainRuleId (
isMainBanned (
banRoundTypes (
banGameplays ("}
CCLClubBanGameplayREQ
clubId (
areaId (D
	gameplays (21.com.kodgames.message.proto.club.BanGameplayPROTO"'
CLCClubBanGameplayRES
result ("1
CCLClubTableREQ
roleId (
clubId ("m
CLCClubTableRES
result (J
clubTableList (23.com.kodgames.message.proto.club.ClubTableInfoPROTO"b
ClubTablePlayerInfoPROTO
roleId (
name (	
head (	

ip (	
status ("Û
ClubTableInfoPROTO
clubId (
clubName (	
roomId (
cost (
payType (J
players (29.com.kodgames.message.proto.club.ClubTablePlayerInfoPROTO
	playerMax (
	gameplays (
	roundType	 (
createTimestamp
 (
	isRemoved (
hasStartBattle (
finishRoundCount (
	isPrivate (
isActingCreate ("?
CCLJoinClubInfoREQ
invitationCode (	
	inviterId ("°
CLCJoinClubInfoRES
result (@
clubInfo (2..com.kodgames.message.proto.club.ClubInfoPROTO
inviter (
inviterName (	
inviterIcon (	";
CCLJoinClubREQ
invitationCode (	
	inviterId (" 
CLCJoinClubRES
result ("0
CCLAccedeToClubInfoREQ
invitationCode (	"|
CLCAccedeToClubInfoRES
result (
clubName (	
managerName (	
memberCount (
maxMemberCount ("?
CCLAccedeToClubREQ
invitationCode (	
	inviterId ("$
CLCAccedeToClubRES
result (" 
CCLQuitClubREQ
clubId (" 
CLCQuitClubRES
result ("#
CCLClubMembersREQ
clubId ("ù
CLCClubMembersRES
result (E
members (24.com.kodgames.message.proto.club.ClubMemberInfoPROTO
maxMemberCount (
maxAssistantCount ("‚
ClubMemberInfoPROTO
roleId (
roleName (	
roleIcon (	
title (
joinTimestamp (
todayRoomCount (
yesterdayRoomCount (
totalRoomCount (
todayWinCount	 (
yesterdayWinCount
 (
todayCreateRoomCount ( 
yesterdayCreateRoomCount (
	inviterId (
inviterName (	
head (	
lastLoginTime (
totalWinCount (
sevenDayRoomCount (
lastRoomTime (
sevenDayWinCount (
memberRight (
remark (	
joinType (
isRealNameAuth (
headFrameId (
status (
isLeader (")
CCLClubApplicantListREQ
clubId ("r
CLCClubApplicantListRES
result (G

applicants (23.com.kodgames.message.proto.club.ClubApplicantPROTO"¢
ClubApplicantPROTO
roleId (
roleName (	
applyTimestamp (
inviterName (	
inviterDisplayId (
	isManager (
joinType ("E
CCLClubApplicantREQ
clubId (
roleId (
optype ("%
CLCClubApplicantRES
result ("Z
CCLKickOffMemberREQ
clubId (
roleId (
leagueId (
	partnerId ("%
CLCKickOffMemberRES
result ("¿
CCLCreateRoomREQ
roomType (
	gameplays (
	roundType (
clubId (
	managerId (
	isPrivate (
privateRoleIds (

createType (

inviteeIds	 ("T
CLCCreateRoomRES
result (
battleId (
roomId (
clubId ("≤
CLGCreateRoomREQ
	creatorId (
roomType (
	gameplays (
	roundType (
clubId (
cost (
payType (
clubManagerId (
clubName	 (	
canEarlyBattle3
 (
canEarlyBattle4 (
	isPrivate (
privateRoleIds (

createType (

inviteeIds (
banGameplays (
leagueId (
leaderId (

gameplayId (

scoreRatio (
gameplayName (	"π
GCLCreateRoomRES
result (
battleId (
roomId (
clubId (
	creatorId (
cost (
payType (

roundCount (
	playerMax	 (
	gameplays
 (
	isPrivate (
privateRoleIds (

createType (

createTime (
leagueId (

gameplayId ("±
BCLCheckEnterRoomREQ
roleId (
roomId (

roomClubId (
nickname (	
headImageUrl (	
	headFrame (
sex (

isIdentity (
joinType	 (	
specialEffect
 (
leagueId (
clubId (>
gpsInfo (2-.com.kodgames.message.proto.club.GpsInfoProto"¡
CLBCheckEnterRoomRES
result (
roleId (
roomId (

roomClubId (
nickname (	
headImageUrl (	
	headFrame (
sex (

isIdentity	 (
joinType
 (	
specialEffect (
leagueId (
clubId (>
gpsInfo (2-.com.kodgames.message.proto.club.GpsInfoProto"C
GpsInfoProto
status (
latitude (
	longitude ("â
GCLEnterRoomSYN
roomId (D
player (24.com.kodgames.message.proto.club.ClubPlayerInfoPROTO
clubId (
leagueId ("à
GCLQuitRoomSYN
roomId (D
player (24.com.kodgames.message.proto.club.ClubPlayerInfoPROTO
clubId (
leagueId ("∂
ClubPlayerInfoPROTO
roleId (
roleName (	

totalPoint (
position (
head (	

ip (	
status (
scores (
clubId	 (
score
 ("{
GCLDestroyRoomSYN
roomId (
clubId (
reason (
roleIds (
destroyTime (
leagueId ("6
GCLGmtDestroyRoomSYN
roomId (
clubId ("œ
GCLFinalMatchResultSYN
roomId (
clubId (
areaId (E
players (24.com.kodgames.message.proto.club.ClubPlayerInfoPROTO
destroyTime (
leagueId (
leaderGoldCount ("∑
GCLMatchResultSYN
roomId (
clubId (
overGameCount (E
players (24.com.kodgames.message.proto.club.ClubPlayerInfoPROTO
leagueId (

createTime ("G
GCLEnableSubCardSYN
roomId (
clubId (
leagueId ("B
CLGCheckRoleInfoREQ
roleId (
seqId (
area ("c
GCLCheckRoleInfoRES
result (
roleId (
seqId (
name (	
unionId (	"$
CCLActivityRankREQ
clubId ("{
CLCActivityRankRES
result (
clubId (E
users (26.com.kodgames.message.proto.club.ActivityRankItemPROTO"ﬂ
ActivityRankItemPROTO
roleId (
name (	
todayCreate (
	todayGame (
todayWin (
	todayRoom (
yesterdayCreate (
yesterdayGame (
yesterdayWin	 (
yesterdayRoom
 (")
CCLAllInvitationREQ

sourceType ("ç
CLCAllInvitationRES
result (
unprocessedCount (L
invitationList (24.com.kodgames.message.proto.club.InvitationInfoProto"è
InvitationInfoProto
clubId (
clubName (	
	managerId (
managerName (	
memberCount (
maxMemberCount (

createTime (
todayRoomCout (
sevenDayRoomCount	 (
clubRoomAbnormalRate
 (
	inviterId (
inviterName (	
inviterIcon (	
status (
invitedTime (

invitedMsg (	
cardFriends (	

sourceType ("g
CCLSendClubInvitationREQ
clubId (
beInviterId (

sourceType (

invitedMsg (	"E
CLCSendClubInvitationRES
result (
todayInvitedTimes ("L
CCLClubInvitationResultREQ
clubId (
opType (
areaId ("†
CLCClubInvitationResultRES
result (
unprocessedCount (H

invitation (24.com.kodgames.message.proto.club.InvitationInfoProto
opType ("S
CLGGetRoleInfoREQ
purpose (
roleIds (
clubId (
area ("ó
GCLGetRoleInfoRES
result (
purpose (
roleIds (@
	roleInfos (2-.com.kodgames.message.proto.club.ClubRoleInfo
clubId ("c
ClubRoleInfo
roleId (
roleName (	
roleIcon (	
	gameCount (
area ("¬
GIRoleLoginSYN
roleId (
channel (	
name (	
icon (	
	gameCount (
area (
unionId (	
registerTime (
phone	 (	
isRealNameAuth
 (
headFrameId (
	newPlayer (

libVersion (	H
activityInfo (22.com.kodgames.message.proto.club.ActivityInfoPROTO"C
ActivityInfoPROTO

id (
	startTime (
endTime ("“
ICLRoleLoginSYN
roleId (
channel (	
name (	
icon (	
	gameCount (
area (
unionId (	
registerTime (
phone	 (	
isRealNameAuth
 (
headFrameId ("e
CLClubSubCardREQ
clubId (
	managerId (
roomId (
card (
leagueId ("‡
DataUserInfo
clubCardCount (
normalInvitedCount (
recommandInvitedCount (
invitationVersion (
recommandInvitedVersion (
title (
isInWhiteList (
offlineInvtiedSwitch ("æ
DataClubInfo
clubId (
clubName (	
clubIcon (	
clubApplicationCount (
clubApplicationVersion (
clubTaskVersion (
completedTaskCount (
	isManager (
clubCardCount	 (J
clubTableList
 (23.com.kodgames.message.proto.club.ClubTableInfoPROTOG
banGameplays (21.com.kodgames.message.proto.club.BanGameplayPROTO
assistantIds (

clubNotice (	
redPacketVersion (
switches (M
presetGameplays (24.com.kodgames.message.proto.club.PresetGameplayProto
	managerId (
leagueId ("ß
CLCClubDataSYN

notifyType (?
userInfo (2-.com.kodgames.message.proto.club.DataUserInfo@
	clubDatas (2-.com.kodgames.message.proto.club.DataClubInfo"J
BCLCheckWatchRoomREQ
roleId (
roomId (

roomClubId ("Z
CLBCheckWatchRoomRES
result (
roleId (
roomId (

roomClubId ("E
CCLDestroyRoomREQ
roomId (
clubId (
leagueId ("ë
CLCDestroyRoomRES
result (
clubId (J
clubTableList (23.com.kodgames.message.proto.club.ClubTableInfoPROTO
leagueId ("§
CLGDestroyRoomSYN
roomId (
clubId (
destroyerId (
destroyerName (	
leagueId (
destroyReason (
destroyDescription (	"7
CCLFocusOnRoomListREQ
clubId (
optype ("s
CLCFocusOnRoomListRES
result (J
clubTableList (23.com.kodgames.message.proto.club.ClubTableInfoPROTO"U
CLGAddClubCardNotify
agencyId (
clubManagerId (
purchaseTime ("j
CLClubNotifyREQ
clubId (

notifyType (
	managerId (
roleIds (
logFlag ("Q
CLGRoleClubInfoModifySYN
roleId (
clubManagerId (
isJoin ("ﬂ
ClubTaskInfoPROTO
taskId (
taskType (
taskSchedule (
taskCondition (
	gainTimes (
canGainTimes (
	taskTitle (	
taskDescription (	

isAutoGain	 (

isRepeated
 (")
CCLQueryClubTaskListREQ
clubId ("¿
CLCQueryClubTaskListRES
result (H
userTaskList (22.com.kodgames.message.proto.club.ClubTaskInfoPROTOK
managerTaskList (22.com.kodgames.message.proto.club.ClubTaskInfoPROTO"8
CCLObtainTaskRewardREQ
clubId (
taskId ("n
CLCObtainTaskRewardRES
result (D
taskInfo (22.com.kodgames.message.proto.club.ClubTaskInfoPROTO"6
CCLCreateClubREQ
clubName (	
clubIcon (	"2
CLCCreateClubRES
result (
clubId (""
CCLRemoveClubREQ
clubId (""
CLCRemoveClubRES
result ("J
CCLModifyMemberTitleREQ
clubId (
memberId (
title (")
CLCModifyMemberTitleRES
result ("u
OperationRecordPROTO
roleId (
title (
name (	
type (
	timestamp (
content (	",
CCLQueryOperationRecordREQ
clubId ("w
CLCQueryOperationRecordRES
result (I

recordList (25.com.kodgames.message.proto.club.OperationRecordPROTO"w
XCLCheckOperationRightREQ
clubId (
roleId (
operationType (
purpose (

jsonString (	"ª
CLXCheckOperationRightRES
result (
clubId (
roleId (
purpose (
hasRight (

jsonString (	
area (
	isManager (
groupMemberIds	 ("g
CLAgtCreateClubREQ
	managerId (
agentId (
area (
clubName (	
seqId ("C
CLAgtCreateClubRES
result (
clubId (
seqId ("j
GCLBattleStartSYN
clubId (
roomId (

roundCount (
roleIds (
leagueId ("8
CCLModifyClubNoticeREQ
clubId (
notice (	"(
CLCModifyClubNoticeRES
result ("å
ClubRedPacketPROTO

id (
type (	
status (
totalAmount (

gainAmount (

expiryDate (
title1 (	
title2 (	

totalCount	 (
remainCount
 (
luckyRoleName (	
luckyRoleGainAmount (

rewardType (	"*
CCLQueryRedPacketListREQ
clubId ("è
CLCQueryRedPacketListRES
result (
todayTotalMoney (J
redPacketList (23.com.kodgames.message.proto.club.ClubRedPacketPROTO">
CCLGainClubRedPacketREQ
clubId (
redPacketId ("ä
CLCGainClubRedPacketRES
result (
todayTotalMoney (F
	redPacket (23.com.kodgames.message.proto.club.ClubRedPacketPROTO"J
CLGSendWeiXinRedPacketSYN
clubId (
roleId (
money ("4
CLGSendLotterySYN
roleId (
lottery ("<
CCLQueryClubLotteryInfoREQ
clubId (
areaId ("ä
CLCQueryClubLotteryInfoRES
result (

awardCount (
lotteryCount (
	startTime (
endTime (
itemId ("3
CCLDrawLotteryREQ
clubId (
areaId ("s
CLCDrawLotteryRES
result (
	isLottery (

awardCount (
lotteryCount (
	awardCard (":
CLGAddActivityGoodsSYN
roleId (
rewardId ("W
CCLManagerFeedbackREQ
clubId (
sex (
ageGroup (
content (	":
CLCManagerFeedbackRES
result (
	awardCard ("Q
CCLModifyClubSwitchREQ
clubId (

switchType (
switchValue ("(
CLCModifyClubSwitchRES
result ("*
CCLQueryReleaseStatusREQ
areaId ("ô
CLCQueryReleaseStatusRES
result (

checkTimes (
invitedTimes (
releaseTime (
isInRecommandList (
isFirstTime ("X
CCLReleaseRecommandInfoREQ
areaId (

releaseMsg (	
releaseMsgType (",
CLCReleaseRecommandInfoRES
result ("+
CCLCancelRecommandInfoREQ
areaId ("@
CLCCancelRecommandInfoRES
result (
releaseTime ("ê
RecommandInfoProto
roleId (
roleName (	
roleIcon (	
registerTime (
todayRoomCount (
sevenDayRoomCount (
abnormalRate (

releaseMsg (	
invitedTime	 (
processedTime
 (

checkTimes (
cardFriends (	"c
CCLQueryRecommendPlayerListREQ
areaId (
clubId (
opType (
	managerId ("Â
CLCQueryRecommendPlayerListRES
result (
todayInvitedTimes (
unprocessedCount (
todayAcceptTimes (
maxInvitedTimes (K
recommandInfos (23.com.kodgames.message.proto.club.RecommandInfoProto"b
PrivatePlayerInfoProto
roleId (
roleName (	
roleIcon (	
lastRoomTime (".
CCLQueryPrivatePlayerListREQ
clubId ("·
CLCQueryPrivatePlayerListRES
result (V
allPrivatePlayerInfos (27.com.kodgames.message.proto.club.PrivatePlayerInfoProtoY
recentPrivatePlayerInfos (27.com.kodgames.message.proto.club.PrivatePlayerInfoProto"o
PresetGameplayProto
index (
roomType (
	roundType (
	gameplays (
	isInvalid ("è
CCLModifyClubPresetGameplaysREQ
clubId (
opType (L
presetGameplay (24.com.kodgames.message.proto.club.PresetGameplayProto"Ä
CLCModifyClubPresetGameplaysRES
result (M
presetGameplays (24.com.kodgames.message.proto.club.PresetGameplayProto"H
ClubAnnouncementProto
title (	
content (	
picture (	"-
CCLQueryClubAnnouncementREQ
clubId ("÷
CLCQueryClubAnnouncementRES
result (R
normalAnnouncement (26.com.kodgames.message.proto.club.ClubAnnouncementProtoS
managerAnnouncement (26.com.kodgames.message.proto.club.ClubAnnouncementProto"ˇ
ManagerActivityProto

id (	
title (	
type (
status (
	startTime (
endTime (D
selfRank (22.com.kodgames.message.proto.club.RoleRankInfoProtoD
rankList (22.com.kodgames.message.proto.club.RoleRankInfoProto"Q
RoleRankInfoProto
roleId (
roleName (	
data (
rank ("G
CCLQueryManagerActivityListREQ
clubId (
rankListCount ("}
CLCQueryManagerActivityListRES
result (K
acitivtyList (25.com.kodgames.message.proto.club.ManagerActivityProto"Å
CCLAddManagerActivityREQ
clubId (
title (	
type (
	startTime (
endTime (
minRoomCount ("*
CLCAddManagerActivityRES
result ("P
CCLCloseManagerActivityREQ
clubId (
optype (

activityId (	",
CLCCloseManagerActivityRES
result ("J
CCLModifyMemberRemarkREQ
clubId (
roleId (
remark (	"*
CLCModifyMemberRemarkRES
result (")
CCLQueryTreasureInfoREQ
opType ("…
CLCQueryTreasureInfoRES
result (
period (
reward (
catcher (
currentCatcher (
	myCatcher (
partakeNumber (
purchaseCount (
luckyManager	 (	">
CCLPurchaseCatcherREQ
clubId (
purchaseCount (">
CLCPurchaseCatcherRES
result (
purchaseCount ("á
TreasureRewardPROTO
period (
winTime (
rewardLevel (
rewardNumber (

winnerName (	
costCard ("*
CCLTreasureRewardInfoREQ
areaId ("q
CLCTreasureRewardInfoRES
result (E
rewards (24.com.kodgames.message.proto.club.TreasureRewardPROTO"ì
CLCTreasureInfoSYN
period (
	myCatcher (
currentCatcher (
partakeNumber (
highestVersion (
roleVersion ("N
CLSendTreasureRewardREQ
winnerId (
period (
	awardCard ("A
ICLBindPhoneSYN
roleId (
phone (	
roleIds ("`
CLDistributeTaskRewardREQ
clubId (
	managerId (
taskId (
memberId ("J
GCLIdentityVerifySYN
roleId (
realName (	
identity (	"Å
GCLCheckCreateCampaignREQ
roleId (
campaignConfigId (
name (	
time (
dimand (
clubId ("ë
CLGCheckCreateCampaignRES
roleId (
campaignConfigId (
name (	
time (
dimand (
clubId (
result ("6
GCLHeadFrameSYN
roleId (
headFrameId (".
	ItemProto
itemId (
	itemCount ("π
SSRoleFirstChargedSYN
roleId (

chargeType (
chargeCount (

chargeTime (
chargeItemId (=
	itemInfos (2*.com.kodgames.message.proto.club.ItemProto"Ö
ClubStatisticsProto
	timeStamp (
loginRoleCount (
playRoleCount (
	roomCount (
abnormalRoomCount ("+
CCLQueryStatisticsInfoREQ
clubId ("z
CLCQueryStatisticsInfoRES
result (M
statisticsInfos (24.com.kodgames.message.proto.club.ClubStatisticsProto"\
MemberRankInfoProto
roleId (
roleName (	
roleIcon (	
	rankDatas ("v
CCLQueryMemberRankInfoREQ
clubId (
rankType (
	startTime (
endTime (
winnerScore ("Œ
CLCQueryMemberRankInfoRES
result (
rankType (
winnerScore (
overWinnerCount (
totalWinnerCount (G
	rankInfos (24.com.kodgames.message.proto.club.MemberRankInfoProto"˘
RoomInvitedMemberInfoProto
roleId (
roleName (	
roleIcon (	
roleHeadFrame (
status (
right (
playGameCount (
joinTime (
canInvitedTime	 (
remainInvitedTimes
 (
canBeInvited ("?
CCLQueryRoomInvitedMembersREQ
clubId (
roomId ("Å
CLCQueryRoomInvitedMembersRES
result (P
memberInfos (2;.com.kodgames.message.proto.club.RoomInvitedMemberInfoProto"d
CCLSendRoomInvitationREQ
clubId (
roomId (
	inviteeId (
gameplaysDesc (	"Ç
CLCSendRoomInvitationRES
result (V
inviteeMemberInfo (2;.com.kodgames.message.proto.club.RoomInvitedMemberInfoProto"À
CLCNotifyRoomInvitaitonSYN
clubId (
clubName (	
	inviterId (
inviterName (	
inviterIcon (	
inviterHeadFrame (
roomId (
	roundType (
	gamePlays	 ("@
SSRoleGameStatusChangedSYN
roleId (

isInGaming ("’
ClubGroupProto
groupId (	
	groupName (	
leaderId (

leaderName (	

createTime (
memberCount (
minWinScore (
	roomCount (
winnerCount	 (
bigWinCount
 ("N
CCLQueryClubGroupListREQ
clubId (
	startTime (
endTime ("∫
CLCQueryClubGroupListRES
result (
totalRoomCount (
totalWinnerCount (
totalBigWinCount (B
	groupList (2/.com.kodgames.message.proto.club.ClubGroupProto"_
CCLCheckCreateGroupREQ
clubId (
	groupName (	
leaderId (
minScore ("P
CLCCheckCreateGroupRES
result (

leaderName (	

leaderIcon (	"^
CCLCreateClubGroupREQ
clubId (
	groupName (	
leaderId (
minScore ("'
CLCCreateClubGroupRES
result ("8
CCLDeleteClubGroupREQ
clubId (
groupId (	"ä
CLDeleteClubGroupREQ
clubId (
groupId (	
roleId (
callback (
groupMemberIds (
importedClubIds ("'
CLCDeleteClubGroupRES
result ("c
CCLModifyClubGroupREQ
clubId (
groupId (	
	groupName (	
minWinnerScore ("'
CLCModifyClubGroupRES
result ("7
CCLQueryGroupInfoREQ
clubId (
groupId (	"ç
CLCQueryGroupInfoRES
result (
leaderId (

leaderName (	
memberCount (
minWinnerScore (

createTime ("ë
GroupMemberProto
roleId (
roleName (	
roleIcon (	
title (
right (
winCount (
	roomCount (
bigWinCount (
totalWinCount	 (
todayWinCount
 (
yesterdayWinCount (
sevendayWinCount (
totalRoomCount (
todayRoomCount (
yesterdayRoomCount (
sevendayRoomCount (
joinTimestamp (
isLeader ("^
CCLQueryGroupMembersREQ
clubId (
groupId (	
	startTime (
endTime ("∫
CLCQueryGroupMembersRES
result (
totalWinCount (
totalRoomCount (
totalBigWinCount (F
memberInfos (21.com.kodgames.message.proto.club.GroupMemberProto"h
ImportClubInfoProto
clubId (
clubName (	
clubMemberCount (
importRoleList ("O
CCLQueryImportClubInfoREQ
clubId (
leaderId (
leagueId ("z
CLCQueryImportClubInfoRES
result (M
importClubInfos (24.com.kodgames.message.proto.club.ImportClubInfoProto"Ä
CCLImportGroupMemberREQ
groupId (	
leagueId (
targetClubId (
sourceClubId (
importRoleList ("@
CLCImportGroupMemberRES
result (
unImportCount ("à
MemberInfoForGroupProto
roleId (
roleName (	
roleIcon (	
groupId (	
	groupName (	
isGroupLeader ("0
CCLQueryMemberInfosForGroupREQ
clubId ("
CLCQueryMemberInfosForGroupRES
result (M
memberInfos (28.com.kodgames.message.proto.club.MemberInfoForGroupProto"\
CCLModifyGroupMemberREQ
clubId (
opType (
memberId (
groupId (	")
CLCModifyGroupMemberRES
result ("
CCLQueryFirstCreateAwardREQ"@
CLCQueryFirstCreateAwardRES
result (
	awardCard ("_
WXClubApplicantProto
clubId (
	inviterId (
	shareType (
	shareTime ("{
GCLSendWXClubApplicantSYN
applicantId (I

applicants (25.com.kodgames.message.proto.club.WXClubApplicantProto"p
CCLSendRoomInvitedResultREQ
clubId (
roomId (
opType (
areaId (
	inviterId ("-
CLCSendRoomInvitedResultRES
result ("G
BCLCheckActingRoomREQ
roleId (
roomId (
clubId ("G
CLBCheckActingRoomRES
result (
roleId (
roomId ("Q
SCLModifyClubCardSYN
roleId (
	cardCount (
itemModifyType ("£
ClubRankInfoProto
clubId (
clubName (	
clubIcon (	
rank (
score (
memberReward (	
managerReward (	
rankType (")
CCLQueryClubRankListREQ
opType ("É
CLCQueryClubRankListRES
result (
	startTime (
endTime (

rewardRank (
maxRank (E
	rankInfos (22.com.kodgames.message.proto.club.ClubRankInfoProtoH
selfRankInfo (22.com.kodgames.message.proto.club.ClubRankInfoProto";
CCLQueryClubRankInfoREQ
clubId (
rankType ("§
CLCQueryClubRankInfoRES
result (
clubId (
clubName (	
clubIcon (	
yesterdayRank (
yesterdayScore (
myContribution ("¨
ClubRankRewardProto
time (
clubId (
clubName (	
rank (
score (
reward (	
status (
rankType (
needManualSend	 ("+
CCLQueryRankRewardListREQ
opType ("y
CLCQueryRankRewardListRES
result (L
rankRewardList (24.com.kodgames.message.proto.club.ClubRankRewardProto"L
CCLPickClubRankRewardREQ
clubId (
opType (
rankType (":
CLCPickClubRankRewardRES
result (
status ("
CLUpdateVirtualClubRankREQ"
CLClubRankRewardBiLogREQ"8
 CCLUpdateOfflineInvitedSwitchREQ
switchStatus ("2
 CLCUpdateOfflineInvitedSwitchRES
result ("
CCLQueryClubInfosREQ"&
CLCQueryClubInfosRES
result ("7
GCLAdvanceGameWaitSYN
clubId (
roomId ("5
CCLQueryLeagueREQ
leagueId (
clubId ("Ó
CLCQueryLeagueRES
result (
leagueId (

leagueName (	
clubCard (
currentScore (	
myScore (	
leaderId (
show (
title	 (
	fireScore
 (	
partnerNumber (
	partnerId ("è
LeagueGameplayPROTO

id (
name (	
joinThreshold (
scoreCoefficient (
winnerThreshold (
lotteryCost (

lotteryMin (

lotteryMax (
roomType	 (
	roundType
 (
finishScore (
	gameplays (

modifyTime (
canNegative (N
lotteryProperty (25.com.kodgames.message.proto.club.LotteryPropertyPROTO
	playCount ("ª
LotteryPropertyPROTO

startScore (
endScore (
lotteryCost (
clubFireScore (
partnerFireScore (
maxClubFireScore (
leaderGetMinFireScore ("Ö
CCLQueryLeagueGameplayREQ
leagueId (
clubId (
	partnerId (
removeZeroCost (
title (
type ("‹
CLCQueryLeagueGameplayRES
result (G
	gameplays (24.com.kodgames.message.proto.club.LeagueGameplayPROTO
	isOpenGPS (
leagueId (
clubId (
removeZeroCost (
maxGameplayRegion ("Ç
CCLModifyLeagueGameplayREQ
leagueId (

id (F
gameplay (24.com.kodgames.message.proto.club.LeagueGameplayPROTO"8
CLCModifyLeagueGameplayRES
result (

id (":
CCLDeleteLeagueGameplayREQ
leagueId (

id (",
CLCDeleteLeagueGameplayRES
result ("±
!CCLModifyGamePlayClubFireScoreREQ
leagueId (
clubId (

gameplayId (

startScore (
endScore (
changeClubFireScore (
playerCount ("À
!CLCModifyGamePlayClubFireScoreRES
leagueId (
clubId (
result (G
	gameplays (24.com.kodgames.message.proto.club.LeagueGameplayPROTO
removeZeroCost (
playerCount ("≤
$CCLModifyGamePlayPartnerFireScoreREQ
leagueId (
clubId (
	partnerId (

gameplayId (

startScore (
endScore (
changeClubFireScore ("6
$CLCModifyGamePlayPartnerFireScoreRES
result ("‚
LeagueRankPROTO
clubId (
clubName (	
managerName (	
allScore (	
winScore (	
fireScoreRate (	
	fireScore (	
memberCount (
	roomCount	 (
lotteryCount
 (
like ("\
ClubMemberRankPROTO
roleId (
name (	
	roomCount (
lotteryCount ("]
CCLQueryLeagueRankREQ
leagueId (
clubId (
operatorType (
date ("ò
CLCQueryLeagueRankRES
result (
allInitialScore (	
allCurrentScore (	
allLotteryScore (	
allFireScore (	C
	clubRanks (20.com.kodgames.message.proto.club.LeagueRankPROTOI
memberRanks (24.com.kodgames.message.proto.club.ClubMemberRankPROTO"O
CCLClickLikeREQ
leagueId (
clubId (
date (
like ("!
CLCClickLikeRES
result ("Ω
LeagueClubPROTO
clubId (
clubName (	
managerName (	
memberCount (
currentScore (	
fireScoreRate (	
status (
remark (	
	managerId	 ("&
CCLQueryLeaguesREQ
leagueId ("g
CLCQueryLeaguesRES
result (A
leagues (20.com.kodgames.message.proto.club.LeagueClubPROTO"s
CCLModifyLeagueREQ
leagueId (
clubId (
currentScore (
fireScoreRate (
remark (	":
CLCModifyLeagueRES
result (
currentScore (	"3
CCLPauseGameREQ
leagueId (
clubId ("!
CLCPauseGameRES
result ("5
CCLRestoreGameREQ
leagueId (
clubId ("#
CLCRestoreGameRES
result ("7
CCLForceQuitGameREQ
leagueId (
clubId ("%
CLCForceQuitGameRES
result ("<
LeagueTrendPROTO
time (
type (
data (	"C
CCLQueryTrendREQ
leagueId (
clubId (
title ("e
CLCQueryTrendRES
result (A
trends (21.com.kodgames.message.proto.club.LeagueTrendPROTO"ñ
LeagueApprovalPROTO
clubId (
clubName (	
clubIcon (	
	managerId (
managerName (	
memberCount (
status ("'
CCLQueryApprovalREQ
leagueId ("n
CLCQueryApprovalRES
result (G
	approvals (24.com.kodgames.message.proto.club.LeagueApprovalPROTO"A
CCLApprovalREQ
leagueId (
clubId (
agree (" 
CLCApprovalRES
result ("8
CCLModifyLeagueNameREQ
leagueId (
name (	"(
CLCModifyLeagueNameRES
result ("6
CCLShowStartTableREQ
leagueId (
show ("&
CLCShowStartTableRES
result (")
CCLQueryLeagueNameREQ
leagueId (";
CLCQueryLeagueNameRES
result (

leagueName (	"9
CCLQueryJoinLeagueREQ
leagueId (
clubId ("]
CLCQueryJoinLeagueRES
result (
conflictClubName (	
conflictLeagueName (	"à
LeagueMemberPROTO
roleId (
nickname (	
headUrl (	
headFrameId (
status (
	roomCount (
	gameScore (	
initialScore (	
remark	 (	
yesterdayRoomCount
 (
yesterdayLotteryCount (
allRoomCount (
allLotteryCount (
isRealNameAuth (
joinClubTime (
isPauseGame (
title (
memberCount ("t
CCLQueryMembersREQ
leagueId (
clubId (
days (
type (
title (
	partnerId ("
CLCQueryMembersRES
result (
currentScore (	C
members (22.com.kodgames.message.proto.club.LeagueMemberPROTO"h
CCLModifyMemberScoreREQ
leagueId (
clubId (
roleId (
type (
score ("T
CLCModifyMemberScoreRES
result (
currentScore (	
memberScore (	"f
CCLPauseMemberGameREQ
leagueId (
clubId (
roleId (
type (
pause ("'
CLCPauseMemberGameRES
result ("t
CCLCreateLeagueRoomREQ
leagueId (
leaderId (
clubId (

gameplayId (

createType ("J
CLCCreateLeagueRoomRES
result (
roomId (
battleId ("¢
LeagueRoomIndexProto
roomId (

createTime (
	maxPlayer (
playerCount (
hasStartBattle (

gamePlayId (

modifyTime (";
CCLFocusOnLeagueRoomREQ
leagueId (
optype ("t
CLCFocusOnLeagueRoomRES
result (I

roomIndexs (25.com.kodgames.message.proto.club.LeagueRoomIndexProto"´
LeagueTableInfoPROTO
roomId (
	playerMax (
createTimestamp (
	isRemoved (
hasStartBattle (
finishRoundCount (F
gameplay (24.com.kodgames.message.proto.club.LeagueGameplayPROTOJ
players	 (29.com.kodgames.message.proto.club.ClubTablePlayerInfoPROTO"u
CLCNotifyLeagueRoomSYN
leagueId (I

tableInfos (25.com.kodgames.message.proto.club.LeagueTableInfoPROTO";
CCLQueryRoomDetailsREQ
leagueId (
roomIds ("s
CLCQueryRoomDetailsRES
result (I

tableInfos (25.com.kodgames.message.proto.club.LeagueTableInfoPROTO"i
CLCLeagueInfoSYN
type (
leagueId (
haveApproval (
myScore (	
clubId ("[
CCLQueryLeagueScoreREQ
leagueId (
clubId (
	partnerId (
type ("¢
CLCQueryLeagueScoreRES
result (
currentScore (	
	fireScore (	
allScore (	
	managerId (
managerName (	
fireScoreRate (	"ñ
LeagueScoreRecordPROTO
time (

id (
name (	
type (
score (	

afterScore (	
remainScore (	
roomId ("ù
CCLQueryScoreRecordREQ
leagueId (
clubId (
	partnerId (
roleId (
type (
	scoreType (
date (
endDate ("°
CLCQueryScoreRecordRES
result (G
record (27.com.kodgames.message.proto.club.LeagueScoreRecordPROTO
getFireScore (
convertFireScore ("y
LeagueClubRecordPROTO
clubId (
clubName (	
roleId (
roleName (	
score (	
title ("m
CCLQueryClubRecordREQ
leagueId (
clubId (
	partnerId (
type (
	queryType ("p
CLCQueryClubRecordRES
result (G
records (26.com.kodgames.message.proto.club.LeagueClubRecordPROTO"L
CCLConversionScoreREQ
leagueId (
clubId (
	partnerId (";
CLCConversionScoreRES
result (

afterScore (	"8
CCLQueryFireScoreREQ
leagueId (
clubId ("9
CLCQueryFireScoreRES
result (
	fireScore (	"6
"CCLQueryLeagueMatchActivityInfoREQ
leagueId ("ï
"CLCQueryLeagueMatchActivityInfoRES
leagueId (M
record (2=.com.kodgames.message.proto.club.LeagueMatchActivityInfoPROTO
result ("û
LeagueMatchActivityInfoPROTO
date (
memberCount (
fireMemberCount (
playMemberCount (
cardCost (
leagueFireScore ("S
!CCLQueryLeagueClubActivityInfoREQ
date (
leagueId (
clubId ("…
!CLCQueryLeagueClubActivityInfoRES
date (
leagueId (
clubId (K
record (2;.com.kodgames.message.proto.club.ClubMatchActivityInfoPROTO
leagueFireScore (
result ("Œ
ClubMatchActivityInfoPROTO
clubId (
clubName (	
	managerId (
managerName (	
clubMemberCount (
playMemberCount (
devoteLeagueFireScore (
clubFireScore ("S
!CCLQueryClubMemberActivityInfoREQ
date (
leagueId (
clubId ("…
!CLCQueryClubMemberActivityInfoRES
date (
leagueId (
clubId (M
record (2=.com.kodgames.message.proto.club.MemberMatchActivityInfoPROTO
clubFireScore (
result ("œ
MemberMatchActivityInfoPROTO
memberId (

memberName (	

matchCount (
winCount (
devoteClubFireScore (
memberHeadUrl (	
memberHeadFrameId (
memberStatus ("@
CCLModifyLeagueGpsRuleREQ
leagueId (
	isOpenGPS ("+
CLCModifyLeagueGpsRuleRES
result ("W
CCLOrderPartnerREQ
leagueId (
clubId (
memberId (
order ("$
CLCOrderPartnerRES
result ("k
CCLModifyPartnerScoreREQ
leagueId (
clubId (
memberId (
type (
score ("U
CLCModifyPartnerScoreRES
result (
currentScore (	
memberScore (	"O
CCLInvitePartnerMemberREQ
leagueId (
clubId (
memberId ("+
CLCInvitePartnerMemberRES
result ("T
CLCLeagueGamePlayInfoSYN
leagueId (

gamePlayId (

modifyTime ("?
CCLQueryGameplayStatisticsREQ
leagueId (
date ("•
CLCQueryGameplayStatisticsRES
leagueId (
date (
result (T
gameplayStatistics (28.com.kodgames.message.proto.club.GameplayStatisticsProto"Õ
GameplayStatisticsProto

id (
name (	
	gameCount (
lotteryGameCount (
lotteryCost (
delete (F
gameplay (24.com.kodgames.message.proto.club.LeagueGameplayPROTOBBClubProtoBuf