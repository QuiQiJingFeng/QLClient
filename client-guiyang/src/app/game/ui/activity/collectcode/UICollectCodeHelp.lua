local TITLE = {
    [true] = "中奖规则",
    [false] = "活动规则",
}
local CONTENT = {
    [true] = [[
中奖规则：
1、兑奖码由6个字组成，开奖时，会公布1组获奖码，玩家用手中积攒的兑奖码与获奖码进行比对；            
2、比对方式：            
（1）字的数量：对上的字数越多红包金额越大；            
（2）字的顺序：对上的字数相同时，字的顺序全对的红包金额大。            

对上的字数　　对应顺序　　　　获奖等级
六个　　　　　全对应　　　　　一等
六个　　　　　不全对应　　　　二等
五个　　　　　全对应　　　　　三等
五个　　　　　不全对应　　　　四等
四个　　　　　全对应　　　　　五等
四个　　　　　不全对应　　　　六等
三个　　　　　全对应　　　　　七等
        
举例：            
本期获奖码：  恭  喜  发  财  吉  祥
我的兑奖码：  恭  喜  吉  祥  发  财
该兑奖码对上的字数为6个，对应顺序为“不全对应”，因此该兑奖码可领二等奖红包！            
注意：获得活动奖励后，需手动领奖
]],
    [false] = [[
一、活动规则：
1、活动时间 2019年2月8日00:00-2月15日24:00；
2、开奖时间 2月9、11、13、15日20:30；
3、每期开奖会公布1组获奖码，玩家可以用手中积攒的兑奖码与获奖码进行比对，根据对上字的数量和顺序情况瓜分不同金额的红包奖励；
4、每期积攒的码越多，中奖概率越高。
二、兑奖码获取方式：
1.每期活动开奖前，在大厅或俱乐部完成118、228、388、558局好友桌牌局，各可获得1次抽取兑换码的机会。
2.任务完成后获得摇码机会，手动领取后在摇奖机摇得兑奖码，每期第二天20:00时停止兑奖码任务和兑奖码的领取，获奖码公布时间为当天20:30。
]]
}
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeHelp.csb'
local seekButton = require("app.game.util.UtilsFunctions").seekButton
local ScrollText = require("app.game.util.ScrollText")
local UICollectCodeHelp = super.buildUIClass("UICollectCodeHelp", csbPath)
function UICollectCodeHelp:init()
    self._text = ScrollText.new(seekNodeByName(self, "Text_Content", "ccui.Text"), 24, true)
    self._title = seekNodeByName(self, "Text_Title")
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
end

---
--- value: boolean  false 为 活动规则  true 为中奖规则
---
function UICollectCodeHelp:onShow(value)
    value = value or false
    self._text:setString(CONTENT[value])
    self._title:setString(TITLE[value])
end

function UICollectCodeHelp:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeHelp:needBlackMask() return true end

return UICollectCodeHelp