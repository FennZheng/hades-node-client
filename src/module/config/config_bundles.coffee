Log = require("../log/").Log
LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig
EventEmitter = require('events').EventEmitter
ProjectConfig = require("../project_config").ProjectConfig
MonitorServer = require("../monitor").MonitorServer

EVENT_READY = "EVENT_READY"
EVENT_FAIL = "EVENT_FAIL"

class ConfigBundles extends EventEmitter

	constructor : ->
		@_localConfigInited = false
		@_remoteConfigInited = false
		@_inited = false

	init : (confObj)->
		return if @_inited
		@_inited = true
		ProjectConfig.init(confObj)
		self = @
		if ProjectConfig.isConfigFromRemote()
			RemoteConfig.once(RemoteConfig.EVENT_REMOTE_CONFIG_READY,
			->
				Log.info("RemoteConfig is ready")
				self.emit(_instance.EVENT_READY)
			)
			RemoteConfig.once(RemoteConfig.EVENT_REMOTE_CONFIG_TIMEOUT,
			(err)->
				self.emit(_instance.EVENT_FAIL, err)
			)
			RemoteConfig.init()
		else if ProjectConfig.isConfigFromLocal()
			LocalConfig.once(LocalConfig.EVENT_LOCAL_CONFIG_READY,
			->
				Log.info("LocalConfig is ready")
				self.emit(_instance.EVENT_READY)
			)
			LocalConfig.init()

	get : (name)->
		_val = LocalConfig.get(name)
		if not _val?
			_val = RemoteConfig.get(name)
		_val

	getDynamic : (name)->
		_val = LocalConfig.getDynamic(name)
		if not _val?
			_val = RemoteConfig.getDynamic(name)
		_val

_instance = new ConfigBundles()
_instance.setMaxListeners(0)
_instance.EVENT_READY = EVENT_READY
_instance.EVENT_FAIL = EVENT_FAIL

#init monitor
_instance.once(_instance.EVENT_READY, ->
	MonitorServer.init()
)

exports.ConfigBundles = _instance
