ConfigBundles = require("../src/module/config/config_bundles").ConfigBundles

TEST_REMOTE_NODE = "TestRemoteConfig"
TEST_LOCAL_NODE = "test"

ConfigBundles.on(ConfigBundles.CONFIG_READY, ->
	console.log("ConfigBundles receive CONFIG_READY!!")
	console.log("TestRemoteConfig from zookeeper result:"+ConfigBundles.get(TEST_REMOTE_NODE))
	console.log("TestLocalConfig from local file result:"+JSON.stringify(ConfigBundles.get(TEST_LOCAL_NODE)))

)
ConfigBundles.init()