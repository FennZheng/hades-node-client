Module = require('../../lib/Module').Module
IConfig = require('./IConfig').IConfig
LocalConfig = require('./LocalConfig').LocalConfig
RemoteConfig = require('./RemoteConfig').RemoteConfig

class ConfigProxy extends Module
	get : (name)->
		_val = LocalConfig.get(name)
		if not _val?
			_val = RemoteConfig.get(name)
		_val

	getDynamic : (name)->
		_val = LocalConfig.getDynamic(name)
		if not _val?
			_val = RemoteConfig.getDynamic(name)
		_val
