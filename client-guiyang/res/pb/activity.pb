
Èä
activity.proto#com.kodgames.message.proto.activity"g
PlayerRankPROTO
roleId (
nickname (	
score (
	rankOrder (
rankTime ("m
ActivityRankPROTO

activityId (D
record (24.com.kodgames.message.proto.activity.PlayerRankPROTO"
CGActivityRankREQ"∂
GCActivityRankRES
result (D
rank (26.com.kodgames.message.proto.activity.ActivityRankPROTOK
historyRank (26.com.kodgames.message.proto.activity.ActivityRankPROTO"v
LimitedCostlessActivityPROTO

activityId (
roomType (
	startTime (
endTime (
name (	"z
GCNewLimitedCostlessActivitySYNW
activityList (2A.com.kodgames.message.proto.activity.LimitedCostlessActivityPROTO"
CGLimitedCostlessActivityREQ"á
GCLimitedCostlessActivityRES
result (W
activityList (2A.com.kodgames.message.proto.activity.LimitedCostlessActivityPROTO"≥
	GamePROTO

id (
type (
name (	
time (
homeTeam (	
homeIcon (	
visitingTeam (	
visitingIcon (	
homeOdds	 (	
visitingOdds
 (	
dogFall (	
peopleOfBet (

moneyOfBet (
	homeMoney (
visitingMoney (
dogFallMoney ("6
CGQueryLotteryInfoREQ
area (
operate ("§
GCQueryLotteryInfoRES
result (
serviceCharge (	
limitOfMoney (
version (=
games (2..com.kodgames.message.proto.activity.GamePROTO"H
CGQueryStakeREQ
area (

id (
team (
money ("!
GCQueryStakeRES
result ("¶
PlayerBetPROTO

id (
money (
team (
odds (	
canEarn (
status (<
game (2..com.kodgames.message.proto.activity.GamePROTO"$
CGQueryPlayerBetsREQ
area ("o
GCQueryPlayerBetsRES
result (G

playerBets (23.com.kodgames.message.proto.activity.PlayerBetPROTO";
CGQueryReceiveREQ
area (

id (
odds (	"#
GCQueryReceiveRES
result ("P
	OddsPROTO

id (
homeOdds (	
visitingOdds (	
dogFall (	"O
GCOddsModifySYN<
odds (2..com.kodgames.message.proto.activity.OddsPROTO"
GCLotteryRedDotSYN"ë
IACRoleLoginSYN
roleId (
nickname (	

headImgUrl (	
area (
unionId (	

createTime (
phone (	
	newPlayer (

libVersion	 (	
	gameCount
 (L
activityInfo (26.com.kodgames.message.proto.activity.ActivityInfoPROTO"<
GACActivityPurchaseSYN

activityId (
roleId ("®
GACRoomDestroyBiSYN
roomId (
	creatorId (
roleIds (

createTime (
destroyTime (
maxRoundCount (
realRoundCount (
averageBattleTime (
averageIdleTime	 (
startIdleTime
 (
roomLifeTime (
losePlayerCount (
totalLoseScore (
	gameplays (
destroyReason (
	isPrivate (
isActingCreate (
roomType (
area ("V
PlayerHistoryInfo
roleId (
scores (
score (

totalPoint ("y
GACMatchResultSYN
area (F
player (26.com.kodgames.message.proto.activity.PlayerHistoryInfo
clubId ("~
GACFinalMatchResultSYN
area (F
player (26.com.kodgames.message.proto.activity.PlayerHistoryInfo
clubId ("C
GACCampaignAddCardSYN
roleId (
area (
rank ("0
GACBindPhoneSYN
roleId (
phone (	"á
ACCActivityInfoSYN
result (D
info (26.com.kodgames.message.proto.activity.ActivityInfoPROTO
questionnaireStatus ("C
ActivityInfoPROTO

id (
	startTime (
endTime ("`
ACCActivityInfoUpdateSYND
info (26.com.kodgames.message.proto.activity.ActivityInfoPROTO"
CACMainSceneShareQueryREQ"C
ACCMainSceneShareQueryRES
result (
remainderCount ("
CACMainSceneSharePickREQ"B
ACCMainSceneSharePickRES
result (
remainderCount ("%
CACNewPlayerInfoREQ
answer ("%
ACCNewPlayerInfoRES
result (")
ACCPlayWinPrizeSYN
prizeNumber ("
CACQueryQuestionnaireREQ"G
ACCQueryQuestionnaireRES
result (
url (	
reward ("8
ACCQuestionnaireResultSYN
questionnaireStatus ("
CACQuestionnaireRewardREQ"+
ACCQuestionnaireRewardRES
result ("
CACFlopHavePrizeREQ"ñ
FlopPrizeInfoPROTO
imageId (
	prizeName (	

prizeCount (
itemId (
time (

isBigPrize (
prizeInventory ("ü
ACCFlopHavePrizeRES
result (O
prizeInfoPROTO (27.com.kodgames.message.proto.activity.FlopPrizeInfoPROTO
remainFlopCounts (
rules (	"
CACSelectPrizeREQ"é
ACCSelectPrizeRES
result (O
prizeInfoPROTO (27.com.kodgames.message.proto.activity.FlopPrizeInfoPROTO
remainFlopCounts ("
CACFlopHavePrizeTaskREQ"w
FlopHavePrizeTaskPROTO
isFinish (
taskType (
	missCount (
	needCount (
chanceCount ("x
ACCFlopHavePrizeTaskRES
result (M
taskList (2;.com.kodgames.message.proto.activity.FlopHavePrizeTaskPROTO"
CACFlopGetPrizeRecordREQ"À
PrizeRecordPROTO
	prizeName (	

prizeCount (
winTime (
status (
itemId (
goodUID (	
phone (	
name (	
address	 (	
	logistics
 (	
order (	"u
ACCFlopGetPrizeRecordRES
result (I

recordList (25.com.kodgames.message.proto.activity.PrizeRecordPROTO"
CACShareFlopPrizeREQ"&
ACCShareFlopPrizeRES
result ("
CACFlopWinnerListREQ"7
ACCFlopWinnerListRES
result (
content (	"
CACFlopGiftPackageInfoREQ"Ø
ACCFlopGiftPackageInfoRES
result (
	flopCount (
	taskCount (
received (J
package (29.com.kodgames.message.proto.activity.GiftPackageInfoPROTO"5
GiftPackageInfoPROTO
itemId (
count ("
CACFlopReceiveGiftPackageREQ".
ACCFlopReceiveGiftPackageRES
result ("
CACFlopCardBuyREQ"#
ACCFlopCardBuyRES
result ("D
RewardPROTO

id (
name (	
count (
type ("
CACQueryLuckyDrawREQ"ﬁ
ACCQueryLuckyDrawRES
result (E
cost (27.com.kodgames.message.proto.activity.LuckyDrawCostPROTO
defaultLightId (
freeDrawTimes (@
reward (20.com.kodgames.message.proto.activity.RewardPROTO">
LuckyDrawCostPROTO
itemId (
one (
ten ("B
CACQueryDrawREQ
operate (
isFree (
costId ("z
ACCQueryDrawRES
result (
freeDrawTimes (@
reward (20.com.kodgames.message.proto.activity.RewardPROTO"≠
RecordPROTO
reward (	
time (
itemId (
goodUUID (	
order (	
status (
phone (	
name (	
address	 (	
	logistics
 (	"
CACQueryDrawRecordREQ"i
ACCQueryDrawRecordRES
result (@
record (20.com.kodgames.message.proto.activity.RecordPROTO"O
WeekRewardProto
day (
rewardId (
count (
status ("
CACQueryWeekREQ
area ("u
ACCQueryWeekRES
result (
day (E
rewards (24.com.kodgames.message.proto.activity.WeekRewardProto"1
CACQuerySignInREQ
day (
operate ("0
ACCQuerySignInRES
result (
day ("
CACShareActivityInfoREQ"ê
ACCShareActivityInfoRES
result (M

progresses (29.com.kodgames.message.proto.activity.InviteeProgressPROTO
rewardProgress ("f
InviteeProgressPROTO
roleId (

headImgUrl (	

roundCount (
rewardProgress ("J
 CACReceiveShareActivityRewardREQ
roleId (
rewardProgress ("Z
 ACCReceiveShareActivityRewardRES
result (
roleId (
rewardProgress ("
CACMagpieRechargeActivityREQ"Ñ
ACCMagpieRechargeActivityRES
result (
	hasBought (A
item (23.com.kodgames.message.proto.activity.ItemCountPROTO"/
ItemCountPROTO
itmeId (
count ("
ACCMagpieRewardSYN"
CACMagpieWorldProgressREQ"£
ACCMagpieWorldProgressRES
result (
maxRoundCount (
curRoundCount (H
progress (26.com.kodgames.message.proto.activity.ProgressInfoPROTO"E
ProgressInfoPROTO
progress (
status (
reward (	"
CACMagpieWorldWinnerListREQ">
ACCMagpieWorldWinnerListRES
result (
content (	"2
CACMagpieWorldReceiveRewardREQ
progress ("]
ACCMagpieWorldReceiveRewardRES
result (
itemId (
count (
time ("
CACMagpiePrizeRecordREQ"p
ACCMagpiePrizeRecordRES
result (E
record (25.com.kodgames.message.proto.activity.PrizeRecordPROTO"
CACMonthSignInfoREQ"Ú
ACCMonthSignInfoRES
result (

currentDay (
	signCount (
signCost (D
everyDay (22.com.kodgames.message.proto.activity.EveryDayPROTOL
accumulation (26.com.kodgames.message.proto.activity.AccumulationPROTO"L
EveryDayPROTO
status (
itemId (
count (
time ("c
AccumulationPROTO
	signCount (
status (
itemId (
count (
time ("!
CACMonthSignInREQ
type ("7
ACCMonthSignInRES
result (

currentDay (")
CACMonthReceiveRewardREQ
index ("H
ACCMonthReceiveRewardRES
result (
index (
count ("
CACPhoneBindREQ
area (",
ACCPhoneBindRES

id (
count ("U
InviteePROTO
nickname (	

headImgUrl (	
money (	
isFinish (" 
CACOpenRPInfoREQ
area ("ÿ
ACCOpenRPInfoRES
result (
show (	
money (	
friendHuMoney (	
	resetTime (
alreadyShare (
openTips (
huTips (
newTips	 (
newMoney
 (	
withdrawConfig (C
invitees (21.com.kodgames.message.proto.activity.InviteePROTO
rewardMoneyCount (
rewardMoneyAllCount ("2
CACOpenRedPackageREQ
area (
type ("5
ACCOpenRedPackageRES
result (
money (	"s
CACWithdrawREQ
area (
money (
	longitude (	
latitude (	
deviceId (	
isNew (" 
ACCWithdrawRES
result ("^
OpenRecordPROTO
nickname (	
type (
money (	
time (
status ("$
CACWithdrawRecordREQ
area ("¿
ACCWithdrawRecordRES
result (I
openRecords (24.com.kodgames.message.proto.activity.OpenRecordPROTOM
withdrawRecords (24.com.kodgames.message.proto.activity.OpenRecordPROTO"$
CACBackShareREQ
	isManager ("@
ACCBackShareRES
result (
itemId (
count ("
CACBackInfoOrdinaryUserREQ"Ä
ACCBackInfoOrdinaryUserRES
result (
task (
	signCount (
todaySigned (C
reward (23.com.kodgames.message.proto.activity.BackSignRewardB
prize (23.com.kodgames.message.proto.activity.BackSignReward
todayShared ("=
BackSignReward
itemId (
count (
time ("
CACBackSignREQ"3
ACCBackSignRES
result (
	signCount ("
CACBackInfoClubManagerREQ"∆
ACCBackInfoClubManagerRES
result (
shared (
bindNum (
	cacheCard (
	totalCard (
leftResetDay (
increaseCard (
	cardLimit (
todayShared	 ("
CACBackCheckBindUserREQ";
ACCBackCheckBindUserRES
result (
nickname (	"
CACBackExtractCardREQ"5
ACCBackExtractCardRES
result (
card ("*
ACGBackQueryIsManagerREQ
roleId ("M
GACBackQueryIsManagerRES
result (
roleId (
	isManager ("*
GCLBackQueryIsManagerREQ
roleId ("M
CLGBackQueryIsManagerRES
result (
roleId (
	isManager ("
ACCBackClubDelaySYN"
CACPrayInfoREQ"0
ACCPrayInfoRES
result (
itemId ("

CACPrayREQ
itemId ("

ACCPrayRES
result ("
CACPraySignInfoREQ"â
ACCPraySignInfoRES
result (?
reward (2/.com.kodgames.message.proto.activity.SignReward
	signCount (
canSign ("9

SignReward
itemId (
count (
time ("
CACPraySignREQ" 
ACCPraySignRES
result ("_
ThrowRewardPROTO
number (
status (
itemId (
count (
time ("
CACThrowRewardInfoREQ"®
ACCThrowRewardInfoRES
result (

costItemID (
	costCount (
freeOpen (F
rewards (25.com.kodgames.message.proto.activity.ThrowRewardPROTO"9
CACThrowRewardOpenREQ
number (
freeOpen ("Ä
ACCThrowRewardOpenRES
result (
freeOpen (E
reward (25.com.kodgames.message.proto.activity.ThrowRewardPROTO"
CACThrowRewardShareREQ"o
ACCThrowRewardShareRES
result (E
reward (25.com.kodgames.message.proto.activity.ThrowRewardPROTO"
CACGodOfWealthInfoREQ"`
ACCGodOfWealthInfoRES
result (
identity (
	openCount (

headImages (	"E
GodOfWealthRewardPROTO
itemId (
count (	
time ("
CACGodOfWealthOpenREQ"É
ACCGodOfWealthOpenRES
result (
open (L
rewards (2;.com.kodgames.message.proto.activity.GodOfWealthRewardPROTO"
CACGodOfWealthRecordREQ"w
ACCGodOfWealthRecordRES
result (L
rewards (2;.com.kodgames.message.proto.activity.GodOfWealthRewardPROTO"
ACCGodOfWealthSYNC"ç
ClubWeekSignInfoProto
day (
status (
	vaildDate (D
rewardItems (2/.com.kodgames.message.proto.activity.SignReward"u
ClubWeekRewardPackageProto
	packageId (D
rewardItems (2/.com.kodgames.message.proto.activity.SignReward"+
CACQueryClubWeekSignInfoREQ
area ("’
ACCQueryClubWeekSignInfoRES
result (M
	signInfos (2:.com.kodgames.message.proto.activity.ClubWeekSignInfoProtoW
rewardPackages (2?.com.kodgames.message.proto.activity.ClubWeekRewardPackageProto"D
!CACSelectClubWeekRewardPackageREQ
area (
	packageId ("3
!ACCSelectClubWeekRewardPackageRES
result ("9
CACPickClubWeekSignRewardREQ
day (
area (".
ACCPickClubWeekSignRewardRES
result ("9

RewardInfo
itemId (
count (
time ("
CACCollectCodeInfoREQ"ñ
ACCCollectCodeInfoRES
result (B
task (24.com.kodgames.message.proto.activity.CollectCodeTask
period (
	startTime (
countDownTime (
lotteryTime (
endTime (
	luckyCode (	
lotteryTimes	 (
codes
 (	
	codeCount ("ö
CollectCodeTask
taskType (
completeTimes (
status (N
progress (2<.com.kodgames.message.proto.activity.CollectCodeTaskProgress"i
CollectCodeTaskProgress
times (?
reward (2/.com.kodgames.message.proto.activity.RewardInfo"
CACCollectCodeShareREQ"(
ACCCollectCodeShareRES
result ("
CACCollectCodeLotteryREQ"8
ACCCollectCodeLotteryRES
result (
code (	"E
"CACCollectCodeReceiveTaskRewardREQ
taskType (
index ("u
"ACCCollectCodeReceiveTaskRewardRES
result (?
reward (2/.com.kodgames.message.proto.activity.RewardInfo"F
%CACCollectCodeReceiveLotteryRewardREQ
period (
index ("7
%ACCCollectCodeReceiveLotteryRewardRES
result ("
CACCollectCodeQueryCodeREQ"ª
ACCCollectCodeQueryCodeRES
result (C
codes (24.com.kodgames.message.proto.activity.CollectCodeInfo
unluckyItemId (
unluckyItemCount (
unluckyItemTime ("#
!CACCollectCodeQueryHistoryCodeREQ"Å
!ACCCollectCodeQueryHistoryCodeRES
result (L
record (2<.com.kodgames.message.proto.activity.CollectCodePeriodRecord"Å
CollectCodePeriodRecord
period (
	luckyCode (	C
codes (24.com.kodgames.message.proto.activity.CollectCodeInfo"N
CollectCodeInfo
code (	
count (	
status (
itemId ("
CACCollectCodeLuckyRecordREQ"{
ACCCollectCodeLuckyRecordRES
result (K
record (2;.com.kodgames.message.proto.activity.CollectCodeLuckyRecord"%
#CACCollectCodeHistoryLuckyRecordREQ"Ç
#ACCCollectCodeHistoryLuckyRecordRES
result (K
record (2;.com.kodgames.message.proto.activity.CollectCodeLuckyRecord"ü
CollectCodeLuckyRecord
	luckyCode (	
	startTime (
endTime (N

playerInfo (2:.com.kodgames.message.proto.activity.CollectCodePlayerInfo"W
CollectCodePlayerInfo
level (
nickname (	
roleId (
count ("J
QSRewardProto
count (
status (
now (
total ("
CACQueryShareRewardsREQ"í
ACCQueryShareRewardsRES
result (
weChat (	

inviteType (C
rewards (22.com.kodgames.message.proto.activity.QSRewardProto"p
CACQueryPickRewardREQ

inviteType (
pick (
	longitude (	
latitude (	
deviceId (	"'
CACQueryPickRewardRES
result ("
CACCatchDollInfoREQ"S
ACCCatchDollInfoRES
result (
catchCounts (
goldCatchCounts ("0
CACCatchDollREQ
isCatch (
type ("ç
ACCCatchDollRES
result (
isCatch (
catchCounts (
goldCatchCounts (
itemId (
count (
time ("_
CatchDollTaskPROTO
isFinish (
taskType (
finishCount (
allCount ("
CACCatchDollTaskREQ"Å
ACCCatchDollTaskRES
result (

countPrice (F
tasks (27.com.kodgames.message.proto.activity.CatchDollTaskPROTO"
CACBuyCatchDollREQ"9
ACCBuyCatchDollRES
result (
catchCounts ("R
CatchRecordPROTO
itemId (
count (
time (
	catchTime ("
CACCatchRecordREQ"k
ACCCatchRecordRES
result (F
records (25.com.kodgames.message.proto.activity.CatchRecordPROTO"√
KoiFishAwardRecordProto
index (
	hasPicked (
canPickTime (
curRoundCount (
needRoundCount (
awardItemId (
awardItemCount (
awardItemTime (".
CACQueryKoiFishActivityInfoREQ
area ("Ñ
ACCQueryKoiFishActivityInfoRES
result (R
awardRecords (2<.com.kodgames.message.proto.activity.KoiFishAwardRecordProto"=
CACPickKoiFishActivityAwardREQ
area (
index ("0
ACCPickKoiFishActivityAwardRES
result (BBActivityProtoBuf