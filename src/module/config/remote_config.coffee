ZkClient = require('../zk/zk_client').ZkClient
ProjectConfig = require("../project_config").ProjectConfig
RemoteConfigCache = require('./remote_config_cache').RemoteConfigCache
Log = require("../log/log")
EventEmitter = require('events').EventEmitter

EVENT_REMOTE_CONFIG_READY = "EVENT_REMOTE_CONFIG_READY"
EVENT_REMOTE_CONFIG_TIMEOUT = "EVENT_REMOTE_CONFIG_TIMEOUT"

LOAD_STATE = {
	NO_LOADING : "0",
	LOADING : "1",
	LOAD_COMPLETE : "2"
}

CONFIG_ROOT = "/hades/configs/"

class RemoteConfig extends EventEmitter

	constructor : ->
		@_inited = false
		@_loadState = LOAD_STATE.NO_LOADING
		@_loadTimeout = null
		@_autoUpdateInterval = null
		@_dynamicKeys = {}

	init : ->
		return if @_inited
		@_inited = true
		ZkClient.init()
		_config = ProjectConfig.getRemoteConfig()
		@_PROJECT_PATH = CONFIG_ROOT + _config["groupId"] + "/" + _config["projectId"]
		@_loadTimeout = _config["loadTimeout"] || 10000
		@_autoUpdateInterval = _config["autoUpdateInterval"] || 10000
		@_load()

	# @Override
	get : (name)->
		RemoteConfigCache.get name

	getDynamic : (name)->
		if(@_inited)
			_val = RemoteConfigCache.get name
			if _val and not @_dynamicKeys[name]
				@_dynamicKeys[name] = true
				ZkClient.setDataAutoUpdate(@_buildPath(name), (err, data)->
					Log.debug("DataAutoUpdate find updates for name : #{name}, get data: #{data}")
					Log.error("DataAutoUpdate error for name:#{name},error:#{err.stack}") if err
					RemoteConfigCache.setDataStr(name, data)
				)
			return _val
		else
			return null

	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + configName

	_load : ->
		throw new Error("ZkProxy load duplicate invoke!!") if @_loadState != LOAD_STATE.NO_LOADING
		@_loadState = LOAD_STATE.LOADING
		ZkClient.getChildren(@_PROJECT_PATH, @_initConfigMap)

	_initConfigMap : (err, children, stats)=>
		# global cache ,clear it up
		RemoteConfigCache.init()
		if err
			Log(err.stack)
		if children?
			_check = @_createLoadCheck(children.length)
			for child in children
				@_fillConfigItem(child, _check)

		return

	_fillConfigItem : (child, _check)->
		_path = @_buildPath(child)
		ZkClient.getData(_path, (err, data)=>
			if err
				Log.error("_fillConfigItem err:"+err.stack)
			else
				RemoteConfigCache.setDataStr(child, data)
				if --_check.count <= 0
					clearTimeout(_check.timer)
					_instance._loadState = LOAD_STATE.LOAD_COMPLETE
					_instance._setAutoUpdateLoop()
					# add sys configs watch
					for _key in RemoteConfigCache.SYS_KEYS
						ZkClient.setDataAutoUpdate(@_buildPath(_key), (err, data)->
							Log.error("DataAutoUpdate error for name:#{_key},error:#{err.stack}") if err
							RemoteConfigCache.setDataStr(_key, data)
						)
					@.emit(_instance.EVENT_REMOTE_CONFIG_READY)
			return
		)

	_setLoadTimeout : ->
		setTimeout(=>
			if @_loadState != LOAD_STATE.LOAD_COMPLETE
				@.emit(_instance.EVENT_REMOTE_CONFIG_TIMEOUT)
				Log.error("Load all config from zk timeout(#{@_loadTimeout}ms)")
		,@_loadTimeout)


	_createLoadCheck :(taskCount) ->
		_taskCount = taskCount
		_loadTimerId = @_setLoadTimeout()
		{
			count : _taskCount,
			timer : _loadTimerId
		}

	_setAutoUpdateLoop : ->
		setInterval(
			=>
				ZkClient.getData(@_buildPath(RemoteConfigCache.KEY_VERSION_CONTROL), (err, data)=>
					if err
						Log.error("auto-update loop error: #{err.stack}")
					else
						if RemoteConfigCache.isNeedUpdate(new String(data, "utf-8"))
							Log.debug("auto-update loop check: _versionControl has updates")
							for _key of @_dynamicKeys
								ZkClient.getData(@_buildPath(_key), (err, data)->
									if err
										Log.error("auto-update loop get Data error: #{err.stack}")
									else
										RemoteConfigCache.setDataStr(_key, data)
								)
						else
							Log.debug("auto-update loop check: _versionControl has no updates")
					return
				)
		,@_autoUpdateInterval
		)


_instance = new RemoteConfig()


_instance.EVENT_REMOTE_CONFIG_READY = EVENT_REMOTE_CONFIG_READY
_instance.EVENT_REMOTE_CONFIG_TIMEOUT = EVENT_REMOTE_CONFIG_TIMEOUT

exports.RemoteConfig = _instance
