fs = require('fs')
path = require('path')
ProjectConfig = require("../src/module/project_config").ProjectConfig
RemoteConfig = require("../src/module/config/remote_config").RemoteConfig
RemoteConfigMonitor = require("../src/module/config/remote_config_cache").RemoteConfigMonitor
configFile = process.cwd() + "/tool.json"
ProjectConfig.init(configFile)
exportRoot = process.cwd() + "/export_setting/"

console.log("configFile path:#{configFile}")

_validateJSON = (str)->
	try
		JSON.parse(str)
		return true
	catch err
		console.error err.stack
		return false

_writeFile = (name, data)->
	_filePath = path.normalize(path.join(exportRoot, name + ".json"))
	fs.writeFileSync(_filePath, data, "utf-8")

RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_READY,
	->
		console.log("HadesConfig import_setting load completed")
		_sysData = RemoteConfigMonitor.getSysData()
		_userData = RemoteConfigMonitor.getUserData()
		if _sysData
			_sysDataObj = JSON.parse(_sysData)
			for _item of _sysDataObj
				_writeFile(_item, JSON.stringify(_sysDataObj[_item]))
				console.log("write sysData: #{_item}.json successfully")
		if _userData
			_userDataObj = JSON.parse(_userData)
			for _item of _userDataObj
				_writeFile(_item, JSON.stringify(_userDataObj[_item]))
				console.log("write userData: #{_item}.json successfully")
		console.log("export done!")
)
RemoteConfig.on(RemoteConfig.EVENT_REMOTE_CONFIG_TIMEOUT,
	=>
		console.error("HadesConfig export: load remote config timeout")
)
RemoteConfig.init()