local ProtobufLib = require("protobuf")

----------------------------
-- 管理所有支持的网络协议类型
----------------------------
local ProtocolManager = class("ProtocolManager")
namespace("net.core").ProtocolManager = ProtocolManager;

-- 单例，静态函数
-- self.static instance: ProtocolManager;
local _instance = nil

function ProtocolManager.create()
    if _instance ~= nil then
        return;
    end
    _instance = ProtocolManager.new();
    _instance:initialize()
end

function ProtocolManager.destroy()
    _instance = nil;
end

function ProtocolManager.getInstance()
    return _instance;
end

function ProtocolManager:ctor()
    --[[
    -- 协议类型信息Map，
    -- Key：协议Id，
    -- Value：协议类和Protobuf协议类
    --]]
    self._structMap = {}
    self._protoMap = {}
end

-- 初始化
-- @return boolean
function ProtocolManager:initialize()
    -- -- 初始化错误码
    -- kodUtil.ErrorCode.initMap();
    -- kodUtil.PlatformErrorCode.initMap();

    -- 初始化协议信息
    -- local protoBuf: any = laya.utils.Browser.window.dcodeIO.ProtoBuf;
    self._protoMap = {}

    self:registerProtocolFile("pb/auth.pb")
    self:registerProtocolFile("pb/activity.pb")
    self:registerProtocolFile("pb/game.pb")
    self:registerProtocolFile("pb/room.pb")
    self:registerProtocolFile("pb/marquee.pb")
    self:registerProtocolFile("pb/server.pb")
    self:registerProtocolFile("pb/contact.pb")
    self:registerProtocolFile("pb/notice.pb")
	self:registerProtocolFile("pb/battle.pb")
	self:registerProtocolFile("pb/chat.pb")
    self:registerProtocolFile("pb/club.pb")
    self:registerProtocolFile("pb/push.pb")
    self:registerProtocolFile("pb/campaign.pb")
    self:registerProtocolFile("pb/replay.pb")
    self:registerProtocolFile("pb/gold.pb")

    -- 注册协议
    for _, v in pairs(net.protocol) do
        if v.CLZ_CODE ~= nil then
            self:registerProtocolClass(v, v.CLZ_CODE)
        end
    end

    self:registerProtocolStruct("MatchPlaybackProto", "com.kodgames.message.proto.battle.MatchPlaybackPROTO");
    self:registerProtocolStruct("FixedMatchPlaybackProto", "com.kodgames.message.proto.battle.FixedMatchPlaybackPROTO");
    self:registerProtocolStruct("BanGameplayPROTO", "com.kodgames.message.proto.club.BanGameplayPROTO");

    self:registerProtocolStruct("BCRoomPlayerInfoSYN", "com.kodgames.message.proto.room.BCRoomPlayerInfoSYN");
    self:registerProtocolStruct("BCMatchResultSYN", "com.kodgames.message.proto.battle.BCMatchResultSYN");
    return true;
end

-- 通过协议Id获取对应的协议类
-- @param opCode: number
-- @return class
function ProtocolManager:getProtocolClass(opCode)
    if self._protoMap[opCode] == nil then
        return nil;
    end
    return self._protoMap[opCode]._protoClass;
end

-- 通过协议Id获取对应的Protobuf协议类
-- @param opCode: number
-- @return class
function ProtocolManager:getProtocolBufClassName(opCode)
    if self._protoMap[opCode] == nil then
        return nil;
    end
    return self._protoMap[opCode]._protoBufClassName;
end

-- -- 通过协议Id获取对应的协议类
-- function ProtocolManager:getProtocolStruct(name: string): any {
--     // if (self._protoMap.contains(opCode) == false)
--     //     return nil;
--     return self._structMap.get(name)[0];
-- }

-- 通过协议Id获取对应的Protobuf协议类
-- function ProtocolManager:getProtocolBufStruct(name: string): any {
--     // if (self._protoMap.contains(opCode) == false)
--     //     return nil;
--     return self._structMap.get(name)[1];
-- end

-- 通过协议Id实例化对应的Protobuf协议类
-- function ProtocolManager:instantiateProtocolBufStruct(name: string) {
--     local protolBufClass = self.getProtocolBufStruct(name);
--     return new protolBufClass;
-- end

--[[
function ProtocolManager:uploadRelatedData()
    local data = ""
    local fileUtils = cc.FileUtils:getInstance()   
    local downloadDir = "download"
    if loho.getDownloadDir then downloadDir = loho.getDownloadDir() end -- 支持可配置下载目录
    if fileUtils.getFileListInDirectory then
        data = fileUtils:getFileListInDirectory(fileUtils:getAppDataPath() .. downloadDir .. "/")
        data = data .. fileUtils:getFileListInDirectory(fileUtils:getAppDataPath() .. downloadDir .. "_temp/")
    end
    data = data .. fileUtils:getStringFromFile(fileUtils:getAppDataPath() .. downloadDir .. "/update.manifest")
    Logger.uploadFile(data)
end]]

function ProtocolManager:registerProtocolFile(pbFileName)
    local path = cc.FileUtils:getInstance():fullPathForFilename(pbFileName)
    if Macro.assertTrue(path == nil or path == "", "Missing pb file,"..pbFileName) then
        --self:uploadRelatedData()
        return
    end

    local pbFile = cc.FileUtils:getInstance():getStringFromFile(path)
    if Macro.assertTrue(pbFile == nil or pbFile == "", "Empty pb file,"..pbFileName) then
        --self:uploadRelatedData()
        return
    end

    ProtobufLib.register(pbFile)
    return pbFile
end

-- @param protoClass: any
-- @param protoBufClassName: any
function ProtocolManager:registerProtocolClass(protoClass, protoBufClassName)
    local data = {};
    data._protoClass = protoClass;
    data._protoBufClassName = protoBufClassName;
    self._protoMap[protoClass.OP_CODE] = data;
    return Macro.assertFalse(ProtobufLib.check(protoBufClassName), "Missing pbClass,"..protoBufClassName)
end

-- @param name: string
-- @param protoStruct: any
-- @param protoBufStruct: any
function ProtocolManager:registerProtocolStruct(name, protoBufClassName)
     self._structMap[name] = protoBufClassName;
     return Macro.assertFalse(ProtobufLib.check(protoBufClassName), "Missing pbClass,"..protoBufClassName)
end

function ProtocolManager:decodeProtocolStruct(name, buffer)
	if self._structMap[name] == nil then
		return nil
	end

	local pbClassName = self._structMap[name]
	return ProtobufLib.decode_all(pbClassName, buffer)
end
