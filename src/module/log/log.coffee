require("./../util/date.js")

isDebugEnable = true

debug = (msg)->
	console.log("[#{_getTime()}][DEBUG] #{msg}") if isDebugEnable

info = (msg)->
	console.log("[#{_getTime()}][INFO] #{msg}")

error = (msg)->
	console.error("[#{_getTime()}][ERROR] #{msg}")

_getTime = ->
	new Date().format("yyyy-MM-dd HH:mm:ss.S")

exports.debug = debug
exports.info = info
exports.error = error