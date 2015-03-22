require("should")

TEST_DATA_PATH = "/Users/vernonzheng/Project/github/hades-node-client/test/"
LocalConfig = require("../src/module/config/LocalConfig").LocalConfig

describe 'test local config', ->
	config = LocalConfig.get("test",false)
	it 'local config should have property - project', ->
		config.project.should.equal('testProject')
	it 'local config should have property - hostList', ->
		config.hostList.should.equal('localhost:2181')
	it 'local config should have property - retries', ->
		config.retries.should.equal(3)
	it 'local config should have property - sessionTimeout', ->
		config.sessionTimeout.should.equal(60)