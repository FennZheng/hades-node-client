ZkProxy = require("../zk/zk_proxy").ZkProxy

class ServiceBundles
	constructor : ->

	init : ->

	register : (serviceId, meta)->
		ZkProxy.registerService(serviceId, meta)

