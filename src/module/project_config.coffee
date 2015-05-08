Log = require("./log/log")
path = require("path")

SERVICE_DISCOVERY = "serviceDiscovery"
REMOTE_CONFIG = "remoteConf"
LOCAL_CONFIG = "localConf"
ZOOKEEPER_CONFIG = "zookeeperConf"

class ProjectConfig
	constructor : ->
		@_configs = null
		@_inited = false

	init : (confFile)->
		throw new Error("HadesConfig config file is null!!") if not confFile
		return if @_inited
		@_inited = true
		@_configs = require(path.normalize(confFile))
		@_validate()

	getZookeeperConf : ->
		@_configs[ZOOKEEPER_CONFIG]

	getLocalConfig : ->
		@_configs[LOCAL_CONFIG]

	getRemoteConfig : ->
		@_configs[REMOTE_CONFIG]

	getServiceDiscovery : ->
		@_configs[SERVICE_DISCOVERY]

	_validate : ->
		@._checkNodeIsNull(SERVICE_DISCOVERY)
		._checkNodeIsNull(REMOTE_CONFIG)
		._checkNodeIsNull(LOCAL_CONFIG)
		._checkNodeIsNull(ZOOKEEPER_CONFIG)
		return true

	_checkNodeIsNull : (node)->
		@_throwNullEx(node) if not @_configs[node]
		@

	_throwNullEx : (nodeType)->
		throw new Error("#{nodeType} node is null in hades config, please check it!!")


_instance = new ProjectConfig()

exports.ProjectConfig = _instance