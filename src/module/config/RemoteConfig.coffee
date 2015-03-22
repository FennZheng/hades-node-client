Module = require('../../lib/Module').Module
IConfig = require('./IConfig').IConfig
ZkProxy = require('../zk/ZkProxy').ZkProxy
ConfigMap = require('./RemoteConfigStore').ConfigMap

class RemoteConfig extends Module
	@include IConfig

	constructor : (path)->
		if path?
			CONFIG_PATH = path
		@_zkProxy = ZkProxy

	# @Override
	get : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if not ConfigMap[name]?
			ConfigMap[name] = @_zkProxy.getConfig(name,true)
		ConfigMap[name]

	# @Override
	getDynamic : (name)->
		throw new Error("config can not end with .json") if not name? || (name.length >= 5 and name.slice(-5, -1) == ".json")
		if not ConfigMap[name]?
			ConfigMap[name] = @_zkProxy.getConfigAndWatch(name)
		ConfigMap[name]



_instance = new RemoteConfig()
exports.RemoteConfig = _instance