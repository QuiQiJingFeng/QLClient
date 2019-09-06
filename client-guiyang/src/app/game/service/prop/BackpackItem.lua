local PropObject = require("app.game.service.prop.PropObject")
local BackpackItem = class("BackpackItem")

function BackpackItem:ctor()
    self.prop = nil                           -- 保存背包项
    self.num = 0                              -- 数量
    self.isPartically = false                 -- 是否为实物奖励
end

function BackpackItem:setData( prop, num , isPartically)
    self.prop = prop                           -- 保存背包项
    self.num = num                              -- 数量
    self.isPartically = isPartically
end

function BackpackItem:clone(obj)
    if obj.prop.class ~= nil then
        local propObject = obj.prop.class:create()
        propObject:clone(obj.prop) 
        self.prop = propObject                          -- 保存背包项        
    else
        self.prop = obj
    end

    if obj.num ~= nil then
        self.num = obj.num                              -- 数量
    else
        self.num = 1
    end

    self.isPartically = obj.isPartically
end

return BackpackItem