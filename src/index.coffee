ConfigBundles = require("./module/config").ConfigBundles
ServiceBundles = require("./module/discovery").ServiceBundles
Log = require("./module/log/log")

initLog = (logger)->
	Log.init(logger)

exports.ConfigBundles = ConfigBundles
exports.ServiceBundles = ServiceBundles
exports.initLog = initLog