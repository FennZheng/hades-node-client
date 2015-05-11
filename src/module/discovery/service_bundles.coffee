ZkClient = require("../zk/zk_client").ZkClient
Log = require("../log/log")
LOCAL_IP = require("../util/ip_util").LOCAL_IP

SERVICE_ROOT = "/hades/services/"
ProjectConfig = require("../project_config").ProjectConfig

class ServiceBundles
	constructor : ->

	init :(confFile) ->
		ProjectConfig.init(confFile)
		ZkClient.init()
		_config = ProjectConfig.getServiceDiscovery()
		@_GROUP_ID = _config["groupId"]
		@_PORT = _config["port"]

	register : (serviceId, meta, cb)->
		_parentPath = @_buildServicePath(serviceId)
		_childPath = _parentPath + "/" + LOCAL_IP + "/" + @_PORT
		ZkClient.addChildren(_parentPath, _childPath, meta, (err, result)->
			if err
				if cb
					return cb(err, false)
				else
					Log.error("register for parentPath:#{_parentPath}, childPath:#{_childPath}, error:#{err.stack}")
					return
			return cb(null, true) if cb
		)

	get : (serviceId, cb)->
		_path = @_buildServicePath(serviceId)
		ZkClient.getChildDataAndWatch(_path, (err, data)->
			if err
				if cb
					return cb(err, null)
				else
					Log.error("ServiceBundles get service list error:#{err.stack}")
					return
			return cb(null, data) if cb
		)

	_buildServicePath : (serviceId)->
		SERVICE_ROOT + @_GROUP_ID + "/" + serviceId

_instance = new ServiceBundles()

exports.ServiceBundles = _instance