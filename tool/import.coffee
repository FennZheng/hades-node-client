ProjectConfig = require("../src/module/project_config").ProjectConfig
LocalConfig = require("../src/module/config/local_config").LocalConfig
ZkClient = require("./lib/zk_tool_util").ZkClient
configFile = process.cwd() + "/tool.json"
ProjectConfig.init(configFile)

ZkClient.init()

console.log("configFile path:#{configFile}")
# import sys data, _globalLock, _whiteIpList, _versionControl

_SYS_KEY = {
	"GlobalLock" : {
		"name": "_globalLock",
		"value": JSON.stringify({
			"clientUpdateLock": false
		})
	},
	"WhiteIpList" : {
		"name": "_whiteIpList",
		"value": JSON.stringify([])
	},
	"VersionControl" : {
		"name": "_versionControl",
		"value": JSON.stringify({
			"lastModifyTime": Date.now()
		})
	}
}

#import use data
_importUserData = (userData)->
	console.log("start import user data")
	if not userData
		console.eror("userData is null")
		process.exit("-1")
	for _item of userData
		if _item and userData[_item]
			_setData(_item, JSON.stringify(userData[_item]))

_importSysData = ->
	console.log("start import sys data")
	for _key of _SYS_KEY
		_obj = _SYS_KEY[_key]
		_setData(_obj.name, _obj.value)

_setData = (key, val)->
	if not _validateJSON(val)
		console.error("setData for key:#{key}, content is not a json, value:#{val}")
		process.exit(-1)

	ZkClient.setData(key, val, (err, result)->
		if err
			console.error("setData for key:#{key}, error:#{err.stack}")
			process.exit(-1)
		console.log("setData for key:#{key}, success")
	)


_validateJSON = (str)->
	try
		JSON.parse(str)
		return true
	catch err
		return err


LocalConfig.on(LocalConfig.EVENT_LOCAL_CONFIG_READY,
	=>
		console.log("HadesConfig import_setting load completed")
		_userData = LocalConfig.getAll()
		_importSysData()
		_importUserData(_userData)
)
LocalConfig.init()