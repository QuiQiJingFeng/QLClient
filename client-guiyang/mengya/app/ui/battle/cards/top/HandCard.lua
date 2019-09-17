local HandCard = class("HandCard")

function HandCard:init()
end

function HandCard:setData(data)
    if data.isLastCard then
        app.Util:scheduleOnce(function() 
            self:setPositionX(self:getPositionX() + 3)
        end,0,self)
    end
end

return HandCard