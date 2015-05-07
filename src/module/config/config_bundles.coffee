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
		ProjectConfig.init(confFile)
		self = @
		#TODO zookeeper 没启动，没有报错？？？？RemoteConfig
		RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_READY,
			->
				Log.debug("RemoteConfig is ready")
				self._remoteConfigInited = true
				if self._localConfigInited and not self._inited
					self._inited = true
					Log.debug("AllConfig is ready")
					self.emit(_instance.EVENT_CONFIG_READY)
		)
		RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_TIMEOUT,
			->
				Log.error("HadesConfig RemoteConfig load timeout!!")
				self.emit(_instance.EVENT_CONFIG_FAIL)
		)
		LocalConfig.on(LocalConfig.EVENT_LOCAL_CONFIG_READY,
			->
				Log.debug("HadesConfig localConfig is ready")
				self._localConfigInited = true
				if self._remoteConfigInited and not self._inited
					self._inited = true
					Log.debug("HadesConfig allConfig is ready")
					self.emit(_instance.EVENT_CONFIG_READY)
		)
		LocalConfig.init()
		RemoteConfig.init()

	get : (name)->
		_val = LocalConfig.get(name)
		if not _val?
			_val = RemoteConfig.get(name)
		_val

	getDynamic : (name, watcher)->
		_val = LocalConfig.getDynamic(name, watcher)
		if not _val?
			_val = RemoteConfig.getDynamic(name, watcher)
		_val

_instance = new ConfigBundles()
_instance.EVENT_CONFIG_READY = EVENT_CONFIG_READY
_instance.EVENT_CONFIG_FAIL = EVENT_CONFIG_FAIL

exports.ConfigBundles = _instance
