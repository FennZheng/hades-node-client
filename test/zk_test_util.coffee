config = require("./zk_test_util_config.json")
ZK = require('node-zookeeper-client')
Log = require("../src/module/log/log")

class ZkClient
	constructor : ->
		@_inited = false
		@_client = null

	init : ->
		return if @_inited
		@_groupId = config.groupId
		@_projectId = config.projectId
		@_client = ZK.createClient(config.zookeeper, {
			retries: 3 ,
			sessionTimeout: 10000
		})
		#监听所有事件
		###看代码有，disconnected，connected，connectedReadOnly，expired，authenticationFailed
			this.emit('disconnected');
        ###
		@_client.on("disconnected", ()->
			console.log("ZKClient receive event:disconnected")
		)
		@_client.on("connected", ()->
			console.log("ZKClient receive event:connected")
		)
		@_client.on("connectedReadOnly", ()->
			console.log("ZKClient receive event:connectedReadOnly")
		)
		@_client.on("expired", ()->
			console.log("ZKClient receive event:expired")
		)
		@_client.on("authenticationFailed", ()->
			console.log("ZKClient receive event:authenticationFailed")
		)
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




