
Ÿ8

auth.protocom.kodgames.message.proto.auth"q
CIVersionUpdateREQ
channel (

subchannel (

libVersion (	

proVersion (	
roleId ("
IAVersionUpdateREQ
channel (

subchannel (

libVersion (	

proVersion (	
clientConnectionId (
roleId (
roleIp (	"¼
AIVersionUpdateRES
result (
channel (

subchannel (
libVersionLevel (
lastLibVersion (	
libUrl (	

proVersion (	
proNeedUpdate (
proUrl	 (	
reviewVersion
 (	
	reviewUrl (	
clientConnectionId (
updateNotice (	
rejectByWhiteList ("›
ICVersionUpdateRES
result (
channel (

subchannel (

libVersion (	
lastLibVersion (	
libUrl (	

proVersion (	
proNeedUpdate (
proUrl	 (	
reviewVersion
 (	
	reviewUrl (	
updateNotice (	
rejectByWhiteList ("O
ProductVersionPROTO

needUpdate (
version (	
description (	"€
LibraryVersionPROTO
forceUpdate (
libVersionLevel (
highestLibVersion (	
description (	
url (	"ï
CIAccountAuthREQ
channel (	
username (	
refreshToken (	
code (	
platform (	

proVersion (	

libVersion (	
appCode (
deviceId	 (	
area
 (

subChannel (
updateChannel ("¡
IAAccountAuthREQ
channel (	
username (	
refreshToken (	
code (	
clientConnectionId (
platform (	

proVersion (	

libVersion (	
appCode	 (
deviceId
 (	
area (
oldAccountId (

subChannel (
updateChannel ("Í
AIAccountAuthRES
result (
channel (	
username (	
refreshToken (	
	accountId (
nickname (	
headImageUrl (	
sex (
clientConnectionId	 (H

proVersion
 (24.com.kodgames.message.proto.auth.ProductVersionPROTOH

libVersion (24.com.kodgames.message.proto.auth.LibraryVersionPROTO
	timestamp (
	signature (	
wxUrl (	
area (
unionId (	
developerId (	

phoneToken (	
phoneNum (	
loginUrlSwitch (
loginUrl (	

dingOpenId (	
dingRefreshToken (	
	hasHuTong ("
ICAccountAuthRES
result (
channel (	
username (	
refreshToken (	
	accountId (
nickname (	
headImageUrl (	
sex (
roleId	 (
gameServerId
 (

ip (	H

proVersion (24.com.kodgames.message.proto.auth.ProductVersionPROTOH

libVersion (24.com.kodgames.message.proto.auth.LibraryVersionPROTO
clubServerId (
	timestamp (
	signature (	
wxUrl (	
pushServerId (
area (
developerId (	
unionId (	
replayServerId (
campaignServerId (

phoneToken (	
phoneNum (	
goldServerId (
loginUrlSwitch (
loginUrl (	
replayNonZdbServerId (

dingOpenId (	
dingRefreshToken (	
	hasHuTong  (
activityServerId! ("ê
CIPhoneLoginREQ
channel (	
phone (	
token (	

verifyCode (	
platform (	

proVersion (	

libVersion (	
appCode (
deviceId	 (	
area
 (

subChannel (
updateChannel ("†
IAPhoneLoginREQ
channel (	
phone (	
token (	

verifyCode (	
clientConnectionId (
platform (	

proVersion (	

libVersion (	
appCode	 (
deviceId
 (	
area (

subChannel (
updateChannel ("é
AAPhoneLoginResultREQ
channel (	
phone (	
clientConnectionId (
platform (	

proVersion (	

libVersion (	
appCode (
deviceId (	
area	 (

subChannel
 (
updateChannel ("Ã
MergePlayerInfoPROTO
appCode (
channel (	
username (	
platform (	
clientConectionId (
nickname (	
headImageUrl (	
sex (
lastLoginTime	 ("”
AIMergePlayerInfoREQ
unionidAccountid (
openidAccountid (I

playerInfo (25.com.kodgames.message.proto.auth.MergePlayerInfoPROTO"
IAMergePlayerInfoRES
result (
oldAccountid (
newAccountid (I

playerInfo (25.com.kodgames.message.proto.auth.MergePlayerInfoPROTO"”
IGMergePlayerInfoREQ
unionidAccountid (
openidAccountid (I

playerInfo (25.com.kodgames.message.proto.auth.MergePlayerInfoPROTO"
GIMergePlayerInfoRES
result (
oldAccountid (
newAccountid (I

playerInfo (25.com.kodgames.message.proto.auth.MergePlayerInfoPROTO"7
ICEncryptSYN
encryptType (

encryptKey ("_
GACreateAreaAccountSYN
	accountId (
area (
unionId (	
developerId (	"M
GACreateAreaTestAccountSYN
area (
appCode (
username (	"=
AIClientDisconnectSYN
connectionId (
reason ("?
CIVerifyCodeREQ
phone (	
type (
appCode ("[
IAVerifyCodeREQ
phone (	
clientConnectionId (
type (
appCode ("=
AIVerifyCodeRES
result (
clientConnectionId ("!
ICVerifyCodeRES
result ("t
CIBindPhoneREQ
phone (	
oldPhone (	

verifyCode (	
area (
type (
	accountId ("
IABindPhoneREQ
phone (	
oldPhone (	
clientConnectionId (

verifyCode (	
area (
type (
	accountId ("‚
AABindPhoneResultREQ
phone (	
oldPhone (	
clientConnectionId (
area (
type (
	accountId ("
AIBindPhoneRES
result (
clientConnectionId (
phone (	
oldPhone (	
type (
	accountId (
roleIds ("/
ICBindPhoneRES
result (
phone (	"N
CIQueryPlayerInfoREQ
oldBindPhone (	

verifyCode (	
area ("t
IAQueryPlayerInfoREQ
oldBindPhone (	

verifyCode (	
clientConnId (
roleId (
area ("R
AAQueryPlayerInfoREQ
oldBindPhone (	
clientConnId (
roleId ("]
AIQueryPlayerInfoRES
result (
	oldRoleId (
sign (	
clientConnId ("1
CIBindOldPlayerREQ
sign (	
phone (	"$
ICBindOldPlayerRES
result ("G
IABindOldPlayerREQ
sign (	
phone (	
clientConnId (":
AIBindOldPlayerRES
result (
clientConnId ("B
CIBindDingTalkREQ
	accountId (
code (	
area ("^
IABindDingTalkREQ
	accountId (
code (	
area (
clientConnectionId ("c
AIBindDingTalkRES
result (
clientConnectionId (
	accountId (
roleIds ("#
ICBindDingTalkRES
result ("(
CIAccountHuTongCodeREQ
roleId ("6
ICAccountHuTongCodeRES
result (
code (	">
IAAccountHuTongCodeREQ
roleId (
clientConnId ("L
AIAccountHuTongCodeRES
result (
clientConnId (
code (	"M
CIAccountHuTongByCodeREQ
code (	
	newRoleId (
autoFlag ("*
ICAccountHuTongByCodeRES
result ("c
IAAccountHuTongByCodeREQ
code (	
clientConnId (
	newRoleId (
autoFlag ("@
AIAccountHuTongByCodeRES
result (
clientConnId (BBAuthProtoBuf