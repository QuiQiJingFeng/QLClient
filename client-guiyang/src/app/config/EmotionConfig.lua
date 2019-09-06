--[[
表情图片
--]]
cc.SpriteFrameCache:getInstance():addSpriteFrames("art/emotion.plist")

local EmotionConfig = class("EmotionConfig")

-- 获取支持的表情数量
EmotionConfig.getCount = function()
	return 32;
end

EmotionConfig.getTexture = function(index)
	return "art/emotion/bq_"..tostring(index)..".png"
end

return EmotionConfig