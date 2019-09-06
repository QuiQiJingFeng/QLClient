local ns = namespace("manager")

--[[
-- 封装本地存储, 提供基于全局数据, 或者用户数据的存储, 需要处理当存储结构产生变化时的兼容性
--]]
local LocalStorage = class("LocalStorage")
ns.LocalStorage = LocalStorage;

--[[**
 * 获取全局数据
 *]]
function LocalStorage.getGlobalData(key, dataClass)
    return LocalStorage._getData(LocalStorage._convertToGlobalKey(key), dataClass, true);
end

--[[**
 * 保存全局数据
 *]]
function LocalStorage.setGlobalData(key, data)
    LocalStorage._setData(LocalStorage._convertToGlobalKey(key), data, true);
end

--[[**
 * 获取用户数据
 *]]
function LocalStorage.getUserData(userId, key, dataClass)
    -- 两个类型检测
    if type(userId) ~= "number" then
        Macro.assetTrue(true, "LocalStorage.setUserData, userId is not a number!")
        return nil;
    end
    return LocalStorage._getData(LocalStorage._convertToUserKey(userId, key), dataClass, true);
end

--[[**
 * 获取用户数据
 *]]
function LocalStorage.getUserDataWithVersion(userId, key, dataClass, version)
    -- 两个类型检测
    if type(userId) ~= "number" then
        Macro.assetTrue(true, "LocalStorage.setUserData, userId is not a number!")
        return nil;
    end
    local data = LocalStorage._getData(LocalStorage._convertToUserKey(userId, key), dataClass, true)
    local differ = data:checkVer(version)
    if differ == 1 then -- 只差一个版本 升级
        data:upgrade()
    elseif differ > 1 then -- 差多个版本，直接丢弃之前的数据
        data:clear()
    end

    return data
end

--[[**
 * 保存用户数据
 *]]
function LocalStorage.setUserData(userId, key, data)
    -- 两个类型检测
    if type(userId) ~= "number" then
        Macro.assetTrue(true, "LocalStorage.setUserData, userId is not a number!")
        return
    end

    LocalStorage._setData(LocalStorage._convertToUserKey(userId, key), data, true);
end

--[[**
 * 获取用户数据, 数据跟进userId和key单独保存
 *]]
function LocalStorage.getSingleUserData(userId, key, dataClass)
    -- 两个类型检测
    if type(userId) ~= "number" then
        Macro.assetTrue(true, "LocalStorage.setUserData, userId is not a number!")
        return nil;
    end
    LocalStorage._getData(LocalStorage._convertToUserKey(userId, key), dataClass, false);
end

--[[**
 * 保存用户数据, 数据跟进userId和key单独保存
 *]]
function LocalStorage.setSingleUserData(userId, key, data)
    -- 两个类型检测
    if type(userId) ~= "number" then
        Macro.assetTrue(true, "LocalStorage.setUserData, userId is not a number!")
        return
    end

    LocalStorage._setData(LocalStorage._convertToUserKey(userId, key), data, false);
end

--[[**
 * 删除用户数据, 数据跟进userId和key单独保存
 *]]
function LocalStorage.removeUserData(userId, key)
    LocalStorage._removeLocalFile(LocalStorage._convertToUserKey(userId, key));
end

-- 过滤一下无法encode的代码
function LocalStorage._checkTable(tbl)
    local new_tbl = {}
    for k, v in pairs( tbl ) do
        if k == "class" then
            -- pass
        elseif type(v) == "table" then
            new_tbl[k] = LocalStorage._checkTable(v)
        elseif type(v) == "function" or type(v) == "userdata" then
            -- pass
        else
            new_tbl[k] = v
        end
    end
    return new_tbl
end

function LocalStorage._convertToGlobalKey(key)
    return "global_" .. key
end

function LocalStorage._convertToUserKey(userId, key)
    return "user_" .. userId .. "_" .. key;
end

--[[**
 * 解决两个问题。
 * 1、数据类的某个成员重命名了的话，读出来的会是undefined，这是必须得有个默认值
 * 2、读出来的是个json，只有数据，没有函数。严格来说不是调用者想要的类（甚至导致报错）。所以正确的做法应该是new一个目标类，然后逐字段赋值。
 *]]
function LocalStorage._setLoadedValue(newData, loadData)
    if type(newData) ~= "table" and type(loadData) ~= "table" then
        Macro.assetTrue(true, "LocalStorage._setLoadedValue, newData or loadData is not a table!")
        return nil;
    end

    -- 将加载到的数据填充到接收数据的table中去
    for k, v in pairs( loadData ) do
        -- 接收数据的值跟加载到值相同的时候赋值，或者接收数据的table中没有对应数据的时候也赋值
        -- 这里看情况进行相关的修改
        if type( newData[k] ) == type( loadData[k] ) or newData[k] == nil then
            newData[k] = loadData[k]
        end
    end

    return newData;
end

--[[**
 * 获取数据
 *]]
function LocalStorage._getData(key, dataClass, userDefault)
    if type(dataClass) ~= "table" or dataClass.new == nil then
        Macro.assetTrue(true, "LocalStorage._getData, dataClass is not a class!")
        return nil;
    end

    -- 加载本地数据，如果数据是有效值，填充到dataClass
    local res = dataClass.new()
    local jsonstr = ""

    -- 本地模拟器采用文件存储
    if device.platform == "windows" then 
        userDefault = false 
    end 

    if userDefault then
        -- 从UserDefault加载
        local inst_userDefault = cc.UserDefault:getInstance()
        jsonstr =  inst_userDefault:getStringForKey(key)
    else
        -- 本地文件加载
        jsonstr = LocalStorage._loadFromLocalFile(key)
    end

    if jsonstr == "" then
        return res;
    end

    return LocalStorage._setLoadedValue(res, json.decode(jsonstr))
end

--[[**
 * 保存数据
 *]]
function LocalStorage._setData(key, data, userDefault)
    if type(data) ~= "table" or data.new == nil then
        Macro.assetTrue(true, "LocalStorage._setData, data is not a class!")
        return
    end
    
    local tbl = LocalStorage._checkTable(data)

    -- 本地模拟器采用文件存储
    if device.platform == "windows" then 
        userDefault = false 
    end 

    if userDefault then
        -- 保存到UserDefault
        local jsonStr = json.encode(tbl)
        cc.UserDefault:getInstance():setStringForKey(key, jsonStr)
        cc.UserDefault:getInstance():flush()
        local test = cc.UserDefault:getInstance():getStringForKey(key)
        if test ~= jsonStr then
            assert("storage failed")
        else
            test = test.."successful"
        end
    else
        -- 保存到本地文件
        LocalStorage._saveToLocalFile(key, json.encode(tbl))
    end    
end

--[[
-- 从本地文件加载数据
--]]
function LocalStorage._loadFromLocalFile(fileName)
    return cc.FileUtils:getInstance():getStringFromFile(LocalStorage._getLocalFilePath(fileName)) or "";
end

--[[
-- 保存数据到本地文件
--]]
function LocalStorage._saveToLocalFile(fileName, value)    
    cc.FileUtils:getInstance():writeStringToFile(value, LocalStorage._getLocalFilePath(fileName));
end

--[[
-- Remove本地文件
--]]
function LocalStorage._removeLocalFile(fileName)    
    cc.FileUtils:getInstance():removeFile(LocalStorage._getLocalFilePath(fileName));
end

function LocalStorage._getLocalFilePath(fileName)
    return cc.FileUtils:getInstance():getAppDataPath() .. fileName;
end