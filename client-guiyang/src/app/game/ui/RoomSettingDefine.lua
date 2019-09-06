local RoomRoundSetting = class("RoomRoundSetting")
local GameTypeSetting = class("GameTypeSetting")
local RuleOption = class("RuleOption")
local RuleSetting = class("RuleSetting")
local room = {
    --------------------------------------------------------
    -- 局数/圈数配置
    RoomRoundSetting = RoomRoundSetting,
    ---------------------------------------------------------
    -- 一个地区的玩法配置
    GameTypeSetting = GameTypeSetting,
    ---------------------------------------------------------
    -- 一组个规则
    RuleOption = RuleOption,
    ---------------------------------------------------------
    -- 地区下某个玩法的具体规则
    RuleSetting = RuleSetting,
}

-------------------------RoomRoundSetting---------------------------
function RoomRoundSetting:ctor(type, roundOrTimes, value, realValue)
    -- 选项类型名
    self._type = type
    -- 房间是按照全计算,还是局
    self._roundOrTimes = roundOrTimes
    -- 前后端交互值
    self._value = value
    -- 圈/局数量
    self._realValue = realValue
end

-------------------------GameTypeSetting---------------------------
function GameTypeSetting:ctor(gameType, ruleSetting)
    -- 玩法类型吗名
    self._gameType = gameType
    -- 规则配置
    self._ruleSetting = ruleSetting
end

-------------------------RuleOption---------------------------
-- sufficient 添加一个充分条件，如果该充分条件满足，则该项必会被选中
--------------------------------------------------------------
function RuleOption:ctor(option, condition, replaceOption, sufficient)
    -- 规则名
    self._option = option
    -- 规则开启条件,支持表达式
    self._condition = condition
    -- 当规则选中的时候,在牌局界面显示的规则列表中,替代某条规则的显示
    self._replaceOption = replaceOption
    -- 开启的充分条件，即满足该条件时，改项必须选中
    self._sufficient = sufficient or false;
end

function RuleOption:hasCondition()
    return self._condition ~= nil and self._condition ~= ""
end

function RuleOption:hasReplaceOption()
    return (self._replaceOption and self._replaceOption ~= "")
end

function RuleOption:hasSufficient()
    return (self._sufficient and self._sufficient ~= "")
end

-------------------------RuleSetting---------------------------
function RuleSetting:ctor(defaultOption, group, mustSelected)
    -- 默认选中规则
    self._defaultOption = defaultOption
    -- 规则组，其中的选项是互斥关系，只能选中一个
    self._group = group
    -- 是否必须选择一项
    self._mustSelected = mustSelected
end

function RuleSetting:hasDefaultOption()
    return self._defaultOption and self._defaultOption ~= ""
end

function RuleSetting:getOption(option)
    for i = 1, #self._group do
        if self._group[i]._option == option then
            return self._group[i]
        end
    end
    return nil
end

return room