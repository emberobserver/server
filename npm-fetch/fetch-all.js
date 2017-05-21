var RSVP = require('rsvp');
var Registry = require('npm-registry');
var async = require('async');
var fs = require('fs');

var eachLimit = RSVP.denodeify(async.eachLimit);

function unique(arr) {
  return arr.filter(function(value, index, self) {
    return self.indexOf(value) === index;
  });
}

function promiseEachLimit(array, limit, workFunction) {
  let results = [ ];
  return eachLimit(array, limit, (value, cb) => {
    workFunction(value)
      .then((result) => results.push({ state: 'fulfilled', value: result }))
      .catch((err) => results.push({ state: 'rejected', reason: err }))
      .finally(() => cb());
  })
  .then(() => RSVP.resolve(results));
}

var npm = new Registry({
  registry: 'http://registry.npmjs.org'
});

const MAX_RETRIES = 5;
const MAX_CONCURRENCY = 5;
const searchKeyword = 'ember-addon';
const outputFilename = '/tmp/addons.json';

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

function packagesWithKeyword(keyword)
{
  return request('packages.keyword', keyword, function(data) {
    return data.map(function(packageInfo) {
      return packageInfo.name;
    });
  });
}

var allPackageDetails = { };
packagesWithKeyword(searchKeyword).then(function(packageNames) {
  return promiseEachLimit(packageNames, MAX_CONCURRENCY, packageDetails);
}).then(function(promises) {
  var packages = promises.filter(p => p.state === 'fulfilled').map(p => p.value);
  return promiseEachLimit(packages, MAX_CONCURRENCY, (package) => {
    allPackageDetails[ package.name ] = package;
    return packageDownloads(package.name);
  });
}).then(function(promises) {
  let downloads = promises.filter(p => p.state === 'fulfilled').map(p => p.value);
  downloads.forEach(function(packageDownloads) {
    allPackageDetails[ packageDownloads.package ].downloads = packageDownloads;
  });
}).then(function() {
  var packageDetailsArray = Object.keys(allPackageDetails).map(function(packageName) {
    return allPackageDetails[ packageName ];
  });
  fs.writeFile(outputFilename, JSON.stringify(packageDetailsArray), function(err) {
    if (err) {
      console.log(err);
    } else {
      console.log("Fetched data for " + packageDetailsArray.length + " add-ons");
    }
  });
}).catch(function(err) {
  console.log("An error occurred:", err);
});
