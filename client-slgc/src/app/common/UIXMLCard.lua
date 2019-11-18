local UIXMLCard = class("UIXMLCard",function() 
    return ccui.Layout:create()
end)
local bgPath = "art/mahjong_card/bg01/mj_bg2.png"
local TYPE = {
    [1] = "art/mahjong_card/w_%d.png", --万
    [2] = "art/mahjong_card/tiao_%d.png", --条
    [3] = "art/mahjong_card/tong_%d.png", --筒
    [4] = "art/mahjong_card/feng_%d.png", --风  东南西北中发白
    [5] = "art/mahjong_card/hua_%d.png"   --花  春夏秋冬梅兰竹菊
}

--<Cards values="2,2,2,7,7,7,14,14,14,23,23,23,29,0,29"></Cards>
function UIXMLCard:ctor(propertyMap)
    local contentSize = cc.size(0,0)
    local values = string.split(propertyMap.values,",")
    local posX = 0
    local height = 0
    for idx, var in ipairs(values) do
        var = tonumber(var)
        if var ~= 0 then
            local bg = ccui.ImageView:create(bgPath)
            bg:ignoreContentAdaptWithSize(false)
            bg:setAnchorPoint(cc.p(0,0))
            bg:setPositionX(posX)
            self:addChild(bg)
            local size = cc.size(propertyMap.width,propertyMap.height)
            bg:setContentSize(size)
            local type = math.floor(var / 10) + 1
            local value = var % 10
            local facePath = string.format(TYPE[type],value)
            local img = ccui.ImageView:create(facePath)
            img:ignoreContentAdaptWithSize(false)
            img:setAnchorPoint(cc.p(0.5,0.3))
            img:setContentSize(size)
            img:setScale(0.9)
            img:setPosition(cc.p(size.width/2,size.height/2))
            bg:addChild(img)

            posX = posX + size.width
            height = size.height
        else
            posX = posX + 30
        end
    end
    self:setContentSize(cc.size(posX,height))
end


return UIXMLCard