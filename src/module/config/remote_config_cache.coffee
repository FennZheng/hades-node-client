util = require('util')
LOCAL_IP = require("../util/ip_util").LOCAL_IP
Log = require("../log/log")

NONE_JSON = "{}"
KEY_WHITE_IP_LIST = "_whiteIpList"
KEY_VERSION_CONTROL = "_versionControl"
KEY_GLOBAL_LOCK = "_globalLock"
SYS_KEYS = [KEY_VERSION_CONTROL, KEY_WHITE_IP_LIST, KEY_GLOBAL_LOCK]

class RemoteConfigCache

	constructor : ->
		@_inited = false
		@_userData = {}
		@_sysData = {}

	init : ->
		return

	_set : (key, value)->
		if key in SYS_KEYS
			@_sysData[key] = value
			return
		if not @isAllowUpdate()
			Log.debug("key:#{key} update is not allowed , because LocalIp:#{LOCAL_IP} is not in _whiteIpList:#{@_sysData[KEY_WHITE_IP_LIST]}")
			return
		@_userData[key] = value
		return

	setDataStr : (key, str)->
		Log.debug("setDataStr key:#{key} str:#{str}")
		return if not str
		try
			_obj = JSON.parse(str)
			@_set(key, _obj)
		catch err
			Log.error("setDataStr error for key :#{key}, may be JSON Object error:#{err}")

	get : (key)->
		@_userData[key]

	# check whiteIpList & globalLock
	isAllowUpdate : ->
		#TODO test performance
		return false if @_isClientUpdateLock()
		_whiteIpList = @_sysData[KEY_WHITE_IP_LIST]
		return true if not _whiteIpList or not util.isArray(_whiteIpList)
		return true if LOCAL_IP in _whiteIpList
		return false

	# check lastModifyTime
	isNeedUpdate : (remoteVerData)->
		return false if not remoteVerData
		try
			_remoteVerObj = JSON.parse(remoteVerData)
			return false if not _remoteVerObj
			return @_isDataExpire(_remoteVerObj.lastModifyTime)
		catch err
			Log.error("isNeedUpdate _remoteVerData json parse object error:#{err.stack}")
			return false

	_isDataExpire : (remoteTime)->
		return false if not remoteTime
		_localTime = @_getLocalLastModifyTime()
		return true if not _localTime
		return true if _localTime < remoteTime
		return false

	_isClientUpdateLock : ()->
		_globalLock = @_sysData[KEY_GLOBAL_LOCK]
		return false if not _globalLock
		_clientUpdateLock = _globalLock.clientUpdateLock
		return true if _clientUpdateLock
		return false

	_getLocalLastModifyTime : ->
		_localVerObj = @_sysData[KEY_VERSION_CONTROL]
		return null if not _localVerObj
		_localTime = _localVerObj.lastModifyTime
		return null if not _localTime
		return _localTime


class RemoteConfigMonitor
	constructor : (remoteConfigCache)->
		@_configRef = remoteConfigCache

	getSysData : ->
		JSON.stringify(@_configRef._sysData)

	getAllUserData : ->
		JSON.stringify(@_configRef._userData)

	getUserDataByKey : (key)->
		_val = @_configRef._userData[key]
		return JSON.stringify(_val) if not _val
		return NONE_JSON



_instance = new RemoteConfigCache()
_instance.KEY_VERSION_CONTROL = KEY_VERSION_CONTROL
_instance.SYS_KEYS = SYS_KEYS

_monitor = new RemoteConfigMonitor(_instance)

exports.RemoteConfigCache = _instance
exports.RemoteConfigMonitor = _monitor
