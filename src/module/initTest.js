var zookeeper = require('node-zookeeper-client');

var client = zookeeper.createClient("localhost:2181", { retries : 2 });

client.once('connected', function () {
	console.log('Connected to the server.');

	var path = "/hades";
	client.create(path, function (error) {
		if (error) {
			console.log('Failed to create node: %s due to: %s.', path, error);
		} else {
			console.log('Node: %s is successfully created.', path);
		}
	});
	path = "/hades/configs"
	client.create(path, function (error) {
		if (error) {
			console.log('Failed to create node: %s due to: %s.', path, error);
		} else {
			console.log('Node: %s is successfully created.', path);
		}
	});
	path = "/hades/configs/testProject"
	client.create(path, function (error) {
		if (error) {
			console.log('Failed to create node: %s due to: %s.', path, error);
		} else {
			console.log('Node: %s is successfully created.', path);
		}
	});

	client.close();
});

client.connect();