zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/hades_config.json')
RemoteConfigCache = require('../config/remote_config_cache').RemoteConfigCache

CONFIG_ROOT_PATH = "/hades/configs"

#TODO deal with sessionTimeout and connection closed event

@_event = {
	EVENT_ALL_LOAD_COMPLETE : "ALL_LOAD_COMPLETE",
	EVENT_ITEM_LOAD_COMPLETE : "ITEM_LOAD_COMPLETE",
	EVENT_LOAD_ERROR : "LOAD_ERROR"
}

class ZkProxy
	# event
	util.inherits(@, Event.EventEmitter)
	@.on(@EVENT_ALL_LOAD_COMPLETE, ()->	@_loadCompleted = true)
	@.on(@EVENT_ITEM_LOAD_COMPLETE, (name, data)->
		if data?
	        RemoteConfigCache[name] = data
	    else
			delete RemoteConfigCache[name]
	)
	@.on(@EVENT_LOAD_ERROR,(err)-> console.log("LOAD ERROR:#{err.stack}"))

	constructor : ()->
		throw new Error("init error: project is null or hostList is null") if not zkConfig.project?
		@_PROJECT_PATH = CONFIG_ROOT_PATH + "/" +zkConfig.project
		@_hostList = zkConfig.hostList
		@_retries = zkConfig.retries || 3
		@_sessionTimeout = zkConfig.sessionTimeout || 10000
		@_loadTimeout = zkConfig.loadTimeout || 10000
		@_client = zookeeper.createClient(@_hostList, {
			retries: @_retries ,
			sessionTimeout: @_sessionTimeout
		})
		return

	##check if load completed
	checkLoadState : ()->
		@_loadCompleted && true

	load : ()->
		@_loadCompleted = false
		@_client.connect()
		@_client.getChildren(@_PROJECT_PATH, @_initConfigMap.bind(@))

	_initConfigMap : (err, children, stats)->
		# clear up
		RemoteConfigCache = {}
		if err
			@emit(@EVENT_LOAD_ERROR, err)
		if children?
			_countDownLatch = new CountDownLatch(children.length, ()->@emit(@EVENT_ALL_LOAD_COMPLETE))
			for child in children
				@_loadConfigItem(child, _countDownLatch)

	_loadConfigItem : (name, _countDownLatch)->
		_path = @_buildPath(name)
		@_client.getData(_path, null, (err, data, stat)->
			if err
				@emit(@EVENT_LOAD_ERROR, err)
			else
				@emit(@EVENT_ITEM_LOAD_COMPLETE, name, data)
			_countDownLatch.countDown()
			return
		)
		return

	# build zookeeper node full path by config name
	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + configName

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

# export singleton
exports.ZkProxy = new ZkProxy()
# export event enum
for event in @_event
	exports[event.key] = event.value
