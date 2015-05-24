RemoteConfigMonitor = require("../config/remote_config").RemoteConfigMonitor
Log = require("../log").Log
util = require("util")

START_REGEX = new RegExp("^(/)+")
END_REGEX = new RegExp("(/)+$")

resolve = (path)->
	return null if not path
	# cut off both ends of '/'
	path = path.replace(START_REGEX, "")
	path = path.replace(END_REGEX, "")
	_lowerCasePath = path.toLowerCase()
	# return may be favicon.ico
	return null if path.indexOf("monitor") != 0

	Log.debug("resolve param path:#{path}")
	for _route of _routes.EQ
		if _route == _lowerCasePath
			Log.debug("resolve find EQ: _route:#{_route}, path:#{path}")
			return _routes.EQ[_route]()
	for _route of _routes.START_WITH
		if _lowerCasePath.indexOf(_route) == 0
			Log.debug("resolve find START_WITH: _route:#{_route}, param :#{path.substring(_route.length, path.length)}")
			#TODO path.replace not work
			return _routes.START_WITH[_route](path.substring(_route.length, path.length))
	return null

_getTotal = ->
	JSON.stringify({
		"status" : JSON.parse(RemoteConfigMonitor.getStatusStr()),
		"content" : JSON.parse(RemoteConfigMonitor.getContentStr())
	}, null, 4)

_getSysData = ->
	RemoteConfigMonitor.getSysDataStr()

_getUserData = (keyPath)->
	return RemoteConfigMonitor.getUserDataKeysStr() if not keyPath
	try
		keyPath = keyPath.substring(1, keyPath.length) if keyPath.substring(0,1) == "/"
		_keyLiteral = keyPath.split("/")
		_key = _keyLiteral[0]
		_itemStr = RemoteConfigMonitor.getUserDataStrByKey(_key)
		return null if not _itemStr

		_userDataObj = JSON.parse(_itemStr)
		return _itemStr if _keyLiteral.length == 1
		_val =  _recursiveFetch(_userDataObj, _keyLiteral, 1)
		return null if not _val
		return _val
	catch err
		Log.info("_getUserData parse for path:#{keyPath} fail(ignored):#{err.stack}")
		return err

_getUserDataKeysStr = ->
	RemoteConfigMonitor.getUserDataKeysStr()

_recursiveFetch = (obj, keyLiteral, index)->
	return obj if not obj or not util.isArray(keyLiteral) or index >= keyLiteral.length
	_val = obj[keyLiteral[index]]
	return null if not _val
	return _recursiveFetch(_val, keyLiteral, ++index)

# load at last
_routes = {
	"EQ" : {
		"monitor/sysdata": _getSysData,
		"monitor/userdata": _getUserDataKeysStr,
		"monitor": _getTotal
	},
	"START_WITH" : {
		"monitor/userdata": _getUserData
	}
}

exports.resolve = resolve