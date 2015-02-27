var RSVP = require('rsvp');
var Registry = require('npm-registry');
var fs = require('fs');

var npm = new Registry();

const MAX_RETRIES = 5;

function requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts)
{
	var registryCallback = function(err, data) {
		if (err) {
			if (attempts >= MAX_RETRIES) {
				reject(err);
			} else {
				requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts + 1);
			}
		} else {
			resolve(successCallback(data));
		}
	};
	var argsWithCallback = args.concat(registryCallback);
	npm[endpoint][method].apply(npm[endpoint], argsWithCallback);
}

function request(endpointAndMethod, args, successCallback)
{
	var pieces = endpointAndMethod.split('.');
	var endpoint = pieces[0];
	var method = pieces[1];

	if (typeof(args) !== 'object') {
		args = [ args ];
	}

	return new RSVP.Promise(function(resolve, reject) {
		requestWithRetries(resolve, reject, endpoint, method, args, successCallback);
	});
}

function downloads(packageName)
{
	return request('downloads.range', [ 'last-month', packageName ], function(data) {
		return data[0];
	});
}

var packageNames = JSON.parse(fs.readFileSync('/tmp/addon-names.json'));
var promises = packageNames.map(function(packageName) {
	return downloads(packageName);
});
RSVP.all(promises).then(function(downloadData) {
	fs.writeFile("/tmp/addon-downloads.json", JSON.stringify(downloadData), function(err) {
		if (err) {
			console.log("Error writing output file:", err);
		}
	});
}).catch(function(err) {
	console.log("Error:", err);
});
