updateData = (data)->
	zookeeper = require('node-zookeeper-client')
	client = zookeeper.createClient("127.0.0.1:2181", {
		retries: 3,
		sessionTimeout: 10000
	})
	client.setData("/hades/configs/testProject/TestRemoteConfig", new Buffer(data, "utf-8"), 1, (err, stat)->
		if err
			console.log("set data error:"+err.stack)
	)
updateData(33333)
exports.updateData = updateData