local BaseLocalData = require("app.kod.data.BaseLocalData")
local TestData = class("TestData", BaseLocalData)

local VVVV = 1
function TestData:ctor()
    BaseLocalData:ctor()
    self.mydata = "hello"
end

function TestData:upgrade()
    self.__ver = VVVV
    self.mydata = "olleh"
end

function TestData:clear()
    self.__ver = VVVV
    self.mydata = "clear"
end

local super = require("core.TestCaseBase")
local cases = {}

local roleId = 10000
cases["set Test"] = function ()
    local data = TestData.new()
    manager.LocalStorage.setUserData(roleId, "TestData", data);
    tlog.info("data.__ver : "..data.__ver)
    tlog.info("data.mydata : "..data.mydata)
    local getData = manager.LocalStorage.getUserData(roleId, "TestData", TestData);
    tlog.info("getData.__ver : "..getData.__ver)
    tlog.info("getData.mydata : "..getData.mydata)
    return getData.mydata == "hello"
end

cases["upgrade Test"] = function ()
    local data = manager.LocalStorage.getUserData(roleId, "TestData", TestData);
    tlog.info("data.__ver : "..data.__ver)
    tlog.info("data.mydata : "..data.mydata)
    local getData = manager.LocalStorage.getUserDataWithVersion(roleId, "TestData", TestData, VVVV);
    tlog.info("getData.__ver : "..getData.__ver)
    tlog.info("getData.mydata : "..getData.mydata)
    manager.LocalStorage.setUserData(roleId, "TestData", getData);
    return getData.mydata == "olleh"
end

cases["clear Test"] = function ()
    local data = manager.LocalStorage.getUserData(roleId, "TestData", TestData);
    tlog.info("data.__ver : "..data.__ver)
    tlog.info("data.mydata : "..data.mydata)
    local getData = manager.LocalStorage.getUserDataWithVersion(roleId, "TestData", TestData, 100);
    tlog.info("getData.__ver : "..getData.__ver)
    tlog.info("getData.mydata : "..getData.mydata)
    manager.LocalStorage.setUserData(roleId, "TestData", getData);
    return getData.mydata == "clear"
end

-- cases[""] = function ()
    
-- end

local BaseLocalDataTest = class("BaseLocalDataTest", super)

function BaseLocalDataTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return BaseLocalDataTest