local UIScrollText = class("UIScrollText")

function UIScrollText.extend(self)
    assert(self:getDescription() == "ScrollView","must be scrollView")

    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIScrollText)
    self:init()
end

function UIScrollText:init()
    self._txtContent = self:getChildByName("txtContent")
    assert(self._txtContent,"txtContent must be none nil")


end

return UIScrollText