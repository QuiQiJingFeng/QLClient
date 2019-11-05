
¢C
campaign.proto#com.kodgames.message.proto.campaign"+
RewardCostData

id (
count ("V
Cost
key (A
item (23.com.kodgames.message.proto.campaign.RewardCostData"!
Tabs
key (
name (	"9
ICALoginSYN
roleId (
area (
name (	"9
CCAFocusOnCampaignListREQ
optype (
area ("—
CACFocusOnCampaignListRES
result (S
campaignList (2=.com.kodgames.message.proto.campaign.CACNotifyCampaignListSYN
receiveFlag (:
tabInfo (2).com.kodgames.message.proto.campaign.Tabs"¨
CACNotifyCampaignListSYNG
campaignList (21.com.kodgames.message.proto.campaign.CampaignInfoG
signUpInfoList (2/.com.kodgames.message.proto.campaign.SignUpInfo"u

SignUpInfo

campaignId (
configId (A
cost (23.com.kodgames.message.proto.campaign.RewardCostData"„
CampaignInfo

id (
name (	
createTimestamp (
playerCount (
instructions (	
maxPlayerCount (?

rewardList (2+.com.kodgames.message.proto.campaign.Reward
image	 (
	freeTimes
 (
	startTime (	
endTime (	
status (
type (
	shareFree (7
cost (2).com.kodgames.message.proto.campaign.Cost
showStartTime (	
	enterTime (
sort (
nextStartTime (
configId (
tab ("(
CCAPlayerStatusREQ

campaignId ("$
CACPlayerStatusRES
status ("8
CACPlayerStatusSYN
status (

campaignId ("f
CACEnterRoomSYN
roomId (

campaignId (
count (

totalCount (
name (	"Y
Reward
rank (A
item (23.com.kodgames.message.proto.campaign.RewardCostData"A
CCASignUpREQ

campaignId (
configId (
key ("ä
CACSignUpRES
result (

campaignId (7
cost (2).com.kodgames.message.proto.campaign.Cost
configId (
key ("®
CAGSignUpREQ
roleId (

campaignId (
flag (7
cost (2).com.kodgames.message.proto.campaign.Cost
clubId (
configId (
key ("ö
GCASignUpRES
roleId (

campaignId (
result (7
cost (2).com.kodgames.message.proto.campaign.Cost
configId (
key ("(
CCASignUpCancelREQ

campaignId ("6
CACSignUpCancelRES
result (
configId ("v
CAGAddCardREQ

campaignId (C

roleReward (2/.com.kodgames.message.proto.campaign.RoleReward
time ("ë

RoleReward
roleId (A
item (23.com.kodgames.message.proto.campaign.RewardCostData
type (
campaignName (	
rank ("
GCAAddCardRES
result ("Û
CAGCreateRoomREQ

campaignId (@
players (2/.com.kodgames.message.proto.campaign.PlayerInfo
	gamePlays (

roundCount (
	gameCount (
multiple (
campaignConfigId (
clubId (
virtualFlag	 ("Ø
GCACreateRoomRES

campaignId (@
players (2/.com.kodgames.message.proto.campaign.PlayerInfo
roomId (
result (
multiple (
virtualFlag ("9

PlayerInfo
roleId (
score (
rank ("ì
BCARoomResultSYN

campaignId (
roomId (H
playerResults (21.com.kodgames.message.proto.campaign.PlayerResult
	closeFlag ("2
PlayerResult
roleId (

totalPoint ("Ω
CACRankChangeSYN
rank (

totalPoint (
round (
playerCount (
nextPlayerCount (
	roomCount (
thisPlayerCount (
daLiFlag (
name	 (	"(
CACPromotionSYN
promotionFlag (""
CCAGiveUpREQ

campaignId ("
CACGiveUpRES
result ("∫
CampaignResultInfo
name (	
createTimestamp (
rank (
isGiveUp (A
item	 (23.com.kodgames.message.proto.campaign.RewardCostData
status
 (

id ("•
CACResultSYNG
result (27.com.kodgames.message.proto.campaign.CampaignResultInfo
again (
clubId (
configId (
key (
itemId ("'
CCACampaignHistoryREQ
clubId ("a
CACCampaignHistoryRESH
results (27.com.kodgames.message.proto.campaign.CampaignResultInfo"2
CAGStartCampaignSYN
count (
area ("6
CAGCampaignOverSYN

campaignId (
area ("'
CANotifyCampaignListREQ
area ("I
GCARoomDestroySYN

campaignId (
roomId (
playerId ("#
CAGDestroyRoomREQ
roomId ("7
CAMttPrepareREQ

campaignId (
pushType ("
CACMttPrepareSYN

id ("#
CAMttStartREQ

campaignId ("4
CAGMttQueryREQ

campaignId (
roleId ("4
GCAMttQueryRES

campaignId (
roleId ("4
CARankChangeREQ

campaignId (
round (""
CAMttOverREQ

campaignId ("
CCAHonorWallREQ"R
CACHonorWallRES?
mttHonor (2-.com.kodgames.message.proto.campaign.MttHonor"q
MttHonor
campaignName (	
time (A
	roleHonor (2..com.kodgames.message.proto.campaign.RoleHonor"l
	RoleHonor
name (	
rank (C
reward (23.com.kodgames.message.proto.campaign.RewardCostData"W
CARaiseLinePreREQ

campaignId (
round (
score (
multiple ("T
CARaiseLineREQ

campaignId (
round (
score (
multiple ("
CACRaiseLinePreSYN"2
CACRaiseLineSYN
multiple (
score ("
CACDaLiPromotionSYN"%
CCARoundInfoREQ

campaignId ("·
CACRoundInfoRES
daLiFlag (
round (
score (
multiple (
nextPlayerCount (
thisPlayerCount (
time (9
level (2*.com.kodgames.message.proto.campaign.Level:
rounds	 (2*.com.kodgames.message.proto.campaign.Round?

rewardList
 (2+.com.kodgames.message.proto.campaign.Reward
instructions (	"6
Level
time (
multiple (
score ("A
Round
count (
multiple (
nextPlayerCount ("b
CACRoleMissMttSYN

campaignId (
campaignName (	
	enterTime (
configId ("D
CAGMttPrepareREQ

campaignId (
time (
roleId ("7
CCAReceiveRewardREQ

campaignId (
time ("%
CACReceiveRewardRES
result ("$
CCACampaignConfigREQ
area ("b
CACCampaignConfigRESJ
	campaigns (27.com.kodgames.message.proto.campaign.CampaignConfigInfo"©
CampaignConfigInfo

id (
name (	
instructions (	?

rewardList (2+.com.kodgames.message.proto.campaign.Reward7
cost (2).com.kodgames.message.proto.campaign.Cost
type (G

createCost (23.com.kodgames.message.proto.campaign.RewardCostData

leastCount ("N
CCACampaignCreateREQ

id (
name (	
time (
clubId ("&
CACCampaignCreateRES
result ("œ
CampaignCreateInfo
code (

id (
name (	
createTimestamp (
playerCount (
instructions (	?

rewardList (2+.com.kodgames.message.proto.campaign.Reward7
cost (2).com.kodgames.message.proto.campaign.Cost
endTime	 (
status
 (
type (
configId (

leastCount ("Ø
CAGCampaignCreateREQ
roleId (
campaignConfigId (
name (	
time (A
cost (23.com.kodgames.message.proto.campaign.RewardCostData
clubId ("|
GCACampaignCreateRES
result (
roleId (
campaignConfigId (
name (	
time (
clubId ("*
CCACampaignCreateListREQ
clubId ("z
CACCampaignCreateListRESJ
	campaigns (27.com.kodgames.message.proto.campaign.CampaignCreateInfo

campaignId ("2
CCACampaignCancelREQ

id (
clubId ("&
CACCampaignCancelRES
result ("ç
CAGCampaignCancelREQ
roleId (A
item (23.com.kodgames.message.proto.campaign.RewardCostData

campaignId (
clubId ("J
GCACampaignCancelRES
roleId (
clubId (

campaignId ("0
CCACampaignCreatePlayerREQ

campaignId ("b
CACCampaignCreatePlayerRESD
players (23.com.kodgames.message.proto.campaign.PlayerRankInfo"_
PlayerRankInfo
name (	?

rewardList (2+.com.kodgames.message.proto.campaign.Reward"u
CAGMttMarqueeREQ
area (
campaignName (	=
role (2/.com.kodgames.message.proto.campaign.RewardInfo"_

RewardInfo
name (	C
reward (23.com.kodgames.message.proto.campaign.RewardCostData"
CCAArenaInfoREQ"›
CACArenaInfoRES?
rounds (2/.com.kodgames.message.proto.campaign.ArenaRound<
rewards (2+.com.kodgames.message.proto.campaign.Reward
round (
rank (
status (
name (	
configId ("0

ArenaRound
count (
playerCount ("3
CACArenaPromotionSYN
round (
rank (" 
CAMttCreateNextREQ

id ("
CASwitchREQBBCampaignProtoBuf