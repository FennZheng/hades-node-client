ServiceBundles = require("../../src/module/discovery/service_bundles").ServiceBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_REGISTRY = "ad"
URL = "127.0.0.1:9090"
URL_1 = "127.0.0.1:9091"
URL_2 = "127.0.0.1:9092"
URL_3 = "127.0.0.1:9093"

ServiceBundles.on(ServiceBundles.EVENT_READY, ()->
	ServiceBundles.register(TEST_SERVICE_REGISTRY, URL, "Meta-ddd", (err, result)->
	  console.log("register result:#{result}, err:#{err}")
	)
	ServiceBundles.register(TEST_SERVICE_REGISTRY, URL_1, "Meta-ddd", (err, result)->
	  console.log("register result:#{result}, err:#{err}")
	)
)
ServiceBundles.on(ServiceBundles.EVENT_FAIL, (err)->
	console.error("ServiceBundles init error:#{err}")
)
ServiceBundles.init(ConfigFile)


###
setInterval(->
		ServiceBundles.register(TEST_SERVICE_REGISTRY, URL_2, "Meta-ddd", (err, result)->
			console.log("register result:#{result}, err:#{err}")
		)
	,200)

setInterval(->
	ServiceBundles.register(TEST_SERVICE_REGISTRY, URL_3, "Meta-ddd", (err, result)->
		console.log("register result:#{result}, err:#{err}")
	)
,200)
###
