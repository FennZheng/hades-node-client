Module = require('../../lib/module').Module
IConfig = require('./iconfig').IConfig
## store
ConfigMap = {}

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
			ConfigMap[name] = require(CONFIG_PATH+name+".json")
		ConfigMap[name]

	# @Override
	getDynamic : (name, watcher)->
		@get(name)

exports.LocalConfig = new LocalConfig()