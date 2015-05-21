ConfigBundles = require("../../../src/module/config/config_bundles").ConfigBundles
ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/test/setting/test_hades_local.json"

ConfigBundles.on(ConfigBundles.EVENT_READY, ->
	console.log("log/log.json content string:"+JSON.stringify(ConfigBundles.get("log")))
	console.log("3.txt content string:"+JSON.stringify(ConfigBundles.get("3")))
	console.log("deep_object.json content string:"+JSON.stringify(ConfigBundles.get("deep_object")))
	console.log("deep_object.json content /third/third-1 :"+ConfigBundles.get("deep_object")["third"]["third-1"])
	console.log("2.json content string:"+JSON.stringify(ConfigBundles.get("2")))

)
ConfigBundles.on(ConfigBundles.EVENT_FAIL, ->
	console.log("ConfigBundles receive EVENT_CONFIG_FAIL!!")
)
ConfigBundles.init(ConfigFile)

#use ./modify_data.coffee to modify zookeeper data

