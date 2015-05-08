fs = require('fs')
path = require('path')
EventEmitter = require('events').EventEmitter
ProjectConfig = require("../project_config").ProjectConfig
Log = require("../log/log")

## store
ConfigMap = {}
EVENT_LOCAL_CONFIG_READY = "EVENT_LOCAL_CONFIG_READY"

class LocalConfig extends EventEmitter
	## local config path
	constructor : ->
		@_configPath = null

	init : ->
		_config = ProjectConfig.getLocalConfig()
		@_configPath = _config["confRoot"]
		Log.error("LocalConfig configRoot is null!!!") if not @_configPath

		@_loadDir(path.normalize(@_configPath))
		@.emit(_instance.EVENT_LOCAL_CONFIG_READY)

	# @Override name:xx/xx.json
	get : (name)->
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
				_key = path.basename(_fName, ".json")
				if ConfigMap[_key]
					throw new Error("local file name : [#{_key}.json] is duplicate!!!! please check!!")
				ConfigMap[path.basename(_fName, ".json")] = require(_fName)
		return

_instance = new LocalConfig()
_instance.EVENT_LOCAL_CONFIG_READY = EVENT_LOCAL_CONFIG_READY

exports.LocalConfig = _instance
