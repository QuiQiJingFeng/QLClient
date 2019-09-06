--[[
    现在只做一个中转的控制，伪组件
    以后从头做的话，考虑完全组件的方式
]]
local UITouch = {}

local PREPARED_CARD_Y_DELTA = 26

-- 只处理多选的
---------------------------------------------------------------------------------
local UITouchProcessorBase = class("UITouchProcessorBase")
UITouch.UITouchProcessorBase = UITouchProcessorBase

function UITouchProcessorBase:ctor(host)
	self._host = host
	self._offset = PREPARED_CARD_Y_DELTA
end

-- 手牌操作回调:Touchbegan
function UITouchProcessorBase:onHandCardTouchBegan(sender, event)
	local pt = sender:getTouchBeganPosition()
	local cardlist = self._host._playerProcessor._cardList	
	local selectCard = self._host:_getSelectedCard(cardlist, pt)
    -- 多选状态
    if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
        local targetCard = selectCard;

        if table.indexof(self._host._multiSelectList, targetCard) == false then
            -- 没有选中, 继续选择
            if (self._host._multiSelectWillSelectCallback == nil or self._host._multiSelectWillSelectCallback(targetCard, true)) then
				self._host:_onMultiSelectedCard(targetCard, true);
				print("host addr" .. tostring(self._host))
            end
        else
            -- 选中了, 取消选择
            if self._host._multiSelectWillSelectCallback == nil or self._host._multiSelectWillSelectCallback(targetCard, false) then
				self._host:_onMultiSelectedCard(targetCard, false);
				print("host addr" .. tostring(self._host))
            end
        end
    end
end

-- 手牌操作回调:TouchMove
function UITouchProcessorBase:onHandCardTouchMove(sender, event)
end

-- 手牌操作回调:MouseEnd
function UITouchProcessorBase:onHandCardTouchEnd(sender, event)
end

-- 手牌操作回调:TouchCancelled, 当程序切换到后台时触发?
function UITouchProcessorBase:onHandCardTouchCancelled(sender, event)
end

function UITouchProcessorBase:getOffset()
	return self._offset
end


-- 单击出牌
---------------------------------------------------------------------------------
local UITouchProcessorClick = class("UITouchProcessorBase", UITouchProcessorBase)
UITouch.UITouchProcessorClick = UITouchProcessorClick

function UITouchProcessorClick:ctor(host)
    self.class.super.ctor(self, host)
	self._host = host
    -- 先把当前的选牌状态全部清除掉
    self._host:recoverOperatingCard();
end

function UITouchProcessorClick:getOffset()
	-- 多选的情况下正常返回offset
	if self._host._canMulitSelect then
		return self.class.super.getOffset(self)
	else
		return 0
	end
end

function UITouchProcessorClick:onHandCardTouchBegan(sender, event)
	-- 记录鼠标状态 
	self._host._mouseDown = true;
	self._host._operatingCardDoubleDown = false;

	local pt = sender:getTouchBeganPosition()
	local cardlist = self._host._playerProcessor._cardList	
	local selectCard = self._host:_getSelectedCard(cardlist, pt)
	-- 如果点在手牌上了
	if self._host._canMulitSelect == false then
		-- 默认模式, 只能选中一张牌
		if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
			self._host:_popupOperatingCard(selectCard);
			self._host._operatingCardDoubleDown = true;
		end
    else
        self.super.onHandCardTouchBegan(self, sender, event)
	end
end

function UITouchProcessorClick:onHandCardTouchMove(sender, event)
	if not self._host._mouseDown then
		-- 保险起见,再未捕获mouse down时,不处理mouse move.
		return;
	end

	if self._host._canMulitSelect then
		-- 复选状态下不处理拖动,拖动不能改变选择状态
		return;
	end
	local pt = sender:getTouchMovePosition()
	local cardlist = self._host._playerProcessor._cardList
	local selectCard = self._host:_getSelectedCard(cardlist, pt)

	local mousePosiInParent = pt;
	if self._host._operatingCard ~= nil and self._host._operatingCard.mouseEnabled then
		-- 如果y坐标小于指定值，将当前弹出的牌拖出来，并持续拖动
		local vThreadhold = self._host:getCardLayout().anchor.y + PREPARED_CARD_Y_DELTA + 4
		if self._host._operatingCardDoubleDown == true or mousePosiInParent.y > vThreadhold then

			-- 有拖动，则取消doubleClick
			-- Macro.assertFalse(self._operatingCard.x == mousePosiInParent.x and self._operatingCard.y == mousePosiInParent.y)
			if mousePosiInParent.y > vThreadhold then
				-- 超出标记线
				self._host._dragOut = true;
			elseif self._host._dragOut then
				-- 拖出去再拖回来
				self._host._operatingCardDoubleDown = false;
			else
				-- 维持院有关的_operatingCardDoubleDown状态，如果为true，touch end的时候认为是双击出牌
			end

			-- 拖拽设置位置
			mousePosiInParent =  self._host._operatingCard:getParent():convertToNodeSpace(mousePosiInParent)
			self._host._operatingCard:setPosition(cc.p(mousePosiInParent.x, mousePosiInParent.y));

			if not self._host._draggingCard then
				self._host:_startDragging();
			end
		else
			self._host:_endDragging();
		end
	end

	-- 处理滑动选牌
	if self._host._draggingCard == false then
		-- 正在拖拽的情况不能选牌
		if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
			-- 当前鼠标在手牌区

			-- 如果拖到了别的牌上面
			local targetCard = selectCard;
			-- 防止拖动出错牌, 可以打牌的时候不能滑动选牌
			if targetCard ~= self._host._operatingCard and targetCard.mouseEnabled and self._host._playerProcessor:canDiscardCard() == false then
				-- 当前弹出的牌，为操作牌。
				-- 现在为了最小改动，实际还是有好多地方调用_popupOperatingCard，只不过是把弹起的高度改了，所以这个流程还得要处理一下
				self._host:_popupOperatingCard(targetCard);
			end
		end
	end
