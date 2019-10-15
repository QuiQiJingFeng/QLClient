---@alias Handler fun(type: string, data: any):void
---@param event string | "'onClosed'" | "'onData'"
---@param handler Handler | "function(type, data) print(data) end"
function addEventListener(event, handler)
end

addEventListener("onClosed","")