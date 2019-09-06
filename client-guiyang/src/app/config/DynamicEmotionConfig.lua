local DynamicEmotionConfig = {}

local config = {
    "3002",
    "3004",
    "4004",
    "4010",
    "3009",
    "3010",
    "3012",
    "3013",
    "3014",
    "3015",
    "4016",
    "3020",
    "3022",
    "3023",
    "4003",
    "4005",
    "4006",
    "4008",
    "4011",
    "4014",
}


 
for i, value in ipairs(config) do
    local plist = "art/dynamic_emotion/"..value..".plist"
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
end

DynamicEmotionConfig.isDynamic = true


-- 获取支持的表情数量
DynamicEmotionConfig.getCount = function()
	return #config
end

DynamicEmotionConfig.getTexture = function(index)
    return "art/emotion/bq_"..tostring(index)..".png"
end

DynamicEmotionConfig.getFrame = function(index)
    local name = string.format(config[index+1].."1000%d.png",1)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    return frame
end

DynamicEmotionConfig.getFixPosList = function()
    local mvlist = {
                    [1] = {x=20,y=0,},
                    [2] = {x=-20,y=0,},
                    [3] = {x=-20,y=-20},
                    [4] = {x=20,y=0}
                }
    return mvlist
end

DynamicEmotionConfig.getAnimation = function(index)
    local animation = cc.Animation:create()
    for i = 1, 10 do
        local name = string.format(config[index+1].."1000%d.png",i)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
        if not frame then
            break
        end
        animation:addSpriteFrame(frame)
    end
    animation:setDelayPerUnit(0.2)--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame(true)
    local action = cc.Animate:create(animation) 
    local seq = cc.Sequence:create(action,action:clone())
    return seq
end

return DynamicEmotionConfig