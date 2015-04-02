Module = require('../../lib/module').Module
IConfig = require('./iconfig').IConfig
LocalConfig = require('./local_config').LocalConfig
RemoteConfig = require('./remote_config').RemoteConfig

class ConfigProxy extends IConfig
	get : (name)->
		_val = LocalConfig.get(name)
		if not _val?
			_val = RemoteConfig.get(name)
		#TODO _val如果获取不到应该写日志
		_val

	getDynamic : (name, watcher)->
		_val = LocalConfig.getDynamic(name, watcher)
		if not _val?
			_val = RemoteConfig.getDynamic(name, watcher)
		_val


