require("should")
zkHelp = require("./ZkHelp")

RemoteConfig = require("../src/module/config/RemoteConfig").RemoteConfig

HOST = "127.0.0.1:2181"
TEST_NODE = "TestRemoteConfig"


getConfig = ()->
	console.log(RemoteConfig.getDynamic(TEST_NODE))


setInterval(getConfig,1000)
