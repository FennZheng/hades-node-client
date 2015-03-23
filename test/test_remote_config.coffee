require("should")
zkHelp = require("./zk_help")

RemoteConfig = require("../src/module/config/remote_config").RemoteConfig

HOST = "127.0.0.1:2181"
TEST_CONFIG = "TestRemoteConfig"

describe 'test remote static config', ->
	zkHelp.updateData("first data")
	config = RemoteConfig.get(TEST_CONFIG,false)
	it 'remote config - first data', ->
		config.should.equal("first data")

describe 'test remote dynamic config', ->
	zkHelp.updateData("first data")
	dynamicConfig = RemoteConfig.get(TEST_CONFIG,false)
	it 'remote dynamic config should equal - first data', ->
		dynamicConfig.should.equal("first data")
	it 'remote dyanmic config(when zk node changed) should equal - second data', ->
		zkHelp.updateData("second data")
		dynamicConfig.should.equal("second data")



