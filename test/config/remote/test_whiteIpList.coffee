ZkClient = require("../../zk_test_util").ZkClient
ZkClient.init()
TEST_REMOTE_NODE = "testDynamic"
WHITE_IP_LIST = "_whiteIpList"
GLOBAL_LOCK = "_globalLock"
VERSION_CONTROL = "_versionControl"

updateWhiteIpList = (ipArray)->
	ZkClient.setData(WHITE_IP_LIST, new Buffer(ipArray), null)

_ipArray = []
_ipArray.push("172.18.0.97")
_ipArray.push("172.18.0.90")
# localIp
_ipArray.push("172.18.0.95")

updateWhiteIpList(_ipArray)
# then use modify_data.js to modify data , is allow to update


_ipArray = []
_ipArray.push("172.18.0.97")
_ipArray.push("172.18.0.90")
# remove localIp
#_ipArray.push("172.18.0.95")

updateWhiteIpList(_ipArray)
# then use modify_data.js to modify data , is not allow to update





