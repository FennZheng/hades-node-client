os = require('os')

getLocalIp = ->
	iface = os.networkInterfaces().en0
	for alias in iface
		if alias.family == 'IPv4' and alias.address != '127.0.0.1' and !alias.internal
			return alias.address
	return null

LOCAL_IP = getLocalIp()

exports.LOCAL_IP = LOCAL_IP