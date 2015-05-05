ZkProxy = require('../zk/zk_proxy').ZkProxy
RemoteConfigCache = require('./remote_config_cache').RemoteConfigCache
EventEmitter = require('events').EventEmitter

REMOTE_CONFIG_READY = "REMOTE_CONFIG_READY"

class RemoteConfig extends EventEmitter

	@_inited = false
	@_checkInitInterval = 10000

	init : ->
		self = @
		ZkProxy.on(ZkProxy.EVENT_ALL_LOAD_COMPLETE, ->@_inited = true; self.emit(_instance.REMOTE_CONFIG_READY))
		ZkProxy.on(ZkProxy.EVENT_ALL_LOAD_TIMEOUT, ->@_inited = false; process.exit(-1))
		ZkProxy.load()

	# @Override
	get : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		return RemoteConfigCache.get name


	# @Override
	getDynamic : (name, watcher)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if(@_inited)
			_val = RemoteConfigCache.get name
			ZkProxy.regConfWatcher(name)
			return _val
		else
			return null

_instance = new RemoteConfig()
exports.RemoteConfig = _instance
exports.REMOTE_CONFIG_READY = REMOTE_CONFIG_READY