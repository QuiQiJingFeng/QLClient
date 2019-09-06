
÷

room.protocom.kodgames.message.proto.room"£
CBEnterRoomREQ
roleId (
roomId (
nickname (	
headImageUrl (	
	headFrame (
sex (
	isWatcher (

isIdentity (
joinType	 (	
specialEffect
 (
clubId (I
enterRoomPlayerGps (2-.com.kodgames.message.proto.room.GpsInfoProto"
BCEnterRoomRES
result (

roomClubId (
roomType (
	gameplays (

roundCount (
isHaveBeginFirstGame (
maxPlayerCount (
	isWatcher (
canEarlyBattle	 (
	isWaiting
 (
clubManagerId (I
creatorInfo (24.com.kodgames.message.proto.room.RoomPlayerInfoPROTO

createTime (
clubId (
leagueId (

scoreRatio ("
RoomPlayerInfoPROTO
roleId (
position (
nickname (	
headImageUrl (	
	headFrame (
sex (

ip (	
status (

totalPoint	 (
pointInGame
 (>
gpsInfo (2-.com.kodgames.message.proto.room.GpsInfoProtoN
realTimeVoice (27.com.kodgames.message.proto.room.RealTimeVoiceInfoPROTO
rank (

isIdentity (
specialEffect ("¡
BCRoomPlayerInfoSYNH

playerInfo (24.com.kodgames.message.proto.room.RoomPlayerInfoPROTO
totalRoundCount (
nowRoundCount (
multiple ("&
CBQuitRoomREQ
isDestroyRoom ("
BCQuitRoomRES
result ("=
CBStartVoteDestroyREQ
phoneNumber (	
reasons ("'
BCStartVoteDestroyRES
result (" 
CBVoteDestroyREQ
type (""
BCVoteDestroyRES
result ("l
BCVoteDestroyInfoSYN
	applicant (
agreePlayers (
disagreePlayers (

remainTime ("G
BCDestroyRoomSYN
result (
reason (
description (	"#
CBUpdateStatusREQ
status ("#
BCUpdateStatusRES
result ("
SameIpPROTO
players ("O
BCSameIpSYN@

sameGroups (2,.com.kodgames.message.proto.room.SameIpPROTO"C
GpsInfoProto
status (
latitude (
	longitude ("c
SecurePlayerPROTO
roleId (>
gpsInfo (2-.com.kodgames.message.proto.room.GpsInfoProto"X
BCSecureDetectSYNC
players (22.com.kodgames.message.proto.room.SecurePlayerPROTO"C
CBGpsInfoREQ
status (
latitude (
	longitude ("
BCGpsInfoRES
result (":
RealTimeVoiceInfoPROTO
status (
memberId ("n
BCRealTimeVoiceSYN
roleId (H
rtvInfo (27.com.kodgames.message.proto.room.RealTimeVoiceInfoPROTO"6
CBRealTimeVoiceREQ
status (
memberId ("$
BCRealTimeVoiceRES
result ("&
CBQuitWatchBattleREQ
roomId ("&
BCQuitWatchBattleRES
result ("<
CBIpSameREQ
ipSameCount (
gpsConflictCount ("
BCIpSameRES"J
PlayerOPTimeInfo
roleId (
	delayTime (
averageTime ("
CBQueryPlayerOPInfoREQ"r
BCQueryPlayerOPInfoRES
result (H
playerOPInfos (21.com.kodgames.message.proto.room.PlayerOPTimeInfo"+
CBStartBattleInAdvanceREQ
roomId ("+
BCStartBattleInAdvanceRES
result ("$
CBVoteStartBattleREQ
type ("&
BCVoteStartBattleRES
result ("¯
BCVoteStartBattleInfoSYN
	applicant (
agreePlayers (
disagreePlayers (

remainTime (
clearVoteTask (
ruleOfAdvance (
isStart ("L
BVoteStartBattleREQ
roomId (
voteTime (
applicantId ("!
CBOpenAutoHuREQ
isOpen ("!
BCOpenAutoHuRES
result ("`
BCAdvanceInfoSYN
switch (
oldRuleOfPlayerNumber (
newRuleOfPlayerNumber (*+
EMVote

VOTE_AGREE
VOTE_DISAGREEBBRoomProtoBuf