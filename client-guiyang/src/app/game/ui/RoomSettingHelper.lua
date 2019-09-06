local RoomSettingHelper = {}
local room = require( "app.game.ui.RoomSettingDefine" )
room.RoomSettingHelper = RoomSettingHelper

local ROOM_ROUND_SETTING = config.GlobalConfig.getRoomSetting().ROOM_ROUND_SETTING
local GamePlay = config.GlobalConfig.getRoomSetting().GamePlay
local GAME_TYPE_SETTING = config.GlobalConfig.getRoomSetting().GAME_TYPE_SETTING
local RULES_NOT_TO_SHOW = config.GlobalConfig.getRoomSetting().RULES_NOT_TO_SHOW

-------------------------RoomSettingHelper---------------------------
function RoomSettingHelper.getRoomRoundSettings(rules)
    for k, v in pairs( ROOM_ROUND_SETTING ) do
        for k1, v1 in pairs( rules ) do
            if v1 == v._type then
                return v
            end
        end
    end
    return nil
end

-- todo: 这里要把gameTypes换成根据地区来取的
--[[
    @desc: 这个方法改成第一个参数还是现有玩法的type，但是第二个是配置，可以提取不同的配置
    author:{马驰骋}
    time:2017-09-13 16:55:51
    return keys=原来的gameTypes数组，gameTypes=配置
]]
function RoomSettingHelper.getGameTypes()
    local areaId = 0
    if MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()) then
        areaId = game.service.LocalPlayerService:getInstance():getArea()        
    else 
        areaId = config.GlobalConfig.getConfig().AREA_ID; 
    end
    local keys = MultiArea.getGameTypeKeys(areaId)
    local gameTypes = MultiArea.getGameTypeMap(areaId)
    return keys, gameTypes
end

function RoomSettingHelper.getRuleSetting(gameType)
    for k, gameTypeSetting in pairs( GAME_TYPE_SETTING ) do
        if gameTypeSetting._gameType == gameType then
            return gameTypeSetting._ruleSetting
        end
    end

    Logger.info("Invalid game type : " .. tostring(gameType))
    return nil
end

--[[
     * 获取配置项声明所在的元素编号
]]
function RoomSettingHelper.getDeclareIndex(gameType, rule)
    local ruleSetting = RoomSettingHelper.getRuleSetting(gameType)
    if not ruleSetting then
        Logger.info("Invalid game type : " .. tostring(gameType))
        return -1
    end

    for i = 1, #ruleSetting do
        if ruleSetting[i]:getOption(rule) ~= nil then
            return i
        end
    end
    return -1
end

--[[
     * 获取配置项声明所在的元素编号
]]
function RoomSettingHelper.getDeclareItem(gameType, rule)
    local ruleSetting = RoomSettingHelper.getRuleSetting(gameType)
    if not ruleSetting then
        Logger.info("Invalid game type : " .. tostring(gameType))
        return nil
    end

    for i = 1, #ruleSetting do
        if ruleSetting[i]:getOption(rule) ~= nil then
            return ruleSetting[i]
        end
    end
    Logger.info("Invalid rule : " .. rule)
    return nil
end

--[[
     * 获取配置项声明所在的元素编号
]]
function RoomSettingHelper.getDeclareOption(gameType, option)
    local ruleSetting = RoomSettingHelper.getRuleSetting(gameType)
    if not ruleSetting then
        Logger.info("Invalid game type : " .. tostring(gameType))
        return nil
    end

    for i = 1, #ruleSetting do
        local declareOption = ruleSetting[i]:getOption(option)
        if declareOption ~= nil then
            return declareOption
        end
    end
    return nil
end

--[[
     * 获取配置项声明所在的元素编号
]]
function RoomSettingHelper.getDefaultExpression()
    if RoomSettingHelper.defaultExpression == nil then
        for _, gameType in pairs( GAME_TYPE_SETTING ) do
            for _, setting in pairs( gameType._ruleSetting ) do
                local checkDefault = (setting:hasDefaultOption() == false)
                for _, option in pairs( setting._group ) do
                    if option._option == setting._defaultOption then
                        checkDefault = true
                    end
                end

                if checkDefault == false then
                    Logger.info("ROOM_SETTING declare default option error : " .. setting)
                end
            end
        end

        local exp = "local express = {\r\n}\r\n"
        local areaId = game.service.LocalPlayerService:getInstance():getArea();
        local ruleType = MultiArea.getRuleType(areaId)[1]
        for key, v in pairs( ruleType ) do
            exp = exp .. "local "..key .." = false\r\n"
        end
        RoomSettingHelper.defaultExpression = exp
    end

    return RoomSettingHelper.defaultExpression
