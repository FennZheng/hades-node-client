ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
TEST_REMOTE_NODE = "testDynamic"

setInterval(
	()->
		ZkClient.setData(TEST_REMOTE_NODE, "222", null)
,1)