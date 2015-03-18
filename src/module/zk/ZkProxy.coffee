zookeeper = require('node-zookeeper-client')
zkConfig = require('../setting/config.json')

CONFIG_ROOT_PATH = "/hades/configs/"
#TODO 要处理sessionTimeout
class ZkProxy
	constructor : ()->
		throw new Error("hades-node-client init error: project is null in config.json") if not config.project?
		@_PROJECT_PATH = CONFIG_ROOT_PATH + "/" +config.project
		@_hostList = zkConfig.hostList
		@_retries = zkConfig.retries || 3
		@_sessionTimeout = zkConfig.sessionTimeout || 10000
		@_client = zookeeper.createClient(@_hostList, {
			retries: @_retries ,
			sessionTimeout: @_sessionTimeout
		})
		return

	listChildren : (client,path)->
		@_client.getChildren(
		  path
		, (event)->
			console.log('Got watcher event: %s', event)
		, (error, children, stat)->
			if error
				console.log('Failed to list children of %s due to: %s.', path, error)
				return
			console.log('Children of %s are: %j.', path, children)
		)
		return

	setConfig : (name, data)->
		_path = @_buildPath(name)
		if not @_exist(_path)
			@_createPath(_path)
		@_set(_path, data)
		return


	getConfig : (name)->
		_path = @_buildPath(@_buildKey(name))
		_data = null
		@_client.getData(_path, null, (error, data, stat)->
			if error
				console.log(error.stack)
				_data = null
			else
				_data = data
		)
		_data

	getConfigAndWatch : (name, cb)->
		_path = @_buildPath(@_buildKey(name))
		_data = null
		@_client.getData(
			_path,
			(event)->
				switch event.getType
					when "NODE_CREATED" then getConfigAndWatch(name, )
					when "NODE_DELETED" then cb(name, )
					when "NODE_DATA_CHANGED" then cb(name, event)
					when "NODE_CHILDREN_CHANGED" then cb(null, null)
					else cb(null, null)
				@_trasformEvent(event, data, name, cb)
			,(error, data, stat)->
				if error
					console.log(error.stack)
					_data = null
				else
					_data = data
		)
		_data
		cb(name, value)

	###
        Event.type:
	        NODE_CREATED - Watched node is created.
			NODE_DELETED - watched node is deleted.
			NODE_DATA_CHANGED - Data of watched node is changed.
			NODE_CHILDREN_CHANGED - Children of watched node is changed.
	###
	_trasformEvent : (event, cb)->
		switch event.getType
			when "NODE_CREATED" then cb(event)
			when "NODE_DELETED" then cb(name, )
			when "NODE_DATA_CHANGED" then cb(name, event)
			when "NODE_CHILDREN_CHANGED" then cb(null, null)
			else cb(null, null)

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

	_buildPath : (name)->
		@_PROJECT_PATH + "/" + name

	_buildKey : (configName)->
		_zkKey = configName
		if configName.slice(-5,-1) == ".json"
			_zkKey = name.slice(0,-5)
		_zkKey

instance = new ZkProxy()

exports.ZkProxy = instance
