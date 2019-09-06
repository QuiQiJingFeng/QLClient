--[[	
	GainLabelColorUtil 获取label颜色值
	与美术约定普通文本名依次叫 Label_Add_1 、Label_Add_2 ...
	填充文本名(输入框的 placeHolder) Label_PlaceHolder_Add_1 、Label_PlaceHolder_Add_2 ...
--]]
local GainLabelColorUtil = class("GainLabelColorUtil")
local TEXT_NAME = "Label_Add_"
local PH_TEXT_NAME = "Label_PlaceHolder_Add_"

function GainLabelColorUtil:ctor(ui, textNum, placeHolderTextNum)
	self.colors = {}
	self.phColors = {}

	if textNum ~= nil then
		for id = 1,textNum do
			local text = seekNodeByName(ui, TEXT_NAME..id, "ccui.Text")      
			local color = text:getTextColor()
			table.insert(self.colors,color)
		end
	end

	if placeHolderTextNum ~= nil then
		for id = 1,placeHolderTextNum do
			local textplaceHolderColor = seekNodeByName(ui, PH_TEXT_NAME..id, "ccui.Text")      
			local color = textplaceHolderColor:getTextColor()
			table.insert(self.phColors,color)
		end
	end
end

return GainLabelColorUtil
