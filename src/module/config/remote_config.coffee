Module = require('../../lib/module').Module
IConfig = require('./i_config').IConfig
ZkProxy = require('../zk/zk_proxy').ZkProxy
RemoteConfigCache = require('./remote_config_cache').RemoteConfigCache

class RemoteConfig extends Module
	@include IConfig

	@_inited = false
	@_checkInitInterval = 100

	constructor : ()->
		ZkProxy.load()
		ZkProxy.on(@EVENT_ALL_LOAD_COMPLETE,()->@_inited = true)
		ZkProxy.on(@EVENT_ALL_LOAD_TIMEOUT,()->@_inited = false;process.exit(-1))

	# @Override
	get : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if(@_inited)
			return RemoteConfigCache[name]
		else
			setInterval(()->
				if(@_inited)
					clearInterval(self)
			, @_checkInitInterval)
			return RemoteConfigCache[name]


	# @Override
	getDynamic : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if(@_inited)
			return RemoteConfigCache[name]
		else
			setInterval(()->
				if(@_inited)
					clearInterval(self)
			, @_checkInitInterval)
			return RemoteConfigCache[name]

exports.RemoteConfig = new RemoteConfig()