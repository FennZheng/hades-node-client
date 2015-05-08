config = require("./zk_test_util_config.json")
ZK = require('node-zookeeper-client')
Log = require("../src/module/log/log")

class ZkClient
	constructor : ->
		@_inited = false
		@_client = null

	init : ->
		return if @_inited
		_config = config.zookeeperConf
		_clusterList = _config.clusterList
		_retries = _config.retries || 3
		_sessionTimeout = _config.sessionTimeout || 10000
		@_groupId = config.remoteConf.groupId
		@_projectId = config.remoteConf.projectId

		@_client = ZK.createClient(_clusterList, {
			retries: _retries ,
			sessionTimeout: _sessionTimeout
		})
		@_client.connect()
		return

	setData : (name, val, cb)->
		@_client.setData(@_buildPath(name), new Buffer(val), -1, (err, stat)->
			return cb(err, false) if err and cb
			return cb(null, true) if cb
			return
		)

	getData : (name, cb)->
		@_client.getData(@_buildPath(name), null, (err, data, stat)=>
			return cb(err, null) if err and cb
			return cb(null, new String(data, "utf-8")) if cb
			return
		)

	_buildPath : (name)->
		_path = "/hades/configs/" + @_groupId + "/" + @_projectId + "/" + name
		console.log("test _buildPath:#{_path}")
		_path


_instance = new ZkClient()
exports.ZkClient = _instance




