ZK = require('node-zookeeper-client')
ProjectConfig = require("../project_config").ProjectConfig
Log = require("../log/log")

class ZkClient
	constructor : ->
		@_inited = false
		@_client = null

	init : ->
		return if @_inited
		_config = ProjectConfig.getZookeeperConf()
		_clusterList = _config.clusterList
		_retries = _config.retries || 3
		_sessionTimeout = _config.sessionTimeout || 10000

		@_client = ZK.createClient(_clusterList, {
			retries: _retries ,
			sessionTimeout: _sessionTimeout
		})
		@_client.connect()
		return

	setData : (path, val, cb)->
		@_client.setData(path, val, null, (error, stat)->
			return cb(err, false) if err and cb
			return cb(null, true) if cb
			return
		)

	getData : (path, cb)->
		@_client.getData(path, null, (err, data, stat)=>
			Log.debug("getData:#{path}, err:#{err}, data:#{new String(data, "utf-8")}")
			return cb(err, null) if err and cb
			return cb(null, new String(data, "utf-8")) if cb
			return
		)

	getChildren : (path, cb)->
		@_client.getChildren(path, cb)

	# auto-re-watch, because zk-watcher event only notice once
	setDataAutoUpdate : (path, cb)->
		@_recursiveFetchData(path, false, cb)

	_recursiveFetchData : (path, isFetchData, cb)->
		@_client.getData(path,
			(event)=>
				switch event
					when Event.NODE_CREATED then @_recursiveFetchData(path, true, cb)
					when Event.NODE_DATA_CHANGED then @_recursiveFetchData(path, true, cb)
					else
						@_recursiveFetchData(path, false, cb)
				return
			(err, data, stat)->
				if isFetchData
					cb(err, null) if error and cb
					cb(null, new String(data, "utf-8")) if cb
				return
		)


_instance = new ZkClient()
exports.ZkClient = _instance




