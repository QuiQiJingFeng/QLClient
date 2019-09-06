
±
server.proto!com.kodgames.message.proto.server"V
DbPROTO
type (	
name (	
address (	
user (	
password (	"ˆ
ServerConfigPROTO
type (

id ( 
listen_socket_for_server (	
listen_http_for_server (	
listen_http_for_gmt (	
listen_http_for_client (	$
listen_web_socket_for_client (	 
listen_socket_for_client (	!
address_socket_for_client	 (	
address_http_for_client
 (	%
address_web_socket_for_client (	!
address_socket_for_server (	
address_http_for_server (	
address_http_for_gmt (	7
dbs (2*.com.kodgames.message.proto.server.DbPROTO
area ("Z
SSGetLaunchInfoREQD
server (24.com.kodgames.message.proto.server.ServerConfigPROTO"j
SSGetLaunchInfoRES
result (D
server (24.com.kodgames.message.proto.server.ServerConfigPROTO"[
SSRegisterServerREQD
server (24.com.kodgames.message.proto.server.ServerConfigPROTO"V
SSServerListSYNCB
list (24.com.kodgames.message.proto.server.ServerConfigPROTO"$
SSServerDisconnectSYNC

id ("*
SSExchangePeerInfoSYNC
serverID ("E
ClientDisconnectSYN
mixId (
founder (
roleId (")
ServerExceptionSYNC

protocolId ("Œ
PlatformPurchaseREQ
seqId (
playerId (@
keyMap (20.com.kodgames.message.proto.server.ParamKeyValue

billingKey (	"h
PlatformPurchaseRES
result (
seqId (
jsonObj (	
orderId (	
playerId ("+
ParamKeyValue
key (	
value (	"[
SSPUSHNotifySYN
pushType (
roleIds (
notification (	
message (	"E
SGBroadcastMSG
roleId (

protocolId (
message (BBServerProtoBuf