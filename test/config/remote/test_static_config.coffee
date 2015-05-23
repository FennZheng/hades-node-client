ConfigBundles = require("../../../src/module/config/config_bundles").ConfigBundles
ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/test/setting/test_hades_remote.json"
TEST_REMOTE_NODE = "testStatic"

# don't use both test_dynamic_config and test_static_config
ConfigBundles.on(ConfigBundles.EVENT_READY, ->
	setInterval( =>
		console.log("node value:"+ConfigBundles.get(TEST_REMOTE_NODE))
	,1000)
)
ConfigBundles.on(ConfigBundles.EVENT_FAIL, ->
	console.log("ConfigBundles receive EVENT_CONFIG_FAIL!!")
)
ConfigBundles.init(ConfigFile)

#use ./modify_data.js to modify zookeeper data

