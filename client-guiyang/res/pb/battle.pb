
á
battle.proto!com.kodgames.message.proto.battle"A
ResultScorePROTO
type (
calcType (
point ("g
ResultScoreData
sourceId (B
datas (23.com.kodgames.message.proto.battle.ResultScorePROTO"Á
PlayStepPROTO
roleId (
pointInGame (
playType (
cards (E
	scoreData (22.com.kodgames.message.proto.battle.ResultScoreData
sourceRoleId (
datas ("Í
BattlePlayerInfoPROTO
roleId (

totalPoint (
pointInGame (
status (
	handCards (
outCards (F
operateCards (20.com.kodgames.message.proto.battle.PlayStepPROTO"e
BCPlayStepSYN?
steps (20.com.kodgames.message.proto.battle.PlayStepPROTO
protocolSeq ("¸
BCBattlePlayerInfoSYNI
players (28.com.kodgames.message.proto.battle.BattlePlayerInfoPROTO
	isRecover (
protocolSeq (
enableMutilHu (
totalCardsNum ("?
CBPlayCardREQ
playType (
cards (
datas ("4
BCPlayCardRES
result (
protocolSeq ("›
ResultEventPROTO
addOperation (B
score (23.com.kodgames.message.proto.battle.ResultScorePROTOF
	subScores (23.com.kodgames.message.proto.battle.ResultScorePROTO
targets (
combinedTimes (
combinedPoint (

eventPoint (

sourceCard ("“
PlayerMatchResultPROTO
roleId (

totalPoint (
pointInGame (C
events (23.com.kodgames.message.proto.battle.ResultEventPROTO
	handCards (F
operateCards (20.com.kodgames.message.proto.battle.PlayStepPROTO
status (
outCards ("«
FixedPlayerMatchResultPROTO
roleId (
	displayId (

totalPoint (
pointInGame (C
events (23.com.kodgames.message.proto.battle.ResultEventPROTO
	handCards (F
operateCards (20.com.kodgames.message.proto.battle.PlayStepPROTO
status (
outCards	 ("e
MatchPlaybackPlayerPROTO
roleId (
	handCards (
	delayTime (
averageTime ("}
FixedMatchPlaybackPlayerPROTO
roleId (
	displayId (
	handCards (
	delayTime (
averageTime ("Z
MatchPlaybackStepsPROTO?
steps (20.com.kodgames.message.proto.battle.PlayStepPROTO"³
MatchPlaybackPROTOP
playerDatas (2;.com.kodgames.message.proto.battle.MatchPlaybackPlayerPROTOK
records (2:.com.kodgames.message.proto.battle.MatchPlaybackStepsPROTO"½
FixedMatchPlaybackPROTOU
playerDatas (2@.com.kodgames.message.proto.battle.FixedMatchPlaybackPlayerPROTOK
records (2:.com.kodgames.message.proto.battle.MatchPlaybackStepsPROTO"D
ResultGamePROTO
type (
addOperation (
times ("Ä
PlayerMatchFinalResultPROTO
roleId (

totalPoint (
averageTime (F

gameResult (22.com.kodgames.message.proto.battle.ResultGamePROTO
	delayTime (
	applicant ("û
BCMatchResultSYN
isHuang (O
matchResults (29.com.kodgames.message.proto.battle.PlayerMatchResultPROTO
protocolSeq (
isRejoin (
	lastCards (
spceialsCards (
battleEndTime (
canAutoStartNextRound ("ß
BCFinalMatchResultSYNS
gameResults (2>.com.kodgames.message.proto.battle.PlayerMatchFinalResultPROTO
roomId (
roomCreateTime (
maxRoundCount (
clubId (
clubName (	
leagueId ("6
BStartTrusteeshipREQ
roomId (
roleId (" 
BAutoStartGame
roomId ("b
BAutoPlayCardREQ
roomId (
roleId (
playType (
cards (
datas (BBBattleProtoBuf