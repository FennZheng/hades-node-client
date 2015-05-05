zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/hades_config.json')
RemoteConfigCache = require('../config/remote_config_cache').RemoteConfigCache
util = require('util')
EventEmitter = require('events').EventEmitter

CONFIG_ROOT_PATH = "/hades/configs"
SERVICE_ROOT_PATH = "hades/services"
DEFAULT_GROUP = "main"
LOCAL_IP = require("../util/ip_util").LOCAL_IP

DEBUG = true

#TODO deal with sessionTimeout and connection closed event
EVENT_ALL_LOAD_COMPLETE = "LOAD_COMPLETE"
EVENT_ALL_LOAD_TIMEOUT = "LOAD_TIMEOUT"

CONFIG_VERSION_CONTROL = "_versionControl"

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
		@_maxUpdateInterval = zkConfig.MaxUpdateInterval || 60000
		@_client.connect()
		return

	checkLoadState : ->
		@_loadState

	load : ->
		throw new Error("ZkProxy load duplicate invoke!!") if @checkLoadState() != LOAD_STATE.NO_LOADING
		@_loadState = LOAD_STATE.LOADING
		@_client.getChildren(@_PROJECT_PATH, @_initConfigMap)

	_initConfigMap : (err, children, stats)=>
		# global cache ,clear it up
		RemoteConfigCache.init()
		if err
			@_errorLogMsg(err.stack)
		if children?
			_taskCount = children.length
			_loadTimerId = @_setLoadTimeout()
			_task = {
				count : _taskCount,
				timer : _loadTimerId
			}
			for child in children
				@_fillConfigItem(child, _task)

		return

	_fillConfigItem : (child, _task)->
		_path = @_buildPath(child)
		@_client.getData(_path, null, (err, data, stat)=>
			@_debugLog("_taskCount:#{_task.count}   get data!!!!")
			if err
				console.log("err:"+err.stack)
			else
				RemoteConfigCache.set(child, new String(data, "utf-8"))
				if --_task.count <= 0
					@_loadState = LOAD_STATE.LOAD_COMPLETE
					@.emit(_instance.EVENT_ALL_LOAD_COMPLETE)
					clearTimeout(_task.timer)
			return
		)

	_setLoadTimeout : =>
		setTimeout(=>
			if @checkLoadState() != LOAD_STATE.LOAD_COMPLETE
				@.emit(_instance.EVENT_ALL_LOAD_TIMEOUT)
				console.error("load all config from zk timeout(#{@_loadTimeout}ms)")
		,@_loadTimeout)

	_errorLogMsg : (msg)->
		console.log(msg)

	_debugLog : (msg)->
		console.log(msg) if DEBUG

	# build zookeeper node full path by config name
	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + configName

	registerService : (serviceId, meta)->
		_path = @_buildServicePath(serviceId)
		@_client.setData(_path, meta, -1, (error, stat)->
			if error
				console.error("registerService setData error:"+error.stack)
			console.log("Data is set")
			return
		)

	_buildServicePath : (serviceId)->
		SERVICE_ROOT_PATH + "/" + DEFAULT_GROUP + "/" + serviceId

	# auto-register, because zk-watcher event only notice once
	regConfWatcher : (name)->
		_path = @_buildPath(name)
		@_client.getData(_path,
			(event)->
				console.log("event:#{event}")
			(err, data, stat)=>
				@_debugLog("regConfWatcher:#{name} get data!!!!")
				if err
					console.log("err:"+err.stack)
				else
					RemoteConfigCache.set(name, new String(data, "utf-8"))
					@regConfWatcher(name)
				return
		)

	setCheckUpdateLoop : ->
		setInterval(
			=>
				@_client.getData(ZkProxy.KEY_VERSION_CONTROL, null, (err, data, stat)=>
					@_debugLog("_checkLastModifyTime:#{name} get data!!!!")
					if err
						console.log("err:"+err.stack)
					else
						RemoteConfigCache.set(name, new String(data, "utf-8"))
					return
				)
			,@_maxUpdateInterval
		)

	updateConfig : (name)->
		_path = @_buildPath(name)
		@_client.getData(_path,
		    (event)->
				console.log("event:#{event}")
			(err, data, stat)=>
				@_debugLog("regConfWatcher:#{name} get data!!!!")
				if err
					console.log("err:"+err.stack)
				else
					RemoteConfigCache.set(name, new String(data, "utf-8"))
					@regConfWatcher(name)
				return
		)

_instance = new ZkProxy()
# export singleton
exports.ZkProxy = _instance

# export stat enum
for state in LOAD_STATE
	exports[state.key] = state.value

exports.EVENT_ALL_LOAD_COMPLETE = EVENT_ALL_LOAD_COMPLETE
exports.EVENT_ALL_LOAD_TIMEOUT = EVENT_ALL_LOAD_TIMEOUT