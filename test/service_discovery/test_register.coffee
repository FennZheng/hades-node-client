ServiceBundles = require("../../src/module/discovery/service_bundles").ServiceBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_REGISTRY = "ad"
PORT = 9090
PORT_1 = 9091
PORT_2 = 9092
PORT_3 = 9093

ServiceBundles.init(ConfigFile)

ServiceBundles.register(TEST_SERVICE_REGISTRY, PORT, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)

ServiceBundles.register(TEST_SERVICE_REGISTRY, PORT_1, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)

ServiceBundles.register(TEST_SERVICE_REGISTRY, PORT_2, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)

ServiceBundles.register(TEST_SERVICE_REGISTRY, PORT_3, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)