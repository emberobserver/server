// @todo Handle errors

'use strict';

var RSVP = require('rsvp');
var Registry = require('npm-registry');
var npm = new Registry();
var fs = require('fs');

var SEARCH_KEYWORD = 'ember-addon';
var MAX_ATTEMPTS = 10;

var get = function(name) {
  var promise = new RSVP.Promise(function(resolve, reject) {

    function attemptRequest(name, attempts, callback) {
      if (attempts > MAX_ATTEMPTS) {
        callback(new Error('Too many attempts: ' + name));
      }

      npm.packages.get(name, function(err, data) {
        if (err) {
          attemptRequest(name, attempts + 1, callback);
        } else {
          callback(null, data);
        }
      });
    };

    attemptRequest(name, 1, function(err, data) {
      if (err) {
        reject(err);
      }

      resolve(data[0]);
    });
  });

  return promise;
};

var fetchByKeyword = function() {
  var promise = new RSVP.Promise(function(resolve, reject) {
    npm.packages.keyword(SEARCH_KEYWORD, function(err, data) {
      if (err) {
        reject(err);
      }

      resolve(data);
    });
  });

  return promise;
};

var fetchByKeywordDetailed = function() {
  var promise = new RSVP.Promise(function(resolve, reject) {
    fetchByKeyword().then(function(packages) {
      var promises = packages.map(function(item) {
        if (item.name) {
          return get(item.name);
        }
      });

      resolve(RSVP.all(promises));
    }).catch(function(err) {
      reject(err);
    });
  });

  return promise;
}

fetchByKeywordDetailed().then(function(data) {
  var outputFilename = '/tmp/addons.json';

  fs.writeFile(outputFilename, JSON.stringify(data, null, 2), function(err) {
    if (err) {
      console.log(err);
    } else {
      console.log("Found " + data.length + " add-ons");
      console.log("Saved addons to " + outputFilename);
    }
  })
});
