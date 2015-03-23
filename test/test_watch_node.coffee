zookeeper = require('node-zookeeper-client')

_zkClient = zookeeper.createClient("localhost:2181")

_zkClient.connect()

TestWatchData = (client, path)->
	client.getData(
		path
		,(event)->
			console.log('Got event: %s.', event)
			TestWatchData(client, path)
		,(err, data, stat)->
			if err
				console.log("getData error:"+err.stack)
			console.log("Got data: %s", data?.toString('utf-8'))
	)

TestWatchData(_zkClient, '/eee/foo')

TestWatchData(_zkClient, '/hades/configs/testProject')


#关注单个节点
#关注/eee/foo节点, 消息只通知一次
#节点修改有消息
#节点被删除没有消息
#get Data获取如果没有节点，error为 NO_NODE[-101], 此时再新增node，收不到通知。

#关注父节点，测试子节点变更通知

#关注父节点，