require("should")
zkHelp = require("./ZkHelp")

RemoteConfig = require("../src/module/config/RemoteConfig").RemoteConfig

HOST = "127.0.0.1:2181"
TEST_NODE = "TestRemoteConfig"

i = 0
getConfig = ()->
	i++
	console.log(" #{i} ---"+RemoteConfig.getDynamic(TEST_NODE))


#setInterval(getConfig,1000)
getConfig()
