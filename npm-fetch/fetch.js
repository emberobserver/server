var RSVP = require('rsvp');
var Registry = require('npm-registry');
var fs = require('fs');

var npm = new Registry({
  registry: 'http://registry.npmjs.org'
});

const MAX_RETRIES = 5;

function wait(ms)
{
  return new RSVP.Promise(function(resolve, reject) {
    setTimeout(resolve, ms);
  });
}

function requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts)
{
  var registryCallback = function(err, data) {
    if (err) {
      if (attempts >= MAX_RETRIES) {
        reject(err);
      } else {
        wait(500 * attempts).then(function() {
          requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts + 1);
        });
      }
    } else {
      if (data[0] && data[0].error && data[0].error === "proxy_error") {
        if (attempts >= MAX_RETRIES) {
          reject(data[0]);
        } else {
          wait(500 * attempts).then(function() {
            requestWithRetries(resolve, reject, endpoint, method, args, successCallback, attempts + 1);
          });
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

function packageDetails(packageName)
{
  return request('packages.details', packageName, function(data) {
    return data[0];
  });
}

function packageDownloads(packageName)
{
  return request('downloads.totals', [ 'last-day', packageName ], function(data) {
    return data[0];
  });
}

if (process.argv.length !== 3) {
  console.error("USAGE: %s %s <package name>", process.argv[0], process.argv[1]);
  process.exit(1);
}

var packageName = process.argv[2];
var thePackageDetails = null;
RSVP.hash({
  package: packageDetails(packageName),
  downloads: packageDownloads(packageName)
}).then(function(data) {
  var details = data.package;
  details.downloads = data.downloads;
  console.log(JSON.stringify(details));
}).catch(function(err) {
  console.log("An error occurred:", err);
});