end

function UITouchProcessorClick:onHandCardTouchEnd(sender, event)
	self._host._mouseDown = false;

	local pt = sender:getTouchEndPosition()
	--pt = sender:getParent():convertToWorldSpace(pt)
	local cardlist = self._host._playerProcessor._cardList
	local selectCard = self._host:_getSelectedCard(cardlist, pt)
	
	-- 拖拽出牌
	if self._host._draggingCard then
		self._host:_endDragging();

		-- 拖动出牌
		-- TODO :　放置自动出牌的时候手动手动出来了
		-- local posi = pt;
		-- local cardLayout = self:getCardLayout()
		-- if posi.y > cardLayout.anchor.y + PREPARED_CARD_Y_DELTA + 40 and not self._operatingCard._disabled then
			-- 拖出了黄线, 出牌处理
			-- self._playerProcessor:discardCard(self._operatingCard);
		-- end
		if not self._host._operatingCard._disabled then
			self._host._playerProcessor:discardCard(self._host._operatingCard);
			-- 统计滑动出牌
			game.service.DataEyeService.getInstance():onEvent("PlayCard_SingleDrag")
		end
	end

	-- 双击出牌
	if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
		-- 当前鼠标在手牌区
		local targetCard = selectCard
		if targetCard == self._host._operatingCard then
			-- 鼠标位置是当前的操作牌
			if self._host._operatingCardDoubleDown and not self._host._operatingCard._disabled then
				-- 是第二次点击, 处理出牌
				self._host._playerProcessor:discardCard(self._host._operatingCard);
				-- 统计双击出牌
				game.service.DataEyeService.getInstance():onEvent("PlayCard_SingleClick")
			end
		end
	end

	if not self._host._operatingCardDoubleDown or self._host._playerProcessor:canDiscardCard() == false then
		-- 如果是当前选中牌了，但是拖回来了
		self._host:recoverOperatingCard()
	end
end

function UITouchProcessorClick:onHandCardTouchCancelled(sender, event)
	self._host._mouseDown = false;
	if self._host._playerProcessor == nil then
		return
	end
	if self._host._draggingCard then
		self._host:_endDragging();
	end

	if not self._host._operatingCardDoubleDown then
		-- 如果是当前选中牌了，但是拖回来了
		self._host:recoverOperatingCard()
	end
end

-- 双击出牌
---------------------------------------------------------------------------------
local UITouchProcessorDoubleClick = class("UITouchProcessorDoubleClick", UITouchProcessorBase)
UITouch.UITouchProcessorDoubleClick = UITouchProcessorDoubleClick

function UITouchProcessorDoubleClick:ctor(host)
    self.class.super.ctor(self, host)
    self._host = host
end

function UITouchProcessorDoubleClick:onHandCardTouchBegan(sender, event)
	-- 记录鼠标状态 
	self._host._mouseDown = true;
	self._host._operatingCardDoubleDown = false;

	local pt = sender:getTouchBeganPosition()
	local cardlist = self._host._playerProcessor._cardList	
	local selectCard = self._host:_getSelectedCard(cardlist, pt)
	-- 如果点在手牌上了
	if self._host._canMulitSelect == false then
		-- 默认模式, 只能选中一张牌
		
		if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
			local targetCard = selectCard
			-- 如果点的不是弹出的牌，复原位置
			if targetCard ~= self._host._operatingCard then
				self._host:recoverOperatingCard();
				-- 更换弹出的牌，并置为操作牌
				self._host:_popupOperatingCard(targetCard);
			else
				-- 如果点的是弹出的牌。
				-- 如果在复选牌的时候，再次点击是取消选中
				self._host._operatingCardDoubleDown = true;
			end
		else
			-- 点其他位置，复原。
			self._host:recoverOperatingCard();
		end
    else
        self.super.onHandCardTouchBegan(self, sender, event)
	end
