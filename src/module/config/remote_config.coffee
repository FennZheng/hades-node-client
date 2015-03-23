Module = require('../../lib/module').Module
IConfig = require('./i_config').IConfig
ZkProxy = require('../zk/zk_proxy').ZkProxy
RemoteConfigCache = require('./remote_config_cache').RemoteConfigCache

class RemoteConfig extends Module
	@include IConfig

	constructor : ()->
		ZkProxy.on("event")
		ZkProxy.load()

	# @Override
	get : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if(ZkProxy.checkLoadState())
			return RemoteConfigCache[name]
		else
			#wait

	# @Override
	getDynamic : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if(ZkProxy.checkLoadState())
			return RemoteConfigCache[name]
		else
			#wait

_instance = new RemoteConfig()
exports.RemoteConfig = _instance