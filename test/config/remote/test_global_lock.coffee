ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
TEST_REMOTE_NODE = "testDynamic"
WHITE_IP_LIST = "_whiteIpList"
GLOBAL_LOCK = "_globalLock"
VERSION_CONTROL = "_versionControl"

#run test_dynamic_config at first, then run this

updateGlobalLock = (isLock)->
	_val = {
		"clientUpdateLock" : isLock
	}
	ZkClient.setData(GLOBAL_LOCK, new Buffer(JSON.stringify(_val)), null)


#updateGlobalLock(true)
#then modify_data.js to modify data , log output update is not allow
updateGlobalLock(false)
#then modify_data.js to modify data , log output update is allow


