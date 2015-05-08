ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
TEST_REMOTE_NODE = "testDynamic"
WHITE_IP_LIST = "_whiteIpList"
GLOBAL_LOCK = "_globalLock"
VERSION_CONTROL = "_versionControl"

updateDynamicNode = (val)->
	ZkClient.setData(TEST_REMOTE_NODE, new Buffer(val), null)

updateGlobalLock = (isLock)->
	_val = {
		"clientUpdateLock" : isLock
	}
	ZkClient.setData(GLOBAL_LOCK, new Buffer(JSON.stringify(_val)), null)

updateVersionControl = (lastModifyTime)->
	_val = {
		"lastModifyTime" : lastModifyTime
	}
	ZkClient.setData(VERSION_CONTROL, new Buffer(JSON.stringify(_val)))



