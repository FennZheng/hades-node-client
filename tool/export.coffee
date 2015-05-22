Fs = require('fs')
Path = require('path')
ZkClient = require("./lib/zk_tool_util").ZkClient
toolConfig = require("./tool.json")
ZkClient.init(toolConfig)

RemoteConfigCache = {}
EXPORTS_ROOT = process.cwd() + "/export_setting/"
PROJECT_PATH = "/hades/configs/" + toolConfig.groupId + "/" + toolConfig.projectId
LOAD_TIMEOUT = 5000
IsLoadCompleted = false
start_time = null

_writeFile = (name, obj)->
	_filePath = Path.normalize(Path.join(EXPORTS_ROOT, name + ".json"))
	Fs.writeFileSync(_filePath, JSON.stringify(obj, null, '\t'), "utf-8")

_dumpToDisk = ->
	for _item of RemoteConfigCache
		_writeFile(_item, RemoteConfigCache[_item])
		console.log("write sysData: #{_item}.json successfully")
	_finishLog()

_finishLog = ->
	console.log("===== all exports finished (count:#{Object.keys(RemoteConfigCache).length},cost:#{(Date.now()-start_time)}ms) =====")

_setLoadTimeout = ->
	setTimeout(=>
		if not IsLoadCompleted
			console.log("Load all config from zookeeper timeout(#{LOAD_TIMEOUT}ms)")
	,LOAD_TIMEOUT)

_createLoadCheck = (taskCount) ->
	_taskCount = taskCount
	_loadTimerId = _setLoadTimeout()
	{
		count : _taskCount,
		timer : _loadTimerId
	}

_fillConfigItem = (child, _check)->
	ZkClient.getData(child, (err, data)=>
		if err
			console.error("_fillConfigItem err:"+err.stack)
		else
			try
				RemoteConfigCache[child] = JSON.parse(data)
			catch err
				console.error("item json parse object error:#{err.stack}")
			if --_check.count <= 0
				IsLoadCompleted = true
				clearTimeout(_check.timer)
				console.log("get remote config completed, start to dump to disk")
				_dumpToDisk()
		return
	)

_initConfigMap = (err, children, stats)=>
	if err
		console.error(err.stack)
	if children?
		_check = _createLoadCheck(children.length)
		for child in children
			_fillConfigItem(child, _check)
	return

_load = ->
	console.log("start _load from PROJECT_PATH:#{PROJECT_PATH}")
	ZkClient.getChildren(PROJECT_PATH, _initConfigMap)

run = ->
	start_time = Date.now()
	_load()

run()


