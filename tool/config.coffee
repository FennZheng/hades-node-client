
projectConfig = {
	"configSource" : "remote",
	"zookeeperConf" : {
		"clusterList" : "",
		"retries" : 3,
		"sessionTimeout" : 5000
	},

	"localConf" : {
		"confRoot" : ""
	},

	"remoteConf" : {
		"groupId" : "",
		"projectId" : ""
	},

	"serviceDiscovery" : {
		"groupId" : "main"
	},
	"monitor" : {
		"disable" : true,
		"port" : 12312
	}
}

toolJsonObj = require("./tool.json")

initProjectConfig = ->
	projectConfig.zookeeperConf.clusterList = toolJsonObj.zookeeper
	projectConfig.localConf.confRoot = process.cwd() + "/import_setting/"
	projectConfig.remoteConf.groupId = toolJsonObj.groupId
	projectConfig.remoteConf.projectId = toolJsonObj.projectId
	return projectConfig


_config = initProjectConfig()

exports.projectConfig = _config