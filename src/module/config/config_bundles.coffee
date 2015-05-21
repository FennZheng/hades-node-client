Log = require("../log/log")
LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig
EventEmitter = require('events').EventEmitter
ProjectConfig = require("../project_config").ProjectConfig

EVENT_READY = "EVENT_READY"
EVENT_FAIL = "EVENT_FAIL"

class ConfigBundles extends EventEmitter

	constructor : ->
		@_localConfigInited = false
		@_remoteConfigInited = false
		@_inited = false

	init : (confFile)->
		return if @_inited
		@_inited = true
		ProjectConfig.init(confFile)
		self = @
		if ProjectConfig.isConfigFromRemote()
			RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_READY,
			->
				Log.info("RemoteConfig is ready")
				self.emit(_instance.EVENT_READY)
			)
			RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_TIMEOUT,
			(err)->
				self.emit(_instance.EVENT_FAIL, err)
			)
			RemoteConfig.init()
		else if ProjectConfig.isConfigFromLocal()
			LocalConfig.on(LocalConfig.EVENT_LOCAL_CONFIG_READY,
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

exports.ConfigBundles = _instance
