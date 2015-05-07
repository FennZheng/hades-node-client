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
		@_client.setData(path, new Buffer(val), -1, (err, stat)->
			return cb(err, false) if err and cb
			return cb(null, true) if cb
			return
		)

	getData : (path, cb)->
		@_client.getData(path, null, (err, data, stat)=>
			return cb(err, null) if err and cb
			return cb(null, new String(data, "utf-8")) if cb
			return
		)

	getChildren : (path, cb)->
		@_client.getChildren(path, cb)

	# auto-re-watch, because zk-watcher event only notice once
	setDataAutoUpdate : (path, cb)->
		@_recursiveFetchData(path, false, cb)

	#TODO Nodejs是否支持尾递归优化？？？
	_recursiveFetchData : (path, isFetchData, cb)->
		Log.debug("_recursiveFetchData path:#{path}, isFetchData:#{isFetchData}")
		@_client.getData(path,
			(event)=>
				return @_recursiveFetchData(path, false, cb) if not event
				switch event.type
					when ZK.Event.NODE_CREATED then @_recursiveFetchData(path, true, cb)
					when ZK.Event.NODE_DATA_CHANGED then @_recursiveFetchData(path, true, cb)
					else
						@_recursiveFetchData(path, false, cb)
				return
			(err, data, stat)->
				if isFetchData
					cb(err, null) if err and cb
					cb(null, new String(data, "utf-8")) if cb
				return
		)


_instance = new ZkClient()
exports.ZkClient = _instance