end

--[[
     * 根据当前选择条件
]]

function RoomSettingHelper.getExpression(gameType, settings)
    local expression = RoomSettingHelper.getDefaultExpression()
    for k, s in pairs( settings ) do
        local declareItem = RoomSettingHelper.getDeclareItem(gameType, s);
        if not declareItem then
            Logger.info("Invalid room setting : " .. s)
            return
        end

        expression = expression .. "local ".. s .. " = true\r\n"
    end
    return expression
end

--[[
     * 处理选项，删除无效的选项，补充默认选项

    新添加两个变量
    @param reverse 禁用判断，如果是禁用的话，不做必须检查，(条件检查，现在应该还有问题，贵阳没有相关实现)
    @param forbidRuleNames 当前禁用的玩法，当有默认选项被禁用的时候，用来选择下一个可用的选项
]]
function RoomSettingHelper.processOptions(gameType, currentOptions, reverse, forbidRuleNames)
    -- 默认值为非禁用判断
    reverse = reverse or false
    -- 默认值为空
    forbidRuleNames = forbidRuleNames or {}
    local settings = {}
    -- 是否第一加载， 不是第一次加载则不跳默认选项
    local firstLoad = false
    if currentOptions == nil then
        currentOptions = {}
        firstLoad = true
    end

    local ruleSetting = RoomSettingHelper.getRuleSetting(gameType)
    if ruleSetting then
        for _, item in pairs( ruleSetting ) do
            while true do
                local hasSetting = false
                for _, currentItem in pairs( currentOptions ) do
                    if item:getOption(currentItem) ~= nil then
                        hasSetting = true
                        local added = false
                        for _, v in pairs( settings ) do
                            if v == currentItem then
                                added = true
                            end
                        end
                        if not added then
                            settings[#settings + 1] = currentItem
                            end
                        end
                    end

                if hasSetting and not reverse then
                    break
                end

                -- TODO-NOTICE 如果是有前置条件的情况下，这里可能需要检查一下
                -- 第一次检查的时候，排除经理设置的情况
                if item:hasDefaultOption() and ((firstLoad and not reverse) or item._mustSelected) then
                    local  declaredOption = item:getOption(item._defaultOption)
                    if declaredOption and declaredOption:hasCondition() then
                        local expression = RoomSettingHelper.getExpression(gameType, settings)
                        if reverse then
                            -- 在禁用模式下，返回值需要反转一下
                            expression = expression.. "function express.func() return not " .. declaredOption._condition .. " end\r\nreturn express\r\n"
                        else
                            expression = expression.. "function express.func() return " .. declaredOption._condition .. " end\r\nreturn express\r\n"
                        end
                        local exp = assert(loadstring( expression ))()
                        if exp.func() == false then
                            break
                        end
                    end

                    if reverse then
                        -- 如果是反转模式的话，当前所有的选项，不能全部在里面，如果全部禁用掉了，会导致前面选中后，后面必选的无法选择
                        -- 所以这里还需要做一次有效性的检查
                        local allSelected = true
                        for i,v in ipairs(item._group) do
                            if table.indexof(settings, v._option) == false then
                                allSelected = false
                                break
                            end
                        end
                        if allSelected then
                            -- 全部移除掉
                            for i,v in ipairs(item._group) do
                                local idx = table.indexof(settings, v._option)
                                table.remove(settings, idx)
                            end
                        end
                        break
                    end

                    -- 非反转选择的后续判断
                    if table.indexof(forbidRuleNames, item._defaultOption) ~= false then
                        -- 你让我选的，我没法去选了！那么就随便选一个吧
                        local success = false
                        for i,v in ipairs(item._group) do
                            if table.indexof(forbidRuleNames, v._option) == false then
                                -- 这个可以选
                                settings[#settings + 1] = v._option
                                success = true
                                break
                            end
                        end
                        -- 全部选项是否都禁用了
                        if Macro.assertTrue(success == false, "mustSelected option[no one can selected!]") then
                            -- 做一个保护，在已经出错的情况下，可以继续下去，将默认选项开放出来，供其选择
                            local idx = table.indexof(forbidRuleNames, item._defaultOption)
                            table.remove(forbidRuleNames, idx)
                        end
                    else
                        settings[#settings + 1] = item._defaultOption
                    end
                end

                break
            end
        end
    end

    return settings
end

--[[
     * 获取指定类型的配置当前是否可以选择
]]
function RoomSettingHelper.isSettingEnabled(gamePlay, settingToCheck, settings, reverse)
    -- 检查依赖项是否有效
    local declareOption = RoomSettingHelper.getDeclareOption(gamePlay, settingToCheck)
    if not declareOption then
        return false
    end

    -- 如果没有前置选项, 默认为可以选中
    if declareOption:hasCondition() == false then
        return true
    end

    local expression = RoomSettingHelper.getExpression(gamePlay, settings)
    if reverse then
        -- 如果是在禁用状态的时候，所有的按钮都是可以点击的，只不过在有效性检查的时候，会处理，如果必须选中，那么会处理
        return true
    end
    expression = expression.. "function express.func() return " .. declareOption._condition .. " end\r\nreturn express\r\n"
    local exp = assert(loadstring( expression ))()
    return exp.func()
end

--[[
     * 从当前配置中提取房间局数设置
]]
function RoomSettingHelper.isRealTimeEnabled(options)
    if options == nil then
        return false
    end

    for _, v in pairs( options ) do
        if v == "REAL_TIME_VOICE" then
            return true
        end
    end

    return false
end

--[[
    显示该box的充分条件是否满足。
]]
function RoomSettingHelper.isSufficientEnabled(gamePlay, key, option)
    -- 检查依赖项是否有效
    local ruleSetting = RoomSettingHelper.getRuleSetting(gamePlay)
    if not ruleSetting then
        return false
    end

    local sufficient = false;
    for i = 1, #ruleSetting do
        local declareOption = ruleSetting[i]:getOption(key)
        if declareOption ~= nil then
            sufficient = declareOption._sufficient or false;
        end
    end

    -- 如果没有前置选项, 默认为可以选中
    if sufficient == false then
        return false
    end

    local expression  = RoomSettingHelper.getExpression(gamePlay, option)
    expression = expression.."function express.func() return " .. sufficient .. " end\r\nreturn express\r\n"
    local exp = assert(loadstring( expression ))()
    return exp.func()
end

--[[
     * 将数字类型的规则显示形式转换为字符串类型
]]
function RoomSettingHelper.convert2OptionValue(optionType)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    local temp = ruleType[optionType]
    if not temp then
        Logger.info("Invalie OptionType : " .. optionType)
        return 0
    end

    return temp[1]
end

--[[
     * 将数字类型的规则显示形式转换为字符串类型(上面的那个并没有用。。)
]]
function RoomSettingHelper.convert2OptionString(optionType)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]

    local result = ""
    table.foreach(ruleType,function (k,v)
        if v[1] == optionType then
            result = k
        end
    end)

    return result
end

--[[
     * 从当前配置中提取房间局数设置
]]
function RoomSettingHelper.getRoomRoundSettingFromOptions(options)
    if options == nil then
        return nil
    end

    for i = 1, #ROOM_ROUND_SETTING do
        for _, v in ipairs( options ) do
            if v == ROOM_ROUND_SETTING[i]._type then
                return ROOM_ROUND_SETTING[i]
            end
        end
    end

    Logger.error("Invalie options : " .. unpack(options))
end

--[[
     * 通过房间参数获取对应的配置
]]
function RoomSettingHelper.getRoomRoundSetting(roundOrTimes, value)
    for i = 1, #ROOM_ROUND_SETTING do
        local setting = ROOM_ROUND_SETTING[i]
        -- 这里有问题，以后再定
        -- setting 里面的roundOrTimes为true  ， true是局数 ， false是圈数
        if setting._roundOrTimes == roundOrTimes and setting._value == value then
            return setting
        end
    end
    Logger.info("Invalie room setting : roundOrTimes ".. value)
end

--[[
     * 
]]
function RoomSettingHelper.getGameTypeFromOptions(options)
    local all = RoomSettingHelper.getGameTypes()
    for i = 1, #options do
        local option = options[i]
        for _, v in ipairs( all ) do
            if v == option then
                return option
            end
        end
    end
    Logger.info("getGameTypeFromOptions Failed")
    return ""
end

--[[
     * 将数字类型的规则显示形式转换为字符串类型
]]
function RoomSettingHelper.convert2OptionValues(optionTypes)
    local optionValues = {}

    -- GameType需要在第一个
    local gameType = RoomSettingHelper.getGameTypeFromOptions(optionTypes)
    if gameType and gameType ~= "" then
        local optionValue = RoomSettingHelper.convert2OptionValue(gameType)
        if optionValue ~= 0 then
            optionValues[#optionValues + 1] = optionValue
        end
    end

    -- 添加其他的
    for _, optionType in ipairs( optionTypes ) do
        if optionType == gameType then
            -- pass
        else
            local optionValue = RoomSettingHelper.convert2OptionValue(optionType)
            if optionValue ~= nil then
                optionValues[#optionValues + 1] = optionValue
            end
        end
    end

    return optionValues
end

--[[
     * 将字符串类型的规则显示形式转换为数字类型
]]
function RoomSettingHelper.convert2OptionType(optionValue)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    for key, v in pairs( ruleType ) do
        local temp = ruleType[key]
        if temp[1] == optionValue then
            return key
        end
    end
    Logger.info("Invalie OptionValue : " .. optionValue)
end

--[[
     * 将字符串类型的规则显示形式转换为数字类型
]]
function RoomSettingHelper.convert2OptionTypes(optionValues)
    local optionTypes = {}
    for _, optionValue in pairs( optionValues ) do
        local optionType = RoomSettingHelper.convert2OptionType(optionValue)
        if optionType ~= nil then
            optionTypes[#optionTypes + 1] = optionType
        end
    end

    return optionTypes
end

--[[
     * 将选项转换为用于发送到服务器的选项
]]
function RoomSettingHelper.convert2ServerGameOptions(gameType, options)
    if options == nil then
        return {}
    end

    local returnOptions = {}
    for i = 1, #options do
        returnOptions[i] = options[i]
    end

    -- 删除房间局数选项
    for i = 1, #ROOM_ROUND_SETTING do
        local j = table.indexof(returnOptions, ROOM_ROUND_SETTING[i]._type)
        if j then
            table.remove( returnOptions, j )
        end
    end

    -- 删除实时语音选项
    for j = 1, #returnOptions do
        if returnOptions[j] == "REAL_TIME_VOICE" then
            table.remove( returnOptions, j )
            break
        end
    end

    -- 添加玩法选项
    returnOptions[#returnOptions + 1] = gameType

    -- 转换为发给服务器的数字值
    return RoomSettingHelper.convert2OptionValues(returnOptions)
end

--[[
     * 将从服务器收到的玩法信息, 转换为选项字符串
]]
function RoomSettingHelper.convert2ClientGameOptions(roundOrTimes, roomCount, serverOptionValues)
    local optionTypes = RoomSettingHelper.convert2OptionTypes(serverOptionValues)
    local roomSetting = RoomSettingHelper.getRoomRoundSetting(roundOrTimes, roomCount)
    if roomSetting then
        table.insert( optionTypes, 2 ,roomSetting._type )
    end
    return optionTypes
end

function RoomSettingHelper.initCreateRoomSettings(createRoomSetting)
    local gameTypes = RoomSettingHelper.getGameTypes()

    -- 移除无效的GameType
    for key, v in pairs( createRoomSetting._ruleMap ) do
        -- Logger.debug("key is : " .. key)
        local finded = false
        for _, v in pairs( gameTypes ) do
            if v == key then
                finded = true
            end
        end
        if not finded then
            -- Logger.debug("delete : " .. createRoomSetting._ruleMap[key])
            createRoomSetting._ruleMap[key] = nil
        end
    end

    -- 检查默认GameType
    if createRoomSetting._ruleMap[createRoomSetting._gameType] == nil then
        createRoomSetting._gameType = gameTypes[1]
    end

    -- 添加缺少的GameType, 更新已存在的GameType
    for _, gameType in pairs( gameTypes ) do
        createRoomSetting._ruleMap[gameType] = RoomSettingHelper.processOptions(gameType, createRoomSetting._ruleMap[gameType])
    end
end

--[[
     * 
]]
function RoomSettingHelper.getRulesLog(rules)
    local function tobin(num)
        local str = ""
        for i = 31, 0, -1 do
            str = str .. bit.band(bit.rshift(num, i), 1)
        end
        return str
    end
    local log = ""
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    for k, rule in pairs( rules ) do
        local data = ruleType[rule]
        if data then
            log = log .."["..data[2].."|"..data[1].."|"..tobin(data[1]).."]\n"
        else
            Logger.info("GetRuleDescs() Failed. Invalid Rule: " .. rule)
        end
    end

    return log
end

--[[
     * 
]]
function RoomSettingHelper.getOptionsDescs(gameType, options)
    local displayOptions = {}

    -- 构造可以现实的选项, 有些选项会替换掉其他选项
    for i = 1, #options do
        displayOptions[i] = options[i]
    end
    for _, option in pairs( options ) do
        local decleardOption = RoomSettingHelper.getDeclareOption(gameType, option)
        if decleardOption then
            if decleardOption:hasReplaceOption() then
                for i, v in ipairs( displayOptions ) do
                    if v == decleardOption._replaceOption then
                        table.remove( displayOptions, i )
                    end
                end
            end
        end
    end

    local result = {}
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    for _, rule in ipairs( displayOptions ) do
        local data = ruleType[rule]
        if data then
            if data[2] ~= "" then
                result[#result + 1] = data[2]
            end
        else
            Logger.info("GetRuleDescs() Failed. Invalid Rule: " .. rule)
        end
    end

    return result
end

-- 获取对应option的中文文本
function RoomSettingHelper.getChineseString(input)
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    local ruleName = RoomSettingHelper.convert2OptionString(input)
    local text = ""
    if ruleType[ruleName] ~= nil then
        text = ruleType[ruleName][2]
    end

    return text
end

--[[
     * 获取用于微信邀请分享的文本
     -- TOTO:现在这里已经没有使用的地方了，如果使用请注意
]]
function RoomSettingHelper.inviteFriends(gameType, rules)
    -- local roomId = BattleService:getInstance().roomId
    local roomId = 000000
    -- local roleName = game.service.LocalPlayerService:getInstance().name

    local rule = RoomSettingHelper.buildLineText(RoomSettingHelper.getOptionsDescs(gameType, rules))
    local msg = ""
    local APP_NAME = "APP_NAME"
    local SHARE_DOWNLOAD = "URL:"
    if --[[game.GameMain:isOpenClipBoardVersion()]] true then
        msg = rule..",房间号【"..roomId.."】,点击复制本条消息，打开《"..APP_NAME.."》就可以直接进入房间！点击"..SHARE_DOWNLOAD.."猛戳下载《"..APP_NAME.."》"
    else
        msg = "房间号:"..roomId..","..rule.."等你激战喽！！！"
    end

    return msg
end

--[[
     * 获取用于微信邀请分享的文本
]]
function RoomSettingHelper.buildLineText(rules)
    local res = ""
    for i = 1, #rules do
        local desc = rules[i]
        -- 空描述不显示
        if desc ~= "" then
            if res == "" then
                -- 第一个描述
                res = desc
            else
                res = res ..",".. desc
            end
        end
    end
    return res
end

--[[
     * 
]]
function RoomSettingHelper.manageRuleLabels(createRoomSetting, maxRulesPerLine)
    maxRulesPerLine = maxRulesPerLine == nil and 255 or maxRulesPerLine
    local rules = {}
    if createRoomSetting._ruleMap[createRoomSetting._gameType] == nil then
        return rules
    end

    for k, v in pairs( createRoomSetting._ruleMap[createRoomSetting._gameType] ) do
        rules[k] = v
    end

    local allGameTypes = RoomSettingHelper.getGameTypes()

    local allDescs = RoomSettingHelper.getOptionsDescs(createRoomSetting._gameType, rules)
    local res = {}
    local group = {}
    local index = 1
    while index <= #allDescs do
        table.insert(group, allDescs[index])
        if index%maxRulesPerLine == 0 or index == #allDescs then
            table.insert(res, RoomSettingHelper.buildLineText(group))
            group = {}
        end
        index = index + 1
    end

    return res
end

-- 获取配置的禁止项
function RoomSettingHelper.getForbidRuleNames(playIds)
    if playIds == nil then
        return {}
    end
    local forbidNames = {};
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getForbidPlay(areaId)[1]
    for i,v in ipairs(playIds) do
        for j,v2 in ipairs(ruleType) do
            if v == v2.gamePlayId then
                table.insert(forbidNames, v2.ruleSetName);
            end
        end
    end
    return forbidNames;
end

return room