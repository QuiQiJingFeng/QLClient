local UIXMLImageView = class("UIXMLImageView",function() 
    return ccui.ImageView:create()
end)
--<Image src="ui/art/img/Icon_Diamonds.png" width=50 height=50 fixY=20 fixX=20/>
function UIXMLImageView:ctor(propertyMap)
    self:ignoreContentAdaptWithSize(false)
    self:loadTexture(propertyMap.src)
    if propertyMap.width then
        local size = cc.size(propertyMap.width,propertyMap.height)
        self:setContentSize(size)
    end
    if propertyMap.fixX or propertyMap.fixY then
        local setPosition = self.setPosition
        self.setPosition = function(node,pos)
            pos.y = pos.y + propertyMap.fixY
            pos.x = pos.x + propertyMap.fixX
            setPosition(node,pos)
        end
    end
end

return UIXMLImageView