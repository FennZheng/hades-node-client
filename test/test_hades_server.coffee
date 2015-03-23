net = require('net')

HOST = '127.0.0.1'
PORT = 8888

class Client
	constructor : (id)->
		@_id = id
		@_client = new net.Socket()
		@_client.connect(PORT, HOST, ()->
			console.log('CONNECTED TO: ' + HOST + ':' + PORT)
		)
		@_client.setNoDelay(true);
		@_client.setKeepAlive(true,20000)
		@_client.on('data',(data)->
			console.log('DATA: ' + data)
		)
		@_client.on('error',(error)->
			console.log("error:"+error)
			self.retry()
		)
		@_client.on('close',()->
			console.log('Connection closed')
			self.retry()
		)
		@_client.write("I'm client id"+i+" inited")
		return
	retry : ()->
		console.log('Connection retry')
		@_client.connect(PORT, HOST, ()->
			console.log('CONNECTED TO: ' + HOST + ':' + PORT)
		)
	write : (msg)->
		@_client.write("I'm client id"+i+" msg:"+msg)

client_num = 1

for i in [1..client_num]
	client = new Client(i)


