Module = require('../../lib/module').Module
IConfig = require('./i_config').IConfig
LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig

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
