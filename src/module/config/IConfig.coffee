Module = require("../../lib/Module")
class IConfig extends Module
	###
		static pool
	###
	IS_DYNAMIC = true
	IS_STATIC = false

	###
	    load config
	###
	load = ()->


	###
	    fetch config
	    @param name : config name，unique
	    @param isDynamic :
	        {true:dynamic（only support remote config） false:static}
	###
	get = (name,isDynamic)->

exports.IConfig = IConfig

