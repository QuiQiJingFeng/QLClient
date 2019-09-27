local RuleParse = class("RuleParse")

function RuleParse:ctor(settings)
    self._settings = settings
end

function RuleParse:getDescript()
    local infos = {}
    for _, setting in ipairs(self._settings) do
        local data = app.ConfigManager:getInstance():getRoomSettingConfig(setting)
        table.insert(infos,data.name)
    end
    return table.concat(infos,"、")
end

function RuleParse:getMaxPlayerNum()
    if table.indexof(self._settings,720897) then
        return 2
    end
    if table.indexof(self._settings,720898) then
        return 3
    end
    if table.indexof(self._settings,131073) then
        return 4
    end
end



return RuleParse