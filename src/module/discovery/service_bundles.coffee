ZkClient = require("../zk/zk_client").ZkClient
Log = require("../log/log")

SERVICE_ROOT = "/hades/services/"
ProjectConfig = require("../project_config").ProjectConfig

class ServiceBundles
	constructor : ->

	init :(confFile) ->
		ProjectConfig.init(confFile)
		_config = ProjectConfig.getServiceDiscovery()
		@_GROUP_ID = _config["groupId"]

	register : (serviceId, meta)->
		_path = @_buildServicePath(serviceId)
		ZkClient.setData(_path, meta, (err, result)->
			if not result
				Log.error("ServiceBundles register error for #{serviceId}: #{err?.stack}")
			else
				Log.info("ServiceBundles register success for #{serviceId}")
		)

	_buildServicePath : (serviceId)->
		SERVICE_ROOT + @_GROUP_ID + "/" + serviceId
