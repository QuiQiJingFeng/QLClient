
Ö¶

game.protocom.kodgames.message.proto.game"
GUnusedMessage"C
ActivityInfoPROTO

id (
	startTime (
endTime ("-
GiftInfoPROTO
type (
itemId ("£

CGLoginREQ
roleId (
sex (
nickname (	
headImageUrl (	
	accountId (
channel (	
	signature (	
appCode (
area	 (
developerId
 (	
unionId (	
username (	
	channelId (
type (
phone (	

libVersion (	"ö

GCLoginRES
result (
roomCardCount (
battleId (
roomId (
marqueeVersion (
newMail ("
newLimitedCostlessActivity (
noticeVersion (
buttonValue	 (
	timeStamp
 (
clubId (

createTime (
	connGroup (	
isIdentityVerify (
isAgency (
	agtWebUrl (	
combatId (
area (
mttStartTime (
ticket (
phone (	
notifyRedDot (
pushRegisterId (	
headFrameId (

goldAmount (
goldBeanCount (
isInGoldMatch (
competitionVoucherCount (
lastLastLoginTime (@
giftInfo (2..com.kodgames.message.proto.game.GiftInfoPROTO
isBindDingTalk (
pushClientId  (	
hasPlayFastMode! ("
CGLogoutREQ"
GCLogoutRES
result ("
GCKickoffSYNC
reason ("‘
BGRoomCardModifySYNC
roleId (
roomId (

roundCount (
ipSameCount (
gpsConflictCount (
maxMemberCount ("-
GCRoomCardModifySYNC
roomCardCount ("‡
RoomConfigPROTO
type (

roundCount (
	gameCount (
	cardCount (
tingTipSwitch (
advanceSwitch ("r
GBGameConfigSYN
creatorClassName (	E
roomConfigs (20.com.kodgames.message.proto.game.RoomConfigPROTO"s
GCLGameConfigSYN
creatorClassName (	E
roomConfigs (20.com.kodgames.message.proto.game.RoomConfigPROTO":
GroupPlayerInfoPROTO
groupId (
	itemCount ("Û
VirtualPlayerInfoPROTO
nickname (	

headImgUrl (	
groupId (
scoreMultiple (
battleScoreMax (
	itemCount (H
	groupInfo (25.com.kodgames.message.proto.game.GroupPlayerInfoPROTO"ó
AutoEnterPlayer
roleId (

totalPoint (
rank (
nickname (	
headImageUrl (	
	headFrame (
sex (

isIdentity (R
virtualPlayerInfo	 (27.com.kodgames.message.proto.game.VirtualPlayerInfoPROTO"‰
CGCreateRoomREQ
roomType (
	gameplays (
	roundType (
freeActivityId (

createType (

inviteeIds ("¸
GBCreateRoomREQ
	creatorId (
roomId (

roomClubId (
roomType (
	roundType (

roundCount (
	gameCount (
	gameplays (
clubManagerId
 (

campaignId (J
autoEnterPlayers (20.com.kodgames.message.proto.game.AutoEnterPlayer
multiple (
area (
clubName (	
canEarlyBattle3 (
canEarlyBattle4 (
	isPrivate (
privateRoleIds (
	isVirtual (

createType (

inviteeIds (
banGameplays (
leagueId (

gameplayId (

scoreRatio (" 
BGCreateRoomRES
result (
roomId (

roomClubId (

campaignId (
	creatorId (
	gameplays (
	playerMax (J
autoEnterPlayers (20.com.kodgames.message.proto.game.AutoEnterPlayer
multiple	 (
	isPrivate
 (
privateRoleIds (
roomType (

createType (

inviteeIds (
clubName (	
	creatTime (
leagueId (

gameplayId ("C
GCCreateRoomRES
result (
battleId (
roomId ("$
CGQueryBattleIdREQ
roomId ("[
GCQueryBattleIdRES
result (
battleId (
	gamePlays (
isInRoom ("±
BGEnterRoomSYN
roomId (
roleId (
roleIp (	
status (

createTime (
isBattleStart (

roundCount (
joinType (	
clubId	 ("/
BGQuitRoomSYN
roomId (
roleId ("†
BGDestroyRoomSYN
roomId (
roleList (
reason (

watcherIds (

createTime (
ipConflicts (
gpsConflicts (
roomType (
destroyerId	 (
destroyerName
 (	
destroyTime (
destroyDescription (	"%
GBGmtDestroyRoomSYN
roomId ("q
BattleStatisticsPROTO
totalRoomCount (
positiveRoomCount (
silentRoomCount (
area ("^
BGBattleStatisticsSYNE
proto (26.com.kodgames.message.proto.game.BattleStatisticsPROTO"”
GPlayerHistoryPROTO
roleId (
position (
nickname (	

headImgUrl (	
	headFrame (
sex (

totalPoint (
	delayTime (
totalDelayTime	 (
averageTime
 (
scores (
score (

openAutoHu (
clubId ("
GRoundReportPROTO
playerRecords (
	startTime (
	lastCards (
isHuang (
specialCards (
destroyerId (
endTime ("Ñ
BGMatchResultSYN
roomId (

createTime (K
playerRecords (24.com.kodgames.message.proto.game.GPlayerHistoryPROTO
	roundType (

roundCount (
playerMaxCardCount (M
roundReportRecord (22.com.kodgames.message.proto.game.GRoundReportPROTO
	gameplays (
playbackDatas	 (
enableMutilHu
 (
clubManagerId (
clubId (
gameOverCount (
protocolSeq (
roomType (
openTingTips ("í
BGFinalMatchResultSYN
roomId (

createTime (K
playerRecords (24.com.kodgames.message.proto.game.GPlayerHistoryPROTO
	roundType (
destroyReason (
roomType (

isFastMode (
destroyTime ("
GCAntiAddictionSYN"‡
InviterRoomInfoPROTO
	creatorId (
	gamePlays (
nickname (	
headImageUrl (	
	headFrame (
roomId ("&
CGInviterRoomInfoREQ
roomId ("6
GBInviterRoomInfoREQ
roomId (
roleId ("{
BGInviterRoomInfoRES
result (C
info (25.com.kodgames.message.proto.game.InviterRoomInfoPROTO
roleId ("k
GCInviterRoomInfoRES
result (C
info (25.com.kodgames.message.proto.game.InviterRoomInfoPROTO"
CGTimeSynchronizationREQ"=
GCTimeSynchronizationRES
result (
	timeStamp (";
CGSendPhoneNumberREQ
roleId (
phoneNumber (	"9
GCSendPhoneNumberRES
result (
	validTime ("\
CGSendVerificationCodeREQ
roleId (
phoneNumber (	
verificationNumber (	"+
GCSendVerificationCodeRES
result ("E
CGIdentityVerifyREQ
roleId (
name (	
identity (	"%
GCIdentityVerifyRES
result ("™
BGRoomDestroyBiSYN
roomId (
	creatorId (
roleIds (

createTime (
destroyTime (
maxRoundCount (
realRoundCount (
averageBattleTime (
averageIdleTime	 (
startIdleTime
 (
roomLifeTime (
losePlayerCount (
totalLoseScore (
	gameplays (
destroyReason (
	isPrivate (
isActingCreate (
roomType ("©
GBClubDestroyRoomSYN
roomId (
clubId (
destroyerId (
destroyerName (	
leagueId (
destroyerReason (
destroyDescription (	"0
BGWatchRoomSYN
roomId (
roleId ("4
BGQuitWatchRoomSYN
roomId (
roleId ("
CGGetAgentInfoREQ"@
GCGetAgentInfoRES
result (
sign (	
sTime (""
GCAgentStatusSYN
status ("-
ServerAreaPROTO
area (
name (	"c
GCSelectAreaREQ?
areas (20.com.kodgames.message.proto.game.ServerAreaPROTO
default ("B
CGSelectAreaREQ
area (
appCode (
username (	"/
GCSelectAreaRES
result (
area ("
CGAreaListREQ"P
GCAreaListRES?
areas (20.com.kodgames.message.proto.game.ServerAreaPROTO"5
GBSyncRoleAreaInfoSYN
roleId (
area ("S
CGAccountGpsREQ
roleId (
province (	
city (	
district (	"!
GCAccountGpsRES
result ("*
GBCampaignDestroyRoomSYN
roomId ("º
CGPayOrderREQ
roleId (
payType (
osType (
rmb (
goodId (	

deviceType (
	channelId (
subChannelId (
custom	 (	
itemId
 ("a
GCPayOrderRES
result (
payType (
orderId (	
payUrl (	
domain (	"
GMPayOrderREQ
kodId (	

serverType (
rechargeService (
roleId (
payType (
osType (
rmb (
itemId (	
itemName	 (	
itemDetails
 (	
areaId (

deviceType (
	channelId (
subChannelId (
custom (	"P
MGPayOrderRES
result (
roleId (
orderId (	
payUrl (	"Y
CGPayVerifyREQ
orderId (	
roleId (
transactionId (	
receipt (	"1
GCPayVerifyRES
result (
orderId (	"Y
GMPayVerifyREQ
orderId (	
roleId (
transactionId (	
receipt (	"A
MGPayVerifyRES
result (
roleId (
orderId (	"-
TimePricePROTO
time (
price ("»
GoodsInfoPROTO
goodId (
goodName (	
	goodPrice (
goodInventory (
currentInventory (
exchangeTimes (
alreadyExchanged (
isNeedPhoneNumber (
isNeedAddress	 (
payType
 (
tab (B
	timePrice (2/.com.kodgames.message.proto.game.TimePricePROTO"
	CGMallREQ"n
	GCMallRES
result (
points (A
goodInfo (2/.com.kodgames.message.proto.game.GoodsInfoPROTO"\
	BillPROTO
exchangeTime (
	goodPrice (
exchangeReason (	
status ("
CGMallBillREQ"”
GCMallBillRES
result (:
income (2*.com.kodgames.message.proto.game.BillPROTO7
pay (2*.com.kodgames.message.proto.game.BillPROTO"k
CGQueryExchangeREQ
goodId (
phoneNumber (	
	addressee (	
address (	
time ("3
GCQueryExchangeRES
result (
price ("
GCRefreshGoodsSYN"”
BGBattleStartSYN
clubId (
roomId (

roundCount (

createTime (
isEarlyBattle (
roleIds (
roomType ("¤
Goods
goodUID (	
time (
goods (	
image (	
order (	
status (
phone (	
name (	
address	 (	
	logistics
 (	"!
CGQueryGoodsREQ
roleId ("L
GCQueryGoodsRES9
	goodsList (2&.com.kodgames.message.proto.game.Goods"`
CGApplyGoodsREQ
roleId (
goodUID (	
name (	
phone (	
address (	"!
GCApplyGoodsRES
result ("$
GCTicketModifySYNC
ticket ("`
IGBindPhoneSYN
roleId (
type (
phone (	
oldPhone (	
roleIds (""
GCNotifyRedDotSYNC
type ("+
RewardCostData

id (
count ("˜
	MailPROTO

id (	
title (	
content (	
sendTime (
status (=
item (2/.com.kodgames.message.proto.game.RewardCostData"
CGReceiveItemREQ

id (	""
GCReceiveItemRES
result ("
CGQueryMailREQ"[
GCQueryMailRES
result (9
mails (2*.com.kodgames.message.proto.game.MailPROTO".
CGChangeMailREQ

id (	
operate ("!
GCChangeMailRES
result ("
CGDeleteReadMailsREQ"&
GCDeleteReadMailsRES
result ("-
GGSendTimeMailREQ

id (
time ("É
SGSendMailSYN
area (
title (	
content (	
sendTime (
	timeLimit (

targetType (
	receivers (	>
items (2/.com.kodgames.message.proto.game.RewardCostData"w
AnnouncementPROTO

id (	
title (	
content (	

pictureUrl (	
	startTime (
endTime ("
CGQueryAnnouncementREQ"r
GCQueryAnnouncementRES
result (H
announcement (22.com.kodgames.message.proto.game.AnnouncementPROTO"§
ActivityPROTO

id (	
title (	

pictureUrl (	

skipTarget (
	startTime (
endTime (
status (
level (
sendTime	 ("
CGQueryActivityREQ"w
GCQueryActivityRES
result (B

activities (2..com.kodgames.message.proto.game.ActivityPROTO
times ("
CGReadActivityREQ

id (	"#
GCReadActivityRES
result ("¸
SGSendActivitySYN
area (
title (	
picture (	
skip (
	startTime (
endTime (

targetType (
	receivers (	
level	 (
times
 ("!
BGStopBattleSYN
canUse ("4
RoomToRoleIdPROTO
roomId (
roleIds ("X
BGRemainderRoomsSYNA
rooms (22.com.kodgames.message.proto.game.RoomToRoleIdPROTO"!
CGQueryAgtInfoREQ
area ("Y
GCQueryAgtInfoRES
result (
weChat (	
sowingMapUrl (	
status ("
CGGetAgtWebUrlREQ"0
GCGetAgtWebUrlRES
result (
url (	"A
GGChangeBillREQ
billId (
status (
roleId ("r
TurntableRewardPROTO

activityId (
rewardId (
gainTime (

rewardDesc (	
itemId ("
CGQueryTurntableInfoREQ"×
GCQueryTurntableInfoRES
result (
	itemCount (F
rewards (25.com.kodgames.message.proto.game.TurntableRewardPROTO
lastRewardInfo (	9
	goodsList (2&.com.kodgames.message.proto.game.Goods"
CGTurntableDrawREQ"–
GCTurntableDrawRES
result (
	itemCount (E
reward (25.com.kodgames.message.proto.game.TurntableRewardPROTO
lastRewardInfo (	"
GCPlayerHasItemCountSYN"
CGShareTurntableRewardREQ">
CGShareTurntableRewardRES
result (
	itemCount ("f
CGUploadPushInfoREQ
roleId (
	channelId (
pushRegisterId (	
pushClientId (	"%
GCUploadPushInfoRES
result (";
CGUploadRolePushTypeREQ
roleId (
pushType (")
GCUploadRolePushTypeRES
result ("{
Consume

id (
uid (	
count (
content (	

createTime (
destroyTime (
status ("
CGQueryRoleItemsREQ"M
GCQueryRoleItemsRES6
item (2(.com.kodgames.message.proto.game.Consume"3
GCNotifyItemsChangeSYN

id (
count ("2
HeadFramePricePROTO
time (
price ("›
HeadFramePROTO

id (
name (	
type (
isLock (
desc (	C
price (24.com.kodgames.message.proto.game.HeadFramePricePROTO"#
CGQueryHeadFrameREQ
area ("½
GCQueryHeadFrameRES
result (
currency (@
roleHeadFrames (2(.com.kodgames.message.proto.game.ConsumeB
	headFrame (2/.com.kodgames.message.proto.game.HeadFramePROTO"@
CGPurchaseHeadFrameREQ
area (

id (
time ("(
GCPurchaseHeadFrameRES
result (""
CGSwitchHeadFrameREQ

id ("&
GCSwitchHeadFrameRES
result ("O
	ItemPROTO
	operation (

id (
count (
updateReason ("I
SCItemInfoSYN8
item (2*.com.kodgames.message.proto.game.ItemPROTO"Y
SSItemInfoSYN
roleId (8
item (2*.com.kodgames.message.proto.game.ItemPROTO"h
GoldMatchResultPROTO
roleId (

totalPoint (
goldCoinCount (
goldBeanCount ("­
GGoldMatchResultSYNF
matchResult (21.com.kodgames.message.proto.game.BGMatchResultSYNN
goldMatchResult (25.com.kodgames.message.proto.game.GoldMatchResultPROTO"
HomePageNoticeProto
title (	
content (	
priority (
jumpType (
	startTime (
endTime (
sendTime ("*
CGQueryHomePageNoticeREQ
areaId ("q
GCQueryHomePageNoticeRES
result (E
notices (24.com.kodgames.message.proto.game.HomePageNoticeProto"G
IGQueryPlayerInfoREQ
	oldRoleId (
sign (	
result ("i
GCQueryPlayerInfoRES
result (
	oldRoleId (
oldName (	
cardNum (
sign (	"?
GCLSendQuestionnaireRewardSYN
roleId (
reward ("9
CGAccusePlayerREQ
mailAddress (	
content (	"#
GCAccusePlayerRES
result ("-
PushMessage
title (	
content (	"{
PushParameter

id (
day (
	timeOfDay (	>
messages (2,.com.kodgames.message.proto.game.PushMessage"X
GCPushParameterSYNB

parameters (2..com.kodgames.message.proto.game.PushParameter")
CGQueryH5AccessTokenREQ
appkey (	";
GCQueryH5AccessTokenRES
result (
loginUrl (	"&
CGQueryH5PayUrlREQ
prepayId (	"F
GCQueryH5PayUrlRES
result (
payUrl (	
toPayUrl (	"6
CGUploadH5BIREQ
accessToken (	
biInfo (	"!
GCUploadH5BIRES
result (".
ExchangePROTO
itemId (
count (""
CGReceiveGiftREQ
itemId ("d
GCReceiveGiftRES
result (@
exchange (2..com.kodgames.message.proto.game.ExchangePROTO"1
GBRemovePlayerSYN
room (
roleId ("4
IGBindDingTalkSYN
roleId (
roleIds ("0
CGApplyToAgtREQ
phone (	
weChat (	">
GCApplyToAgtRES
result (
sign (	
sTime ("~
FriendInfoProto
roleId (
roleName (	
roleIcon (	
headFrameId (

createTime (
status ("
CGQueryFriendListREQ"l
GCQueryFriendListRES
result (D

friendList (20.com.kodgames.message.proto.game.FriendInfoProto"9
GUpdateFriendInfoREQ
roleId (
	friendIds ("-
CGDeleteFriendInfoREQ
deleteRoleId ("'
GCDeleteFriendInfoRES
result ("c
FriendRecommendProto
roleId (
roleName (	
roleIcon (	
recommendReason ("
CGQueryFriendRecommendListREQ"}
GCQueryFriendRecommendListRES
result (L
recommendList (25.com.kodgames.message.proto.game.FriendRecommendProto"]
FriendApplicantProto
roleId (
roleName (	
roleIcon (	
	applyTime ("
CGQueryFriendApplicantListREQ"}
GCQueryFriendApplicantListRES
result (L
applicantList (25.com.kodgames.message.proto.game.FriendApplicantProto"'
CGSearchRoleInfoREQ
searchId ("Y
GCSearchRoleInfoRES
result (
roleId (
roleName (	
roleIcon (	"C
CGSendFriendApplicantREQ
recipientId (

sourceType ("*
GCSendFriendApplicantRES
result ("A
CGHandleFriendApplicantREQ
opType (
applicantId (",
GCHandleFriendApplicantRES
result ("Ö
RoomInvitedFriendInfoProto
roleId (
roleName (	
roleIcon (	
roleHeadFrame (
status (

createTime (
playGameCount (
canInvitedTime (
remainInvitedTimes	 ("2
 CGQueryRoomInvitedFriendInfosREQ
roomId ("„
 GCQueryRoomInvitedFriendInfosRES
result (P
friendInfos (2;.com.kodgames.message.proto.game.RoomInvitedFriendInfoProto"<
CGSendRoomInvitationREQ
roomId (
	inviteeId ("z
GCSendRoomInvitationRES
result (O

friendInfo (2;.com.kodgames.message.proto.game.RoomInvitedFriendInfoProto"Þ
GCNotifyRoomInvitationSYN
clubId (
clubName (	
	inviterId (
inviterName (	
inviterIcon (	
inviterHeadFrame (
roomId (
	roundType (
	gamePlays	 (

sourceType
 ("+
CGCheckFriendShipREQ
checkRoleId ("8
GCCheckFriendShipRES
result (
isFriend ("3
GCSendFriendNotifyDataSYN
applicantCount ("a
ActivityTagPROTO
buttonId (
image (	
start (
end (
position ("Z
GCActivityTagSYNF
activityTag (21.com.kodgames.message.proto.game.ActivityTagPROTO"3
CGSendEmojiREQ
emojiId (
receiver (" 
GCSendEmojiRES
result ("C
GCSendEmojiSYN
emojiId (
sender (
receiver ("+

EmojiPROTO
itemId (
count ("
CGQueryEmojiREQ"]
GCQueryEmojiRES
result (:
emoji (2+.com.kodgames.message.proto.game.EmojiPROTO"/
PayTypePROTO
payType (
status ("$
CGQueryPayTypesREQ
osType ("d
GCQueryPayTypesRES
result (>
payType (2-.com.kodgames.message.proto.game.PayTypePROTO"ˆ
RoomInvitationProto
roomId (
	inviterId (
invitedSource (
clubId (
clubName (	
gameplaysDesc (	"§
SGSendRoomInvitationSYN
	inviteeId (
sendOffline (
gameplaysDesc (	M
roomInvitations (24.com.kodgames.message.proto.game.RoomInvitationProto"=
SpecialEffectInfoPROTO
itemId (
destroyTime ("d
GCSpecialEffectSYNN
specialEffect (27.com.kodgames.message.proto.game.SpecialEffectInfoPROTO"8
CGUseSpecialEffectREQ
itemId (
operate ("'
GCUseSpecialEffectRES
result ("}
CGUploadClientInfoREQ
writeOpType (

readOpType (
deviceId (	

deviceName (	
deviceVersion (	"
GCUploadClientInfoRES"*
RedDotProto
key (	
status ("R
GCRedDotStatusSYN=
redDots (2,.com.kodgames.message.proto.game.RedDotProto"
GCUploadClientLogSYN"
CGUploadClientLogREQ"&
GCUploadClientLogRES
result ("]
SCActivityInfoSYNH
activityInfo (22.com.kodgames.message.proto.game.ActivityInfoPROTO"<
GBGmtChangeCheatcardSYN
opened (
	cheatcard (	"…
BGBattleInAdvanceBISYNC
area (
roomId (

createTime (
ruleOfNumber (
playerNumber (
type ("V
ItemInfo
prizeId (
name (	
itemId (
count (
time ("„
SGAddItemREQ
roleId (
area (7
item (2).com.kodgames.message.proto.game.ItemInfo>
defaultItem (2).com.kodgames.message.proto.game.ItemInfo

activityId (
reason (
json (	

mallReason (	
redPacketReason	 (	"§
GSAddItemRES
result (
roleId (
area (

activityId (G
updateResult (21.com.kodgames.message.proto.game.UpdateItemResult
json (	"i
UpdateItemResult
result (
uuid (	7
item (2).com.kodgames.message.proto.game.ItemInfo"~
SGCostItemREQ
roleId (
area (

activityId (
json (	
itemId (
count (
reason ("p
GSCostItemRES
result (
roleId (
area (

activityId (
json (	
success ("c
SGQueryGoodsInfoREQ
roleId (
area (

activityId (
json (	
uuid (	"¤
GSQueryGoodsInfoRES
result (
roleId (
area (

activityId (
json (	=
	goodsInfo (2*.com.kodgames.message.proto.game.GoodsInfo"}
	GoodsInfo
uuid (	
order (	
status (
phone (	
roleName (	
address (	
	logistics (	"
CGQueryRoleTicketsREQ"O
GCQueryRoleTicketsRES6
item (2(.com.kodgames.message.proto.game.Consume"
CGWalletInfoREQ"q
GCWalletInfoRES
result (
money (?
record (2/.com.kodgames.message.proto.game.WithdrawRecord"3
CGWalletWithdrawREQ
level (
appId (	"%
GCWalletWithdrawRES
result ("
CGWalletWithdrawRecordREQ"‘
GCWalletWithdrawRecordRES
result (
income (
expenditure (?
record (2/.com.kodgames.message.proto.game.WithdrawRecord"W
WithdrawRecord
date (
reason (	
beforeMoney (

afterMoney ("
CGWalletConfigREQ"b
GCWalletConfigRES
result (=
config (2-.com.kodgames.message.proto.game.WalletConfig">
WalletConfig
money (
count (
useCount ("=
SGWithdrawREQ
roleId (
money (
appId (	"
GSWithdrawRES
result ("5
CGBusinessCardInfoREQ
area (
roleId ("h
GCBusinessCardInfoRES
result (?
info (21.com.kodgames.message.proto.game.BusinessCardInfo"2
BusinessCardInfo
roleId (
upload ("l
BGStartGameOfflineBISYN
area (
roomId (

createTime (
clubId (
offline ("6
BGAdvanceGameWaitSYN
clubId (
roomId (*1
ItemUpdateOperation
ADD
SUB
SYNCBBGameProtoBuf