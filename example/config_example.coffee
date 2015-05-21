ConfigBundles = require("../src/module/config/config_bundles").ConfigBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"
TEST_REMOTE_NODE = "route"
TEST_LOCAL_NODE = "test"

ConfigBundles.on(ConfigBundles.EVENT_READY, ->
	console.log("ConfigBundles receive EVENT_CONFIG_READY!!")
	console.log("TestRemoteConfig from zookeeper result:"+ConfigBundles.getDynamic(TEST_REMOTE_NODE))
	console.log("TestLocalConfig from local file result:"+JSON.stringify(ConfigBundles.get(TEST_LOCAL_NODE)))
)

ConfigBundles.on(ConfigBundles.EVENT_FAIL, ->
	console.log("ConfigBundles receive EVENT_CONFIG_FAIL!!")
)

ConfigBundles.init(ConfigFile)