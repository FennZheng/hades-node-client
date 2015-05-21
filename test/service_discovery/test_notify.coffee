ServiceBundles = require("../../src/module/discovery/service_bundles").ServiceBundles
ConfigFile = "/Users/vernonzheng/Project/github/hades-node-client/src/setting/hades_config.json"

TEST_SERVICE_GET = "ad"

ServiceBundles.init(ConfigFile)

_eventId1 = "event1"
_eventId2 = "event2"

ServiceBundles.on(ServiceBundles.EVENT_READY, ()->
	ServiceBundles.watch(TEST_SERVICE_GET, _eventId1)
)
ServiceBundles.on(ServiceBundles.EVENT_FAIL, (err)->
	console.error("ServiceBundles init error:#{err.stack}")
)

ServiceBundles.on(_eventId1, (data)->
	console.log("receive new event:#{_eventId1} data:#{data}")
)

ServiceBundles.on(_eventId2, (data)->
	console.log("receive new event:#{_eventId2} data:#{data}")
)


