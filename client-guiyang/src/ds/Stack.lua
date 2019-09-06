--[[0
    一个简单的 Stack 数据结构，封装了一些常用的函数，写代码更加OOP吧
    目前还没有文件引用它，请暂且不要使用，等待作者自行踩坑，觉得ok再说吧
    create date: 2018/09/12
]]
local M = class("Stack")

function M:ctor(luaTable)
    Macro.assertFalse(false, 'no finished')
    self.innerTable = luaTable or {}
end

function M:push(value)
    table.insert(self.innerTable, value)
end

function M:pop()
    return table.remove(self.innerTable)
end

return M