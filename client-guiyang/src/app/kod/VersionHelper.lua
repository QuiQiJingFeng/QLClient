local ns = namespace("kod.VersionHelper")
local Version = require("app.kod.util.Version")


function ns.biggerThanVersion(ver)
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local supportVersion = Version.new(ver)
    return currentVersion:compare(supportVersion) >= 0;		
end

function ns.smallerThanVersion(ver)
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local supportVersion = Version.new(ver)
    return currentVersion:compare(supportVersion) < 0;		
end

function ns.equalToVersion(ver)
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local supportVersion = Version.new(ver)
    return currentVersion:compare(supportVersion) == 0;		
end