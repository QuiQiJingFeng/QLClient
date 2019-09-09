local LocalStorage = {}

function LocalStorage:setRoleId(roleId)
    self._roleId = tostring(roleId)
end

function LocalStorage:saveDataByKey(key,data)
    key = self._roleId .. ":" .. key
    local jsonStr = json.encode(data)
    cc.UserDefault:getInstance():setStringForKey(key, jsonStr)
    cc.UserDefault:getInstance():flush()
end

function LocalStorage:loadDataFromKey(key)
    key = self._roleId .. ":" .. key
    local jsonStr = cc.UserDefault:getInstance():getStringForKey(key)
    if jsonStr == "" then
        return
    end
    return json.decode(jsonStr)
end

return LocalStorage