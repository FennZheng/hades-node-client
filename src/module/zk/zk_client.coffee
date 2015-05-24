ZK = require('node-zookeeper-client')
ProjectConfig = require("../project_config").ProjectConfig
Log = require("../log").Log
KEY_REGEX = new RegExp(".+/")

class ZkClient
	constructor : ->
		@_inited = false
		@_client = null
		@isConnected = false

	init :(cb) ->
		return cb(null, true) if @_inited
		_config = ProjectConfig.getZookeeperConf()
		_clusterList = _config.clusterList
		_retries = _config.retries || 3
		_sessionTimeout = _config.sessionTimeout || 2000
		_connectTimeout = _config.connectTimeout || 2000

		@_client = ZK.createClient(_clusterList, {
			retries: _retries ,
			sessionTimeout: _sessionTimeout
		})
		@_initEventListener()
		@_connect(_connectTimeout, cb)
		return

	_connect : (connectTimeout, cb)->
		_timerId = setTimeout(->
			cb(new Error("ZkClient connect timeout(#{connectTimeout}ms)!!"), false)
		,connectTimeout)
		@_client.once("connected", ()=>
			clearTimeout(_timerId)
			@isConnected = true
			cb(null, true)
		)
		@_client.connect()

	_initEventListener : ->
		@_client.on("disconnected", ()->
			Log.info("ZKClient receive event:disconnected")
			@isConnected = false
		)
		@_client.on("connected", ()->
			Log.info("ZKClient receive event:connected")
			@isConnected = true
		)
		@_client.on("connectedReadOnly", ()->
			Log.info("ZKClient receive event:connectedReadOnly")
		)
		@_client.on("expired", ()->
			Log.info("ZKClient receive event:expired")
		)
		@_client.on("authenticationFailed", ()->
			Log.info("ZKClient receive event:authenticationFailed")
		)
		
	exists : (path, val, cb)->
		@_client.exists(path, null, -1, cb)

	setData : (path, val, cb)->
		_buffer = null
		_buffer = new Buffer(val) if val
		@_client.setData(path, _buffer, -1, (err, stat)->
			if err
				if cb
					return cb(err, false)
				else
					Log.error("setData for path: #{path} error:#{err.stack}")
					return
			cb(null, true) if cb
		)

	create : (path, val, isPersistence, cb)->
		_nodeMode = ZK.CreateMode.PERSISTENT
		_nodeMode = ZK.CreateMode.EPHEMERAL if not isPersistence
		_buffer = null
		_buffer = new Buffer(val) if val
		@_client.create(path, _buffer, _nodeMode, (err, path)->
			if err and err.getCode() != ZK.Exception.NODE_EXISTS
				if cb
					return cb(err, false)
				else
					Log.error("create for path:#{path} isPersistence:#{isPersistence} error: #{err.stack}")
					return
			Log.info("create success for path :#{path} isPersistence:#{isPersistence}")
			return cb(null, true) if cb
		)


	addChildren : (parentPath, childPath, meta, cb)->
		self = @
		@_client.exists(parentPath, null, (err, stat)->
			if err
				if cb
					return cb(err, false)
				else
					Log.error("addChildren for parentPath: #{parentPath} , childPath: #{childPath} ,error: #{err.stack}")
					return
			if stat
				#exists
				self.create(childPath, meta, false, cb)
			else
				self._client.mkdirp(parentPath, null, null, ZK.CreateMode.PERSISTENT, (err, result)->
					if err
						if err.getCode() == ZK.Exception.NODE_EXISTS
							# created by other client
							self.create(childPath, meta, false, cb)
							return
						if cb
							return cb(err, false)
						else
							Log.error("addChildren create for path :#{childPath} error:#{err.stack}")
							return
					self.create(childPath, meta, false, cb)
				)
		)

	getData : (path, cb)->
		@_client.getData(path, null, (err, data, stat)=>
			if err
				if cb
					return cb(err, null)
				else
					Log.error("getData for path:#{path}, error:#{err.stack}")
					return
			return cb(null, new String(data, "utf-8")) if cb
		)

	getChildren : (path, cb)->
		@_client.getChildren(path, cb)

	# for config : auto-re-watch
	setDataAutoUpdate : (path, cb)->
		@_recFetchNodeData(path, false, cb)

	# for service-discovery : auto-re-watch
	getChildDataAndWatch : (path, cb)->
		@_recFetchChildData(path, true, cb)

	_recFetchChildData : (path, isFetchData, cb)->
		#Log.debug("_recursiveFetchData path:#{path}, isFetchData:#{isFetchData}")
		@_client.getChildren(path,
			(event)=>
				return @_recFetchChildData(path, false, cb) if not event
				Log.debug("receive event #{event.name} for path:#{path}")
				switch event.type
					when ZK.Event.NODE_CREATED then @_recFetchChildData(path, true, cb)
					when ZK.Event.NODE_CHILDREN_CHANGED then @_recFetchChildData(path, true, cb)
					else
						@_recFetchChildData(path, false, cb)
				return
			(err, data, stat)=>
				if isFetchData
					#TODO deal with connection loss exception
					if err
						if err.getCode() == ZK.Exception.NO_NODE
							Log.error("NO_NODE found for path: #{path}")
							return
						else if err.getCode() == ZK.Exception.CONNECTION_LOSS
							@_client.connect()
						if cb
							return cb(err, null, null)
						else
							Log.error("auto-update for path:#{path} error:#{err.stack}")
					return cb(null, @_getKeyByPath(path), new String(data, "utf-8")) if cb
		)

	_recFetchNodeData : (path, isFetchData, cb)->
		#Log.debug("_recursiveFetchData path:#{path}, isFetchData:#{isFetchData}")
		@_client.getData(path,
			(event)=>
				return @_recFetchNodeData(path, false, cb) if not event
				Log.debug("receive event #{event.name} for path:#{path}")
				switch event.type
					when ZK.Event.NODE_CREATED then @_recFetchNodeData(path, true, cb)
					when ZK.Event.NODE_DATA_CHANGED then @_recFetchNodeData(path, true, cb)
					else
						@_recFetchNodeData(path, false, cb)
				return
			(err, data, stat)=>
				if isFetchData
					#TODO deal with connection loss exception
					if err
						if err.getCode() == ZK.Exception.NO_NODE
							Log.error("NO_NODE found for path: #{path}")
							return
						else if err.getCode() == ZK.Exception.CONNECTION_LOSS
							@_client.connect()
						if cb
							return cb(err, null, null)
						else
							Log.error("auto-update for path:#{path} error:#{err.stack}")
					return cb(null, @_getKeyByPath(path), new String(data, "utf-8")) if cb
		)

	_getKeyByPath : (path)->
		return "" if not path
		path.replace(KEY_REGEX,"")

_instance = new ZkClient()
exports.ZkClient = _instance

