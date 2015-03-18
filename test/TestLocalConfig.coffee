require("should")

TEST_DATA_PATH = "/Users/vernonzheng/Project/github/hades-node-client/test/"
LocalConfig = require("../src/module/config/LocalConfig").LocalConfig
localConfig = new LocalConfig(TEST_DATA_PATH)
config = localConfig.get("test",false)

describe 'test local config', ->
	config = localConfig.get("test",false)
	it 'local config should be a object', ->
		config.should.be.a('object')
	it 'local config should have property - project', ->
		config.should.have.property('project')
	it 'local config should have property - hostList', ->
		config.should.have.property('hostList')
	it 'local config should have property - retries', ->
		config.should.have.property('retries')
	it 'local config should have property - sessionTimeout', ->
		config.should.have.property('sessionTimeout')
	it 'local config should have property - project', ->
		config.project.should.equal('testProject')
	it 'local config should have property - hostList', ->
		config.hostList.should.equal('localhost:2181')
	it 'local config should have property - retries', ->
		config.retries.should.equal(3)
	it 'local config should have property - sessionTimeout', ->
		config.sessionTimeout.should.equal(60)
