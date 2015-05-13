ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
TEST_REMOTE_NODE = "testDynamic"
WHITE_IP_LIST = "_whiteIpList"
GLOBAL_LOCK = "_globalLock"
VERSION_CONTROL = "_versionControl"

#run test_dynamic_config at first, then run this

updateVersionControl = (lastModifyTime)->
	_val = {
		"lastModifyTime" : lastModifyTime
	}
	ZkClient.setData(VERSION_CONTROL, new Buffer(JSON.stringify(_val)))

updateVersionControl(Date.now())

# 



