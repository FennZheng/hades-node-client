require("should")
zkHelp = require("./zk_help")

RemoteConfig = require("../src/module/config/remote_config").RemoteConfig

HOST = "127.0.0.1:2181"
TEST_NODE = "TestRemoteConfig"

i = 0
getConfig = ()->
	i++
	console.log(" #{i} ---"+RemoteConfig.getDynamic(TEST_NODE))


#setInterval(getConfig,1000)
getConfig()
