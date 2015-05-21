ZkClient = require("../zk/zk_client").ZkClient
Log = require("../log/log")
LOCAL_IP = require("../util/ip_util").LOCAL_IP
EventEmitter = require('events').EventEmitter
Util = require("util")

ProjectConfig = require("../project_config").ProjectConfig
SERVICE_ROOT = "/hades/services/"
EVENT_READY = "EVENT_READY"
EVENT_FAIL = "EVENT_FAIL"
#TODO 本地缓存解决短时间的网络分区问题

###
    listenerMap:
    {
		"serviceId1":
            {
                "eventId1":{timestamp},
				"eventId2":{timestamp}
            }
    }
    cache:
    {
        "serviceId1": [url1, url2]
    }
###

class ServiceBundles extends EventEmitter
	constructor : ->
		@_serviceMaxClient = {}
		@_listenerMap = {}
		@_recoveryMode = false
		@_cache = {}

	init :(confFile) ->
		ProjectConfig.init(confFile)
		ZkClient.init((err, result)=>
			if not result
				@.emit(_instance.EVENT_FAIL, err)
				return
			_config = ProjectConfig.getServiceDiscovery()
			@_GROUP_ID = _config["groupId"]
			@_autoUpdateInterval = _config["autoUpdateInterval"] || 2000
			@.emit(_instance.EVENT_READY)
		)

	register : (serviceId, url, meta, cb)->
		_parentPath = @_buildServicePath(serviceId)
		_childPath = _parentPath + "/" + url
		ZkClient.addChildren(_parentPath, _childPath, meta, (err, result)->
			if err
				if cb
					return cb(err, false)
				else
					Log.error("register for parentPath:#{_parentPath}, childPath:#{_childPath}, error:#{err.stack}")
					return
			return cb(null, true) if cb
		)

	#!!! only use it once
	watch : (serviceId, notifyEventId)->
		if @_isNotifyEventRegistered(serviceId, notifyEventId)
			throw new Error("notifyEventId:#{notifyEventId} had been registered")

		@_addListener(serviceId, notifyEventId)

		_path = @_buildServicePath(serviceId)

		ZkClient.getChildDataAndWatch(_path, (noThrowErr, key, data)=>
			# no throw out error
			if noThrowErr
				Log.error("get service for key:#{key} list error:#{noThrowErr.stack}")
				return
			@_updateCacheAndNotify(key, data)
			return
		)
		@_setAutoUpdateLoop(serviceId)
		return

	_loadByLocal : ->


	_isNotifyEventRegistered : (serviceId, notifyEventId)->
		return false if not @_listenerMap[serviceId]
		return false if not @_listenerMap[serviceId][notifyEventId]

	_setAutoUpdateLoop : (serviceId)->
		setInterval(
			=>
				ZkClient.getChildren(@_buildServicePath(serviceId), (err, data)=>
					if err
						Log.error("service auto-update loop error: #{err.stack}")
						return
					@_updateCacheAndNotify(serviceId, data)
					return
				)
		,@_autoUpdateInterval
		)

	_updateCacheAndNotify : (key, data)->
		Log.debug("_updateCacheAndFireEvent: key:#{key} data:#{data}")
		if not data
			Log.debug("_updateCacheAndFireEvent: that data is null don't update cache")
		else
			if @_updateCache(key, data)
				@_notifyToListeners(key, data)

	###
        return true if updated
        return false if no updates
    ###
	_updateCache : (key, array)->
		return false if not array or not Util.isArray(array) or array.length <= 0
		if not @_cache[key]
			@_cache[key] = []
		_cacheSize = @_cache[key].length
		if array.length > _cacheSize
			@_serviceMaxClient[key] = array.length
		else if array.length == _cacheSize
			#equal
			return false if array.sort().toString() == @_cache[key].sort().toString()
		# safe mode
		#if array.length < @_serviceMaxClient/2
		#	Log.error("!!Lost more than half client for serviceId:#{key}, ignore updates")
		#	return false
		@_cache[key] = array
		return true

	_buildServicePath : (serviceId)->
		SERVICE_ROOT + @_GROUP_ID + "/" + serviceId

	_isServiceWatched : (serviceId)->
		@_listenerMap[serviceId] and @_listenerMap[serviceId].length > 0

	_addListener : (serviceId, notifyEventId)->
		if not @_listenerMap[serviceId]
			@_listenerMap[serviceId] = []
		@_listenerMap[serviceId][notifyEventId] = true

	_notifyToListeners : (serviceId, data)->
		_eventIdMap = @_listenerMap[serviceId]
		return if not _eventIdMap
		for _eventId of _eventIdMap
			@.emit(_eventId, data)

_instance = new ServiceBundles()
_instance.setMaxListeners(0)
_instance.EVENT_READY = EVENT_READY
_instance.EVENT_FAIL = EVENT_FAIL

exports.ServiceBundles = _instance