fs = require('fs')
path = require('path')
EventEmitter = require('events').EventEmitter

## store
ConfigMap = {}
LOCAL_CONFIG_READY = "LOCAL_CONFIG_READY"

class LocalConfig extends EventEmitter
	## local config path
	constructor : ->
		@_configPath = "/Users/vernonzheng/Project/github/hades-node-client/src/setting"

	init : (configRoot)->
		if configRoot?
			@_configPath = configRoot
		else
			console.error("LocalConfig configRoot is null!!!")
		@_loadDir(path.normalize(@_configPath))
		@.emit(_instance.LOCAL_CONFIG_READY)

	# @Override name:xx/xx.json
	get : (name)->
		throw new Error("config can not end with .json") if name.slice(-5,-1) == ".json"
		_val = ConfigMap[name]
		return null if not _val
		return _val

	# @Override
	getDynamic : (name, watcher)->
		@get(name)

	# 同步递归 读取配置
	_loadDir : (f)->
		_files = fs.readdirSync(f)
		for _item of _files
			_fName = path.join(f, _files[_item])
			_fStat = fs.lstatSync(_fName)
			if _fStat.isDirectory()
				@_loadDir(_fName)
			else if path.extname(_fName) == ".json"
				ConfigMap[path.basename(_fName, ".json")] = require(_fName)
		return

_instance = new LocalConfig()
exports.LocalConfig = _instance
exports.LOCAL_CONFIG_READY = LOCAL_CONFIG_READY