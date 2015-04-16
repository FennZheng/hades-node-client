zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/hades_config.json')
RemoteConfigCache = require('../config/remote_config_cache').RemoteConfigCache
util = require('util')
EventEmitter = require('events').EventEmitter

CONFIG_ROOT_PATH = "/hades/configs"
DEBUG = true

#TODO deal with sessionTimeout and connection closed event
EVENT = {
	EVENT_ALL_LOAD_COMPLETE : "LOAD_COMPLETE",
	EVENT_ALL_LOAD_TIMEOUT : "LOAD_TIMEOUT"
}

LOAD_STATE = {
	NO_LOADING : "0",
	LOADING : "1",
	LOAD_COMPLETE : "2"
}

class ZkProxy extends EventEmitter

	constructor : ->
		throw new Error("init error: project is null or hostList is null") if not zkConfig.project?
		@_loadState= LOAD_STATE.NO_LOADING
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
	checkLoadState : ->
		@_loadState

	load : ->
		throw new Error("ZkProxy load duplicate invoke!!") if @checkLoadState() != LOAD_STATE.NO_LOADING
		@_loadState = LOAD_STATE.LOADING
		@_client.connect()
		@_client.getChildren(@_PROJECT_PATH, @_initConfigMap)

	_initConfigMap : (err, children, stats)=>
		# global cache ,clear it up
		RemoteConfigCache.init()
		if err
			@_errorLogMsg(err.stack)
		if children?
			_taskCount = children.length
			_loadTimerId = @_setLoadTimeout()
			for child in children
				@_fillConfigItem(child, _taskCount, _loadTimerId)

		return

	_fillConfigItem : (child, _taskCount, _loadTimerId)->
		_path = @_buildPath(child)
		@_client.getData(_path, null, (err, data, stat)=>
			if err
				console.log("err:"+err.stack)
			else
				RemoteConfigCache.set(child, new String(data, "utf-8"))
				if --_taskCount <= 0
					@_loadState = LOAD_STATE.LOAD_COMPLETE
					@.emit(EVENT.EVENT_ALL_LOAD_COMPLETE)
					clearTimeout(_loadTimerId)
			return
		)

	_setLoadTimeout : ->
		setTimeout(->
			if @checkLoadState() != LOAD_STATE.LOAD_COMPLETE
				@.emit(EVENT.EVENT_ALL_LOAD_TIMEOUT)
				console.error("load all config from zk timeout(#{@_loadTimeout}ms)")
		,@_loadTimeout)

	_errorLogMsg : (msg)->
		console.log(msg)

	_debugLog : (msg)->
		console.log(msg) if DEBUG

	# build zookeeper node full path by config name
	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + configName

	register : ()->


# export singleton
exports.ZkProxy = new ZkProxy()

# export stat enum
for state in LOAD_STATE
	exports[state.key] = state.value

# export event enum
for event in EVENT
	exports[event.key] = event.value