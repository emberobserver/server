var RSVP = require('rsvp');
var Registry = require('npm-registry');
var async = require('async');
var fs = require('fs');

var eachLimit = RSVP.denodeify(async.eachLimit);
var npm = new Registry({
  registry: 'http://registry.npmjs.org'
});

const MAX_RETRIES = 5;
const MAX_CONCURRENCY = 5;

function promiseEachLimit(array, limit, workFunction) {
  let results = [ ];
  return eachLimit(array, limit, (value, cb) => {
    workFunction(value)
      .then((result) => results.push({ state: 'fulfilled', value: result }))
      .catch((err) => results.push({ state: 'rejected', reason: err, inputValue: value }))
      .finally(() => cb());
  })
  .then(() => RSVP.resolve(results));
}

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
			if (data && data[0] && data[0].error === 'proxy_error') {
				if (attempts >= MAX_RETRIES) {
					reject(data[0]);
				} else {
					requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts + 1);
				}
			} else {
				resolve(successCallback(data));
			}
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
		requestWithRetries(resolve, reject, endpoint, method, args, successCallback, 0);
	});
}

function downloads(packageName)
{
	return request('downloads.range', [ 'last-month', packageName ], function(data) {
		return data[0];
	});
}

var packageNames = JSON.parse(fs.readFileSync('/tmp/addon-names.json'));
promiseEachLimit(packageNames, MAX_CONCURRENCY, (packageName) => downloads(packageName))
	.then(function(promises) {
		promises.filter(p => p.state === 'rejected').map(p => p.inputValue).forEach(packageName => console.log('WARN: failed to get download data for', packageName));
		let downloadData = promises.filter(p => p.state === 'fulfilled').map(p => p.value);
		fs.writeFile("/tmp/addon-downloads.json", JSON.stringify(downloadData), function(err) {
			if (err) {
				console.log("Error writing output file:", err);
			}
		});
	}).catch(function(err) {
		console.log("Error:", err);
	});