end

function UITouchProcessorDoubleClick:onHandCardTouchMove(sender, event)
	if not self._host._mouseDown then
		-- 保险起见,再未捕获mouse down时,不处理mouse move.
		return;
	end

	if self._host._canMulitSelect then
		-- 复选状态下不处理拖动,拖动不能改变选择状态
		return;
	end

	local pt = sender:getTouchMovePosition()
	local cardlist = self._host._playerProcessor._cardList
	local selectCard = self._host:_getSelectedCard(cardlist, pt)

	local mousePosiInParent = pt;
	if self._host._operatingCard ~= nil and self._host._operatingCard.mouseEnabled then
		-- 如果y坐标小于指定值，将当前弹出的牌拖出来，并持续拖动
		local vThreadhold = self._host:getCardLayout().anchor.y + PREPARED_CARD_Y_DELTA + 4
		if self._host._operatingCardDoubleDown == true or mousePosiInParent.y > vThreadhold then

			-- 有拖动，则取消doubleClick
			-- Macro.assertFalse(self._operatingCard.x == mousePosiInParent.x and self._operatingCard.y == mousePosiInParent.y)
			if mousePosiInParent.y > vThreadhold then
				-- 超出标记线
				self._host._dragOut = true;
			elseif self._host._dragOut then
				-- 拖出去再拖回来
				self._host._operatingCardDoubleDown = false;
			else
				-- 维持院有关的_operatingCardDoubleDown状态，如果为true，touch end的时候认为是双击出牌
			end

			-- 拖拽设置位置
			mousePosiInParent =  self._host._operatingCard:getParent():convertToNodeSpace(mousePosiInParent)
			self._host._operatingCard:setPosition(cc.p(mousePosiInParent.x, mousePosiInParent.y));

			if not self._host._draggingCard then
				self._host:_startDragging();
			end
		else
			self._host:_endDragging();
		end
	end

	-- 处理滑动选牌
	if self._host._draggingCard == false then
		-- 正在拖拽的情况不能选牌
		if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
			-- 当前鼠标在手牌区

			-- 如果拖到了别的牌上面
			local targetCard = selectCard;
			-- 防止拖动出错牌, 可以打牌的时候不能滑动选牌
			if targetCard ~= self._host._operatingCard and targetCard.mouseEnabled and self._host._playerProcessor:canDiscardCard() == false then
				-- 弹出的牌，缩回去
				self._host:recoverOperatingCard();
				-- 当前弹出的牌，为操作牌。
				self._host:_popupOperatingCard(targetCard);
			end
		end
	end
end

function UITouchProcessorDoubleClick:onHandCardTouchEnd(sender, event)
	self._host._mouseDown = false;

	local pt = sender:getTouchEndPosition()
	--pt = sender:getParent():convertToWorldSpace(pt)
	local cardlist = self._host._playerProcessor._cardList
	local selectCard = self._host:_getSelectedCard(cardlist, pt)
	
	-- 拖拽出牌
	if self._host._draggingCard then
		self._host:_endDragging();

		-- 拖动出牌
		-- TODO :　放置自动出牌的时候手动手动出来了
		-- local posi = pt;
		-- local cardLayout = self:getCardLayout()
		-- if posi.y > cardLayout.anchor.y + PREPARED_CARD_Y_DELTA + 40 and not self._operatingCard._disabled then
			-- 拖出了黄线, 出牌处理
			-- self._playerProcessor:discardCard(self._operatingCard);
		-- end
		if not self._host._operatingCard._disabled then
			self._host._playerProcessor:discardCard(self._host._operatingCard);
			-- 统计滑动出牌
			game.service.DataEyeService.getInstance():onEvent("PlayCard_Drag")
		end
	end

	-- 双击出牌
	if selectCard and table.indexof(cardlist.handCards, selectCard) ~= false then
		-- 当前鼠标在手牌区
		local targetCard = selectCard
		if targetCard == self._host._operatingCard then
			-- 鼠标位置是当前的操作牌
			if self._host._operatingCardDoubleDown and not self._host._operatingCard._disabled then
				-- 是第二次点击, 处理出牌
				self._host._playerProcessor:discardCard(self._host._operatingCard);
				-- 统计双击出牌
				game.service.DataEyeService.getInstance():onEvent("PlayCard_Click")
			end
		end
	end
end

function UITouchProcessorDoubleClick:onHandCardTouchCancelled(sender, event)
	self._host._mouseDown = false;
	if self._host._playerProcessor == nil then
		return
	end
	if self._host._draggingCard then
		self._host:_endDragging();
	end
end

return UITouch