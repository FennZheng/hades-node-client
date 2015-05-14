Log = require("../log/log")
LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig
EventEmitter = require('events').EventEmitter
ProjectConfig = require("../project_config").ProjectConfig

EVENT_CONFIG_READY = "EVENT_CONFIG_READY"
EVENT_CONFIG_FAIL = "EVENT_CONFIG_FAIL"

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
		#TODO zookeeper 没启动，没有报错？？？？RemoteConfig
		if ProjectConfig.isConfigFromRemote()
			RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_READY,
			->
				Log.info("RemoteConfig is ready")
				self.emit(_instance.EVENT_CONFIG_READY)
			)
			RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_TIMEOUT,
			->
				Log.error("RemoteConfig load timeout!!")
				self.emit(_instance.EVENT_CONFIG_FAIL)
			)
			RemoteConfig.init()
		else if ProjectConfig.isConfigFromLocal()
			LocalConfig.on(LocalConfig.EVENT_LOCAL_CONFIG_READY,
			->
				Log.info("HadesConfig localConfig is ready")
				self.emit(_instance.EVENT_CONFIG_READY)
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
_instance.EVENT_CONFIG_READY = EVENT_CONFIG_READY
_instance.EVENT_CONFIG_FAIL = EVENT_CONFIG_FAIL

exports.ConfigBundles = _instance
