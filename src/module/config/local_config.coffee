Module = require('../../lib/module').Module
IConfig = require('./iconfig').IConfig
fs = require('fs')
path = require('path')

## store
ConfigMap = {}
# NO_EXISTS flag
CONFIG_FILE_NO_EXISTS = "NO_EXISTS"

class LocalConfig extends Module
	@include IConfig
	## local config path
	CONFIG_PATH = "../../setting/"

	constructor : (path)->
		if path?
			CONFIG_PATH = path

	# @Override name:xx/xx.json
	get : (name)->
		throw new Error("config can not end with .json") if name.slice(-5,-1) == ".json"
		if not ConfigMap[name]?
			if fs.existsSync(path)
				ConfigMap[name] = require(@_buildPath(name))
			else
				ConfigMap[name] = CONFIG_FILE_NO_EXISTS
		_val = ConfigMap[name]
		if _val == CONFIG_FILE_NO_EXISTS
			_val = null
		_val

	# @Override
	getDynamic : (name, watcher)->
		@get(name)

	_buildPath : (name)->
		path.normalize(CONFIG_PATH + name + ".json")

exports.LocalConfig = new LocalConfig()