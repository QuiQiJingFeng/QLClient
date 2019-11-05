
¨7
replay.proto!com.kodgames.message.proto.replay"»
GRDestroyRoomSYN
roomId (

createTime (
clubId (
areaId (
	managerId (
destroyerId (
destroyerName (	
destroyReason (
destroyDescription	 (	
destroyTime
 (
leagueId (J
playerInfos (25.com.kodgames.message.proto.replay.PlayerHistoryPROTO"p
RoomHistoryPlayerInfoElem
roleId (
position (
nickname (	

headImgUrl (	
sex ("d
RoomHistoryPlayerInfoK
elems (2<.com.kodgames.message.proto.replay.RoomHistoryPlayerInfoElem")
RoomHistoryGamePlays
	gameplays ("E
RoomHistoryRecordPlayerInfoElem
roleId (

totalPoint ("p
RoomHistoryRecordPlayerInfoQ
elems (2B.com.kodgames.message.proto.replay.RoomHistoryRecordPlayerInfoElem"Ÿ
PlayerHistoryPROTO
roleId (
position (
nickname (	

headImgUrl (	
sex (

totalPoint (
clubId (
clubName (	"Ø
RoundReportPROTO
playerRecords (
	startTime (
	lastCards (
isHuang (
spceialsCards (
version (
destroyerId (
endTime (

scoreRatio	 (
gameplayName
 (	"„
RoomHistoryPROTO
roomId (

createTime (L
playerRecords (25.com.kodgames.message.proto.replay.PlayerHistoryPROTO
	roundType (
	gameplays (

roundCount (
playerMaxCardCount (
enableMutilHu (
isProcessed	 (
isAbnormalRoom
 (
clubId (
destroyTime (

scoreRatio (
gameplayName (	
destoryReason ("Ã
GRMatchResultSYN
roomId (

createTime (
	roundType (

roundCount (
payCard (
enableMutilHu (
playerMaxCardCount (
clubId (
clubManagerId	 (
playbackDatas
 (N
roundReportRecord (23.com.kodgames.message.proto.replay.RoundReportPROTO
	gameplays (L
playerRecords (25.com.kodgames.message.proto.replay.PlayerHistoryPROTO
version (
areaId (
leagueId ("3
CRGameHistoryREQ
version (
areaId ("}
RCGameHistoryRES
result (
version (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO"[
CRHistoryRoomREQ
roomId (

createTime (
queryRoleId (
areaId ("Ã
RCHistoryRoomRES
result (

createTime (
roomId (
queryRoleId (O
roundReportRecords (23.com.kodgames.message.proto.replay.RoundReportPROTO
playbackExist ("^
CRHistoryPlaybackREQ
roomId (
	creatTime (
recordIndex (
areaId ("=
RCHistoryPlaybackRES
result (
playbackDatas ("|
CRShareHistoryREQ
roleId (
roomId (
roundNumber (
clubId (

createTime (
areaId ("Õ
RCShareHistoryRES
result (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTOO
roundReportRecords (23.com.kodgames.message.proto.replay.RoundReportPROTO
playbackExist ("^
CRProcessHistoryREQ
roomId (

createTime (
isProcessed (
areaId ("%
RCProcessHistoryRES
result ("¡
ClubRoomInfoPROTO
roomId (

createTime (
costCard (

roundCount (

isFinished (
winnerScore (
isAbnormalDestroy ("[
ClubHourRoomInfoListC
rooms (24.com.kodgames.message.proto.replay.ClubRoomInfoPROTO"O
CRQueryRoomDestroyInfoREQ
roomId (

createTime (
areaId ("Š
RCQueryRoomDestroyInfoRES
result (
destroyReason (
destroyerId (
destroyerName (	
destroyDescription (	"w
CRShareHistoryRoundForCodeREQ
roomId (

createTime (

roundIndex (
clubId (
areaId ("E
RCShareHistoryRoundForCodeRES
result (
playbackCode (	">
CRHistoryRoomByCodeREQ
playbackCode (	
areaId ("¦
RCHistoryRoomByCodeRES
result (

createTime (
roomId (
queryRoleId (N
roundReportRecord (23.com.kodgames.message.proto.replay.RoundReportPROTO
playbackExist (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO

roundIndex ("“
CCLClubHistoryREQ
clubId (
start (
num (
queryRoleId (
	queryTime (
minScore (
onlyAbnormalRoom ("Œ
CLCClubHistoryRES
result (
start (
clubId (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO"Ø
CLRClubHistoryREQ
clubId (
start (
num (
	queryTime (
minScore (
onlyAbnormalRoom (
areaId (
queryAll (
queryRoleIds	 (
roleId
 (
callback ("®
RCLClubHistoryRES
result (
start (
clubId (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO
roleId (
callback ("I
CCLCheckClubBillREQ
clubId (
	startTime (
endTime ("Ö
CLCCheckClubBillRES
result (
clubId (
	startTime (
endTime (
totalRoomCost (
settledRoomNum (
settledRoomCost (
unsettledRoomNum (
unsettledRoomCost	 ("{
CLRCheckClubBillREQ
clubId (
	startTime (
endTime (
areaId (
roleId (
callback ("ø
RCLCheckClubBillRES
result (
clubId (
	startTime (
endTime (
totalRoomCost (
settledRoomNum (
settledRoomCost (
unsettledRoomNum (
unsettledRoomCost	 (
roleId
 (
callback ("*
CCLCheckClubBillTodayREQ
clubId ("œ
CLCCheckClubBillTodayRES
result (
clubId (
todayRoomNum (
yesterdayRoomNum (
todayRoomCost (
yesterdayRoomCost ("\
CLRCheckClubBillTodayREQ
clubId (
areaId (
roleId (
callback ("¾
RCLCheckClubBillTodayRES
result (
clubId (
todayRoomNum (
yesterdayRoomNum (
todayRoomCost (
yesterdayRoomCost (
roleId (
callback ("À
CCLQueryLeagueRoomHistoryREQ
leagueId (
clubId (
start (
num (
	queryTime (
minScore (
onlyAbnormalRoom (
queryRoleId (
roomId	 ("‡
CLCQueryLeagueRoomHistoryRES
result (
start (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO"÷
CLRQueryLeagueRoomHistoryREQ
roleId (
areaId (
leagueId (
start (
num (
	queryTime (
minScore (
onlyAbnormalRoom (
queryRoleId	 (
queryClubId
 (
callback (
roomId ("»
RCLQueryLeagueRoomHistoryRES
result (
start (
roleId (
callback (
leagueId (H
roomRecords (23.com.kodgames.message.proto.replay.RoomHistoryPROTO"Z
ScoreListPROTO
roleId (
roleName (	
	realScore (
theoryScore ("«
CLRLeaguePlayerScoreResultSYN
roomId (
leagueId (
clubId (

createTime (D
	scoreList (21.com.kodgames.message.proto.replay.ScoreListPROTOBBReplayProtoBuf