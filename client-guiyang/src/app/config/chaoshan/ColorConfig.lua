local M = namespace("config.ColorConfig")

-- 输入框的颜色配置
M.InputField = {
    -- 一般性的，在 LoadCSBNode 之后都会赋值成这个
    Common = {
        InputHolder = cc.c4b(158, 158, 158, 255),
        inputTextColor = cc.c4b(45, 45, 45, 255)
    },

    --[[0
        以下是按照使用场景命名，但是希望后续不再追加，统一使用 Common
        如果要添加，追加的项也不应该使用场景命名，而应该去选择一些通用的名字，例如 HiGH_LIGHT, WHITE 等
    ]]
    White = {
        InputHolder = cc.c4b(158, 158, 158, 255),
        inputTextColor = cc.c4b(208, 200, 203, 255),
    },
}