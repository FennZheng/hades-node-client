ServiceBundles = require("../../src/module/discovery/service_bundles").ServiceBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_REGISTRY = "ad"

ServiceBundles.init(ConfigFile)

ServiceBundles.register(TEST_SERVICE_REGISTRY, "Meta-ddd", (err, result)->
	console.log("register result:#{result}, err:#{err}")
)
