Hades = require("../src/index")
Hades.initLog(null)
ServiceBundles = Hades.ServiceBundles

ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_REGISTRY = "ad"
TEST_SERVICE_GET = "ad"


ServiceBundles.on(ServiceBundles.EVENT_READY, ()->
	ServiceBundles.watch(TEST_SERVICE_GET, (err, data)->
	  console.log(JSON.stringify(data))
	)

	ServiceBundles.register(TEST_SERVICE_REGISTRY, 9090, "Meta-ddd", (err, result)->
	  console.log("register result:#{result}, err:#{err}")
	)

	ServiceBundles.register(TEST_SERVICE_REGISTRY, 9091, "Meta-ddd", (err, result)->
	  console.log("register result:#{result}, err:#{err}")
	)
)
ServiceBundles.on(ServiceBundles.EVENT_FAIL, (err)->
	console.error("ServiceBundles init error:#{err.stack}")
)
ServiceBundles.init(ConfigFile)





