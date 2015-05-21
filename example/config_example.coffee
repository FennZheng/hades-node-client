Hades = require("../src/index")
Hades.initLog(null)
ConfigBundles = Hades.ConfigBundles

ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"
TEST_REMOTE_NODE = "route"
TEST_LOCAL_NODE = "test"

ConfigBundles.on(ConfigBundles.EVENT_READY, ->
	console.log("ConfigBundles receive EVENT_CONFIG_READY!!")
	console.log("TestRemoteConfig from zookeeper result:#{JSON.stringify(ConfigBundles.getDynamic(TEST_REMOTE_NODE))}")
)

ConfigBundles.on(ConfigBundles.EVENT_FAIL, ->
	console.log("ConfigBundles receive EVENT_CONFIG_FAIL!!")
)

ConfigBundles.init(ConfigFile)