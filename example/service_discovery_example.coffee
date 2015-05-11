ServiceBundles = require("../src/module/discovery/service_bundles").ServiceBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_REGISTRY = "ad"
TEST_SERVICE_GET = "ad"

ServiceBundles.init(ConfigFile)

ServiceBundles.get(TEST_SERVICE_GET, (err, data)->
	console.log(JSON.stringify(data))
)

ServiceBundles.register(TEST_SERVICE_REGISTRY, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)
