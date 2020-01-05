local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UIDownloadItem = class("UIDownloadItem",UITableViewCell)
local UIManager = game.UIManager
local DOWNLOAD_STATE = game.UIConstant.DOWNLOAD_STATE 
function UIDownloadItem:init()
    self._txtName = Util:seekNodeByName(self,"txtName","ccui.Text")
    self._txtTotalFileLength = Util:seekNodeByName(self,"txtTotalFileLength","ccui.Text")
    self._txtDownloadNow = Util:seekNodeByName(self,"txtDownloadNow","ccui.Text")
    self._txtState = Util:seekNodeByName(self,"txtState","ccui.Text")

    self._lodingBar = Util:seekNodeByName(self,"lodingBar","ccui.LodingBar")

    self._btnRestore = Util:seekNodeByName(self,"btnRestore","ccui.Button")
    self._btnStop = Util:seekNodeByName(self,"btnStop","ccui.Button")
    Util:bindTouchEvent(self._btnRestore,handler(self,self._onBtnRestoreClick))
    Util:bindTouchEvent(self._btnStop,handler(self,self._onBtnStopClick))
end

function UIDownloadItem:_onBtnRestoreClick()
    self._data.state = DOWNLOAD_STATE.WAITE
    self._data.change = true
end

function UIDownloadItem:_onBtnStopClick()
    self._data.state = DOWNLOAD_STATE.STOPED
    self._data.change = true
end

function UIDownloadItem:updateData(data)
    
    if data.state == DOWNLOAD_STATE.WAITE then
        self._txtState:setString("等待中")
        Util:hide(self._btnStop,self._btnRestore)
    elseif data.state == DOWNLOAD_STATE.STARTING then
        self._txtState:setString("下载中")
        Util:hide(self._btnRestore)
        Util:show(self._btnStop)
    elseif data.state == DOWNLOAD_STATE.STOPED then
        self._txtState:setString("已暂停")
        Util:show(self._btnRestore)
        Util:hide(self._btnStop)
    else
        assert(false)
        self._txtState:setString("")
    end
    self._txtName:setString(data.fileName)
    if data.totalToDownload then
        self._txtTotalFileLength:setString(tostring(data.totalToDownload))
    else
        self._txtTotalFileLength:setString("")
    end
    if data.process then
        self._txtDownloadNow:setString(string.format("已下载.1f%%",data.process))
        self._lodingBar:setPercent(data.process);
    else
        self._txtDownloadNow:setString("")
    end
end
 

return UIDownloadItem