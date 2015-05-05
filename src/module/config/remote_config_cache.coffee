KEY_WHITE_IP_LIST = "_whiteIpList"
KEY_VERSION_CONTROL = "_versionControl"
KEY_GLOBAL_LOCK = "_globalLock"
SYS_KEYS = [KEY_VERSION_CONTROL, KEY_WHITE_IP_LIST]

util = require('util')
LOCAL_IP = require("../util/ip_util").LOCAL_IP

class RemoteConfigCache
	@_inited = false
	constructor : ->
		@_cache = {}
		@_sys = {}
		@_dynamicKeys = {}

	init : ->
		if not @_inited
			@_cache = {}
			@_inited = true
			@_status = {}

	set : (key, value)->
		console.log("remote config cache key:#{key}, value:#{value}")
		if key in SYS_KEYS
			@_sys[key] = value
			return
		return if not @isAllowUpdate()
		@_cache[key] = value
		#TODO test
		console.log(@getLastModifyTime())
		return

	get : (key)->
		@_cache[key]

	getLastModifyTime : ->
		@_cache[KEY_VERSION_CONTROL]?.lastModifyTime

	updateVersion : (data)->
		return if not data
		_localModifyTime = @_sys[KEY_VERSION_CONTROL]?.lastModifyTime
		return if not _localModifyTime
		if _localModifyTime < data.lastModifyTime
			#TODO 更新全部的dynamic keys, 后续改为增量
			return

	isAllowUpdate : ->
		_whiteIpList = @_sys[KEY_WHITE_IP_LIST]
		return true if not _whiteIpList or not util.isArray(_whiteIpList)
		return true if LOCAL_IP in _whiteIpList
		return false

	getStatus : ->
		JSON.stringify(@_status)


_instance = new RemoteConfigCache()

exports.RemoteConfigCache = _instance
exports.KEY_VERSION_CONTROL = KEY_VERSION_CONTROL