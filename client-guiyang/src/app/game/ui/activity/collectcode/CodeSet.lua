local CODE_LEN = 6
local Array = require("ds.Array")
local CodeSet = class("CodeSet")
function CodeSet:ctor(root)
    self._root = root
    self._textArray = Array.new()
    for i = 1, CODE_LEN, 1 do
        local code = seekNodeByName(root, "Image_" .. i, "ccui.ImageView")
        if Macro.assertFalse(code, "find code failed! index is " .. i) then
            local text = seekNodeByName(code, "Text", "ccui.Text")
            if Macro.assertFalse(text, "find code text failed! index is .. " .. i) then
                self._textArray:add(text)
            end
        end
    end
end

function CodeSet:setCodes(texts)
    local len = #texts
    if Macro.assertFalse(CODE_LEN == len, 'texts length illegle, len = ' .. len) then
        self._textArray:forEach(function(item, index)
            item:setString(texts[index])
        end)
    end
    -- print("Code Set:" .. table.concat(texts, "、"))
end

function CodeSet:setVisible(value)
    self._root:setVisible(value or false)
end

return CodeSet