Module = require('../../lib/Module').Module
IConfig = require('./IConfig').IConfig
ZkProxy = require('../zk/ZkProxy').ZkProxy
RemoteConfigCache = require('./RemoteConfigCache').RemoteConfigCache

class RemoteConfig extends Module
	@include IConfig

	constructor : ()->
		ZkProxy.onLoadComplete(
			()->

		)
		ZkProxy.load()
		setInterval(()->
			return if ZkProxy.checkLoadState()
		,1000)


	# @Override
	get : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		#if not ConfigMap[name]?
		#	ZkProxy.loadConfig(name)
		ConfigMap[name]

	# @Override
	getDynamic : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		#if not ConfigMap[name]?
		#	ZkProxy.loadConfigAndWatch(name)
		ConfigMap[name]

_instance = new RemoteConfig()
exports.RemoteConfig = _instance