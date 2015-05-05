LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig
EventEmitter = require('events').EventEmitter

CONFIG_READY = "CONFIG_READY"

class ConfigBundles extends EventEmitter

	constructor : ->
		@_localConfigInited = false
		@_remoteConfigInited = false
		@_inited = false

	init : ->
		self = @
		#TODO zookeeper 没启动，没有报错？？？？RemoteConfig
		RemoteConfig.on(RemoteConfig.REMOTE_CONFIG_READY,
			->
				console.log("RemoteConfig receive event: REMOTE_CONFIG_READY")
				self._remoteConfigInited = true
				console.log("RemoteConfig @_remoteConfigInited!  #{self._localConfigInited}  #{self._inited}")
				if self._localConfigInited and not self._inited
					self._inited = true
					console.log("RemoteConfig emit _instance.CONFIG_READY!")
					self.emit(_instance.CONFIG_READY)
		)
		LocalConfig.on(LocalConfig.LOCAL_CONFIG_READY,
			->
				console.log("LocalConfig receive event: LOCAL_CONFIG_READY")
				self._localConfigInited = true
				if self._remoteConfigInited and not self._inited
					self._inited = true
					self.emit(_instance.CONFIG_READY)
		)
		LocalConfig.init()
		RemoteConfig.init()

	get : (name)->
		_val = LocalConfig.get(name)
		console.log("configBundles get LocalConfig name:#{name}, value :#{_val}")
		if not _val?
			console.log("configBundles get LocalConfig is null")
			_val = RemoteConfig.get(name)
		if not _val?
			console.error("get config not found, key:#{name}, value:#{_val}")
		_val

	getDynamic : (name, watcher)->
		_val = LocalConfig.getDynamic(name, watcher)
		if not _val?
			console.log("configBundles getDynamic LocalConfig is null")
			_val = RemoteConfig.getDynamic(name, watcher)
		if not _val?
			console.error("getDynamic config not found, key:#{name}, value:#{_val}")
		_val

_instance = new ConfigBundles()
exports.ConfigBundles = _instance
exports.CONFIG_READY = CONFIG_READY