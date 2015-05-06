isDebugEnable = true

debug = (msg)->
	console.log("[DEBUG] #{msg}") if isDebugEnable

info = (msg)->
	console.log("[INFO] #{msg}")

error = (msg)->
	console.error("[ERROR] #{msg}")

exports.debug = debug
exports.info = info
exports.error = error