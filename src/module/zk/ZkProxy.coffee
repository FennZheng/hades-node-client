zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/config.json')
RemoteConfigCache = require('../config/RemoteConfigCache').RemoteConfigCache
Fiber = require('fibers')

CONFIG_ROOT_PATH = "/hades/configs"
#TODO 要处理sessionTimeout和connect断开等

class ZkProxy
	@_loadCompleted = false

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
		return

	#util.inherits(ZkProxy, Event.EventEmitter)

	##检查是否加载完成
	checkLoadState : ()->
		@_loadCompleted && true

	load : ()->
		@_loadCompleted = false
		@_client.connect()
		@_client.getChildren(@_PROJECT_PATH, @_initConfigMap.bind(@))

	_initConfigMap : (err, children, stats)->
		if err
			console.log("_initConfigMap error: #{err.stack}")
		if children?
			# fire event when load  complete
			_countDownLatch = new CountDownLatch(children.length, ()-> @_loadCompleted = true)
			for child in children
				@_loadConfigItem(child, _countDownLatch)

	_loadConfigItem : (name, _countDownLatch)->
		_path = @_buildPath(name)
		@_client.getData(_path, null, (error, data, stat)->
			if error
				console.log(error.stack)
			else
				if data?
					RemoteConfigCache[name] = data.toString("utf-8")
				else
					RemoteConfigCache[name] = null
			_countDownLatch.countDown()
			return
		)
		return

	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + @_buildKey(configName)

	_buildKey : (configName)->
		_zkKey = configName
		if configName.slice(-5,-1) == ".json"
			_zkKey = name.slice(0,-5)
		_zkKey

instance = new ZkProxy()


class CountDownLatch
	# count: task count
	# submit: call submit() when task finished
	constructor : (count, submit)->
		@_count = count
		@_submit = submit

	countDown : ()->
		@_count = @_count -1
		if @_count <= 0
			@_submit()
		@_count

exports.ZkProxy = instance
