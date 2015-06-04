require("./../util/date.js")

class Log
	constructor : ->
		@_logger = null
		@_hasLogger = false
		@isDebugEnable = true

	init : (logger)->
		if not logger
			console.log("hades-node-client use console.log instead, cause by: logger is null")
			return
		@_logger = logger
		@_hasLogger = true
		@isDebugEnable = logger.isDebugEnable?()

	debug : (msg)->
		if @_hasLogger
			@_logger.debug(msg)
		else
			console.log("[#{@_getTime()}][Hades-node-client][DEBUG] #{msg}") if @isDebugEnable

	info : (msg)->
		if @_hasLogger
			@_logger.info(msg)
		else
			console.log("[#{@_getTime()}][Hades-node-client][INFO] #{msg}")

	error : (msg)->
		if @_hasLogger
			@_logger.error(msg)
		else
			console.error("[#{@_getTime()}][Hades-node-client][ERROR] #{msg}")

	_getTime : ->
		new Date().format("yyyy-MM-dd HH:mm:ss.S")

_instance = new Log()

init = (logger)->
	_instance.init(logger)

exports.Log = _instance
exports.init = init