Module = require('../../lib/Module').Module
IConfig = require('./IConfig').IConfig
## store
ConfigMap = {}

class LocalConfig extends Module
	@include IConfig
	## local config path
	CONFIG_PATH = "../../setting/"

	constructor : (path)->
		if path?
			CONFIG_PATH = path

	## @Override
	load : ()->
		# lazy load by @get

	## @Override name:xx/xx.json
	get : (name, isDynamic)->
		if not ConfigMap[name]?
			if name.slice(-5,-1) == ".json"
				ConfigMap[name] = require(CONFIG_PATH+name)
			else
				ConfigMap[name] = require(CONFIG_PATH+name+".json")
		ConfigMap[name]

exports.LocalConfig = LocalConfig