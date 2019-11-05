local super = require("core.TestCaseBase")
local cases = {}

cases["背包假数据"] = function ()
    if UIManager:getInstance():getIsShowing("UIBackpack") == false then
        return false
    end
    local ui = UIManager.getInstance():getUI('UIBackpack')
    local event = {}
    event = {
        item = {
            {
                id = "83886081",
                uid = "1",
                count = 3,
                content = "",
                createTime = 1531900700000,
                destroyTime = 1532073526000,
                desc = ""
            },
            {
                id = "83886082",
                uid = "2",
                count = 6,
                content = "",
                createTime = 1531900700000,
                destroyTime = 1532073537000,
                desc = "",
            },
        },
    }
    
    local resPack = net.protocol.GCQueryRoleItemsRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    game.service.BackpackService.getInstance():_onGCQueryRoleItemsRES(response);
    return tshould.equalnil("listitem add success")
end

cases["假实物奖励数据"] = function ()
    if UIManager:getInstance():getIsShowing("UIBackpack") == false then
        return false
    end
    local ui = UIManager.getInstance():getUI('UIBackpack')
    local event = {}
    event = {
        goodsList = {
            {
                goodUID = "asdf1",
                time = 0,
                goods = "一台iphoneX",
                imgae = "",
                order = "",
                status = 0,
                phone = "",
                name = "asdf",
                address = "",
                logistics = "",
                status = 2                
            },
        },
    }
    
    local resPack = net.protocol.GCQueryGoodsRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    game.service.GiftService.getInstance():_onGCQueryGoodsRES(response);
    return tshould.equalnil("listitem add success")
end


local UIBackpackTest = class("UIBackpackTest", super)

function UIBackpackTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    -- self:sorted({
    --     "example! hide btn Test",
    --     "example! show btn Test",
    -- })
end

return UIBackpackTest
