zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/config.json')
ConfigMap = require('./RemoteConfigStore').ConfigMap

CONFIG_ROOT_PATH = "/hades/configs"
#TODO 要处理sessionTimeout
class ZkProxy
	constructor : ()->
		throw new Error("hades-node-client init error: project is null in config.json") if not zkConfig.project?
		@_PROJECT_PATH = CONFIG_ROOT_PATH + "/" +zkConfig.project
		@_hostList = zkConfig.hostList
		@_retries = zkConfig.retries || 3
		@_sessionTimeout = zkConfig.sessionTimeout || 10000
		@_client = zookeeper.createClient(@_hostList, {
			retries: @_retries ,
			sessionTimeout: @_sessionTimeout
		})
		@_client.connect()
		return

	_setConfig : (name, data)->
		_path = @_buildPath(name)
		if not @_exist(_path)
			@_createPath(_path)
		@_set(_path, data)
		return

	loadConfig : (name)->
		_path = @_buildPath(name)
		console.log("loadConfig name:#{name} ,path:#{_path}")

		@_client.getData(_path, null, (error, data, stat)->
			if error
				console.log(error.stack)
			else
				if data?
					ConfigMap[name] = data.toString("utf-8")
				else
					delete ConfigMap[name]
		)

	loadConfigAndWatch : (name)->
		_path = @_buildPath(name)
		console.log("loadConfigAndWatch name:#{name} ,path:#{_path}")
		@_client.getData(
		  _path,
		(event)->
			console.log("receive event:"+zookeeper.Event.NODE_DATA_CHANGED)
			switch event.getType
				when zookeeper.Event.NODE_DATA_CHANGED then @loadConfigAndWatch(name)
				else
					console.log("path #{event.getPath()} changed: #{event.getType()}")
		,(error, data, stat)->
			if error
				console.log(error.stack)
			else
				if data?
					ConfigMap[name] = data.toString("utf-8")
				else
					delete ConfigMap[name]
		)

	_getDataAndNotify : (path, cb)->
		_name = @_getConfigName(path)
		@_client.getData(
		  path
		,(err, data, stat)->
			if error
				console.log("get data error when data changed :"+err.stack)
			else
				if data?
					cb(_name, data.toString("utf-8"))
				else
					cb(_name, null)
		)

	_createPath : (path)->
		@_client.create(path, (error)->
			if error
				console.log('Failed to create node: %s due to: %s.', path, error)
			console.log('Node: %s is successfully created.', path)
		)

	_set : (path, data)->
		@_client.setData(path, null, -1,  (error, stat)->
			if error
				console.log(error.stack)
			console.log('Data is set at path :%s', path)
		)

	# return false if error
	_exist : (path)->
		@_client.exists(path, (error, stat)->
			if error
				console.log(error.stack)
			if stat
				return true
			return false
		)

	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + @_buildKey(configName)

	_buildKey : (configName)->
		_zkKey = configName
		if configName.slice(-5,-1) == ".json"
			_zkKey = name.slice(0,-5)
		_zkKey

	_getConfigName : (path)->
		path.replace(@_PROJECT_PATH+"/", "")


instance = new ZkProxy()

exports.ZkProxy = instance
