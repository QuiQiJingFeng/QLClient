----------------------
-- 加入房间界面
----------------------
local UIJoinRoom = class("UIJoinRoom", require("app.game.ui.UIBase"), function () return kod.LoadCSBNode("ui/csb/UIJoinRoom.csb") end)
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

function UIJoinRoom:ctor()
	self._btnclose = nil
	self._btnRemove = nil
	self._btnClear = nil
	self._btnNumbers = {}
	self._textNumbers = {}
	
    self._currentNumber = 1;
    self._pBtnFunc = nil
end

function UIJoinRoom:needBlackMask()
	return true;
end

function UIJoinRoom:init()
	self._btnclose = seekNodeByName(self, "Button_x_JoinRoom",  "ccui.Button")
	self._btnRemove = seekNodeByName(self, "Button_Delete_JoinRoom",  "ccui.Button")
	self._btnClear = seekNodeByName(self, "Button_Retype_JoinRoom",  "ccui.Button")
	
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key0_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key1_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key2_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key3_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key4_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key5_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key6_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key7_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key8_JoinRoom",  "ccui.Button"))
	table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key9_JoinRoom",  "ccui.Button"))

	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word1_JoinRoom",  "ccui.TextBMFont"))
	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word2_JoinRoom",  "ccui.TextBMFont"))
	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word3_JoinRoom",  "ccui.TextBMFont"))
	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word4_JoinRoom",  "ccui.TextBMFont"))
	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word5_JoinRoom",  "ccui.TextBMFont"))
	table.insert(self._textNumbers, seekNodeByName(self, "BitmapFontLabel_word6_JoinRoom",  "ccui.TextBMFont"))

	self:_registerCallBack()
end

function UIJoinRoom:_registerCallBack()
	bindEventCallBack(self._btnclose, handler(self, self._onClickCloseBtn),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnRemove, handler(self, self._onClickRemoveBtn),ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClear, handler(self, self._onClickClearBtn),ccui.TouchEventType.ended);
	
	for i = 1,#self._btnNumbers do
		bindEventCallBack(self._btnNumbers[i], function()
			self:_onClickNumber(i-1)
		end,ccui.TouchEventType.ended);
		-- self._btnNumbers[i]:setTitleText(""..i-1)
	end
end

function UIJoinRoom:onShow(pFunc)
    self._pBtnFunc = pFunc
	self:_clearNumber()

	self:playAnimation_Scale()
end

function UIJoinRoom:onClose()
    self._pBtnFunc = nil
end

-- 清空选中数组
function UIJoinRoom:_clearNumber()
	for i = 1,#self._textNumbers do
		self._textNumbers[i]:setString("")
	end

	self._currentNumber = 1;
end

function UIJoinRoom:_onClickCloseBtn(sender)
	UIManager:getInstance():destroy("UIJoinRoom");
end

function UIJoinRoom:_onClickRemoveBtn(sender)
	if self._currentNumber == 1 then
		return
	end

	-- 清空一个数字
	self._textNumbers[self._currentNumber-1]:setString("")
	self._currentNumber = self._currentNumber - 1;
end

function UIJoinRoom:_onClickClearBtn(sender)
	self:_clearNumber()
end

function UIJoinRoom:_onClickNumber(number)
	if self._currentNumber > #self._textNumbers then
		-- pass
	else
		self._textNumbers[self._currentNumber]:setString(""..number);
		self._currentNumber = self._currentNumber + 1;
		
        if self._currentNumber == #self._textNumbers + 1 then
			-- 都输入了
			    -- 若已报名比赛 则无法进入房间
			if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
				return
			end
		
			local roomId = 0;
			for i = 1,#self._textNumbers do
				local lableNum = tonumber(self._textNumbers[i]:getString());
				roomId = roomId * 10 + lableNum;
            end
            
            if self._pBtnFunc then 
                self._pBtnFunc(roomId)
                return 
            end

	       game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.InputRoomNumber)
		end
	end
end
return UIJoinRoom;