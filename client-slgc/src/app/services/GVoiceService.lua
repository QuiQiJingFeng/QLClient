local GVoiceService = class("GVoiceService")

local _instance = nil
function GVoiceService:getInstance()
    if not _instance then
        _instance = GVoiceService.new()
    end

    return _instance
end

--appId 1686721846
--appKey c3b8ba424f225f256654a188b52fca83
--udp://cn.voice.gcloudcs.com:10001 SetServerInfo
function GVoiceService:ctor()
    
end

return GVoiceService