zookeeper = require('node-zookeeper-client')
zkConfig = require('../../setting/hades_config.json')
RemoteConfigCache = require('../config/remote_config_cache').RemoteConfigCache
util = require('util')
Events = require('events')

CONFIG_ROOT_PATH = "/hades/configs"

#TODO deal with sessionTimeout and connection closed event
# event started with _ is inner event
EVENT = {
	EVENT_ALL_LOAD_COMPLETE : "LOAD_COMPLETE",
	EVENT_ALL_LOAD_TIMEOUT : "LOAD_TIMEOUT"
}

LOAD_STATE = {
	LOADING : "1",
	LOAD_COMPLETE : "2",
	LOAD_TIMEOUT : "-1"
}

class ZkProxy

	constructor : ()->
		throw new Error("init error: project is null or hostList is null") if not zkConfig.project?
		@_loadState= false
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

	util.inherits(@, Events.EventEmitter)

	##check if load completed
	checkLoadState : ()->
		@_loadState

	load : ()->
		throw new Error("ZkProxy load duplicate invoke!!") if @checkLoadState() == LOAD_STATE.LOAD_COMPLETE
		@_loadCompleted = false
		@_client.connect()
		@_client.getChildren(@_PROJECT_PATH, @_initConfigMap.bind(@))

	_initConfigMap : (err, children, stats)->
		# clear up
		RemoteConfigCache = {}
		if err
			@_errorLogMsg(err.stack)
		if children?
			_taskCompleteQueue = new TaskCompleteQueue(children, ()->@_loadComplete())
			new TaskTimeoutCheck(_taskCompleteQueue).run(@_loadAllComplete)
			for child in children
				@_loadConfigItem(child, _taskCompleteQueue)

	_loadConfigItem : (name, _taskCompleteQueue)->
		_path = @_buildPath(name)
		@_client.getData(_path, null, (err, data, stat)->
			if err
				@_errorLogMsg("_loadConfigItem name: #{name} error: #{err.stack}")
			else
				@_loadItemComplete(name, data)
			_taskCompleteQueue.complete(name)
			return
		)
		return

	_loadItemComplete : (name, data)->
		if data?
			RemoteConfigCache[name] = data
		else
			delete RemoteConfigCache[name]

	_loadAllComplete : ()->
		@_loadCompleted = true
		@.emit(EVENT.EVENT_ALL_LOAD_COMPLETE)

	_loadAllTimeout : (err)->
		@_errorLogMsg(err.stack)
		@.emit(EVENT.EVENT_ALL_LOAD_TIMEOUT)

	_errorLogMsg : (msg)->
		console.log(msg)

	# build zookeeper node full path by config name
	_buildPath : (configName)->
		@_PROJECT_PATH + "/" + configName


class TaskTimeoutCheck
	_taskCompleteQueue = null
	constructor : (taskCompleteQueue)->
		_taskCompleteQueue = taskCompleteQueue
	run : (cb)->
		#nodejs 里setTimeout有更好的替代方案吗？
		setTimeout(
			()->
				if not @_loadCompleted
					_errorMsg = "load all configs timeout , except finished in #{@_loadTimeout} ,
								see unfinished tasks as follows:"
					_errorMsg += _taskCompleteQueue.getInComplete().join(",")
					cb(new Error(_errorMsg))
		, @_loadTimeout
		)
		return

class TaskCompleteQueue
	# tasks: task name array
	# submit: call submit() when task finished
	constructor : (tasks, submit)->
		@_count = tasks.length
		@_tasks = tasks
		@_submit = submit

	complete : (task)->
		@_count = @_count -1
		@_tasks.remove(task)
		if @_count <= 0
			@_submit()
		@_count

	getInComplete : ()->
		@_tasks


# export singleton
exports.ZkProxy = new ZkProxy()
# export event enum
for event in EVENT
	exports[event.key] = event.value

# export stat enum
for state in LOAD_STATE
	exports[state.key] = state.value