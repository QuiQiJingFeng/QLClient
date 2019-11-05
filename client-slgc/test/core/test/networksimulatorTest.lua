local super = require("core.TestCaseBase")
local cases = {}
cases["simulator request test"] = function ()
	local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
	request:getProtocol():setData('test', "123", '', '', nil);
    request.relogin = false
    lohotest.netsimulator.request(request, true);
    return true    
end

local NetworkSimulatorTest = class("NetworkSimulatorTest", super)

function NetworkSimulatorTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    -- self:sorted({
    --     "lru add Test",
    --     "lru find Test",
    --     "lru over max Test",
    -- })
end

return NetworkSimulatorTest

