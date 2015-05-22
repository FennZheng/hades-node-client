ZkClient = require("./lib/zk_tool_util").ZkClient
toolConfig = require("./tool.json")
ZkClient.init(toolConfig)
fs = require("fs")
path = require("path")

# local config map
ConfigMap = {}

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
		return
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
		return

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

# sync
_loadDir = (f)->
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

run = ()->
	_importSettingRoot = process.cwd() + "/import_setting/"
	_loadDir(_importSettingRoot)
	_importUserData(ConfigMap)
	if toolConfig.initSysConfig
		_importSysData()

run()