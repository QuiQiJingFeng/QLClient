local super = app.UITableView
local UITableViewEx = class("UITableViewEx",super)

function UITableViewEx.extend(self, cellTemplate,clickFunc)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UITableViewEx)
    self:initWithCellTemplate(cellTemplate,clickFunc)
    assert(self:getDescription() == "ScrollView","must be scrollView")

    return self
end

function UITableViewEx:initWithCellTemplate(cellTemplate,clickFunc)
    self._clickFunc = clickFunc
    self._cellTemplate = cellTemplate
    local children = self:getChildren()
    self._cellNode = children[1]
    self._cellSize = self._cellNode:getContentSize()
    self._cellNode:setVisible(false)
    self._tableViewSize = self:getContentSize()
    self._cellNodeAnchor = self._cellNode:getAnchorPoint()
    self._container = self:getInnerContainer()
    self:setScrollBarEnabled(false)

    --间隔默认0个像素
    self:setDeltUnit(0)
    self:setDeltUnitFlix(0)

    --默认竖直滑动
    self:setVirtical(self:getDirection() == ccui.ScrollViewDir.vertical)

    self._datas = {}
    self._usedCell = {}

    self:addEventListener(function(sender, eventType)
        if eventType ==  ccui.ScrollviewEventType.containerMoved then
            self:update()
        elseif eventType == ccui.ScrollviewEventType.autoscrollEnded then
            if self._scrollItemToCenter then
                self:scrollItemToCenter()
            end
        end
    end)
end

function UITableViewEx:setDeltUnitFlix(deltFlix)
    self._deltFlix = deltFlix
end

function UITableViewEx:update(dt)
    if #self._datas <= 0 then
        return
    end
    local containPos = cc.p(self._container:getPosition())
    if not self._containerPos then
        self._containerPos = containPos
        return
    end
    if cc.pGetDistance(self._containerPos,containPos) == 0 then
        return
    end

    self:checkRemoveCell()
    self:checkAddCell()
end

--每行/列多少个cell
function UITableViewEx:perUnitNums(num)
    --为了避免出现 N%N==0 的问题这里应该+1
    self._perNum = num
end

function UITableViewEx:updateDatas(datas)
    self:clear()
    self._datas = datas
 
    local num = #self._datas
    local size = clone(self._tableViewSize)
    --行或者列的个数
    local realNum = math.ceil(num/self._perNum)
    if self._isVertical then
        size.height = realNum * self._cellSize.height + (realNum - 1) * self._deltUnit
    else
        size.width = realNum * self._cellSize.width + (realNum - 1) * self._deltUnit
    end
    self:setInnerContainerSize(size)
    if self._isVertical then
        self:jumpToPercentVertical(0)
    else
        self:jumpToPercentHorizontal(0)
    end
    self:checkAddCell()
end

--获取中间位置需要显示的cell 的Idx
function UITableViewEx:getCenterPosIdx()
    return 1
end


function UITableViewEx:getCellPosByIndex(idx)
    local size = self:getInnerContainerSize()
    local posX,posY = self._cellNode:getPosition()
    local realNum = math.ceil(idx/self._perNum)
    local reduce = math.ceil(idx % self._perNum)
    reduce = reduce ~= 0 and reduce or self._perNum
    if self._isVertical then
        local distance = realNum * self._cellSize.height + (realNum - 1)*self._deltUnit
        posY = size.height - distance + self._cellNodeAnchor.y * self._cellSize.height

        posX = (reduce-1) * self._cellSize.width + (reduce -1)* self._deltFlix + posX
    else
        posX = (realNum-1) * self._cellSize.width + (realNum - 1) * self._deltUnit + posX
        posY = posY - ((reduce-1) * self._cellSize.height + (reduce -1)* self._deltFlix)
    end

    local targetPos = cc.p(posX,posY)
    local boundingBox = {x = posX - self._cellNodeAnchor.x * self._cellSize.width,
                         y = posY - self._cellNodeAnchor.y *self._cellSize.height,
                         width = self._cellSize.width, height = self._cellSize.height
                        }
    return targetPos,boundingBox
end

--[[
example:
    Cell编写
    local UITableViewCell = app.UITableViewCell
    local UITestSceneCell = class("UITestSceneCell",UITableViewCell)

    function UITestSceneCell:_initialize()
        self._title = seekNodeByName(self,"BitmapFontLabel_PlayType","ccui.TextBMFont")
    end

    -- 整体设置数据
    function UITestSceneCell:updateData(data)
        self._title:setString(data.title)
    end
    

    return UITestSceneCell

    多行多列列表
    local tbScrollView = seekNodeByName(self,"tbScrollView","ccui.ScrollView")
    self._tbScrollView = UITableViewEx.extend(tbScrollView,UITestSceneCell)
    --如果是竖直滑动 则一行有两个Item,否则则是一列有两个item
    self._tbScrollView:perUnitNums(2)
    self._tbScrollView:updateDatas({
       {title = 1},{title = 2},{title = 3},
       {title = 4},{title = 5},{title = 6},
       {title = 7}
    })
]]

return UITableViewEx