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
			listChildren(client, path)
		, (error, children, stat)->
			if error
				console.log('Failed to list children of %s due to: %s.', path, error)
				return
			console.log('Children of %s are: %j.', path, children)
		)
		return

	setConfig : (name, data)->
		path = @_buildPath(name)
		if not @_exist(path)
			@_createPath(path)
		@_set(path, data)
		return


	getConfig : (name)->
		path = @_buildPath(name)
		@_client.getData(path, (error, data, stat)->
			if error
				console.log(error.stack)
				return null
			return data
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

	_buildPath : (name)->
		@_PROJECT_PATH + "/" + name

instance = new ZkProxy()

exports.ZkProxy = instance
