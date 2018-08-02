var fs = require('fs'),
    http = require('http'),
    url = require('url'),
    sanitize = require('sanitize-filename'),
    pathModule = require('path')
    ;

var server = http.createServer(function(req, res) {
  let path = url.parse(req.url, true).query.path;

  // BAD: This could read any file on the file system
  res.write(fs.readFileSync(path));

  // BAD: This could still read any file on the file system
  res.write(fs.readFileSync("/home/user/" + path));

  // BAD: Insufficient sanitisation
  if (path.startsWith("/home/user/"))
      res.write(fs.readFileSync(path));

  // BAD: Insufficient sanitisation
  if (path.indexOf("secret") == -1)
      res.write(fs.readFileSync(path));

  // BAD: Insufficient sanitisation
  if (fs.existsSync(path))
      res.write(fs.readFileSync(path));

  // GOOD: Path is compared to white-list
  if (path === 'foo.txt')
    res.write(fs.readFileSync(path));

  // GOOD: Path is compared to white-list
  if (path === 'foo.txt' || path === 'bar.txt')
    res.write(fs.readFileSync(path));

  // BAD: Path is incompletely compared to white-list
  if (path === 'foo.txt' || path === 'bar.txt' || someOpaqueCondition())
    res.write(fs.readFileSync(path));

  // GOOD: Path is sanitized
  path = sanitize(path);
  res.write(fs.readFileSync(path));

  path = url.parse(req.url, true).query.path;
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.basename(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.dirname(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.extname(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.join(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.join(x, y, path, z)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.normalize(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.relative(x, path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.relative(path, x)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.resolve(path)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.resolve(x, y, path, z)));
  // BAD: taint is preserved
  res.write(fs.readFileSync(pathModule.toNamespacedPath(path)));
});

angular.module('myApp', [])
    .directive('myCustomer', function() {
        return {
            templateUrl: "SAFE" // OK
        }
    })
    .directive('myCustomer', function() {
        return {
            templateUrl: document.cookie // NOT OK
        }
    })

var server = http.createServer(function(req, res) {
    // tests for a few uri-libraries
    res.write(fs.readFileSync(require("querystringify").parse(req.url).query)); // NOT OK
    res.write(fs.readFileSync(require("query-string").parse(req.url).query)); // NOT OK
    res.write(fs.readFileSync(require("querystring").parse(req.url).query)); // NOT OK
});

(function(){

    var express = require('express');
    var application = express();

    var views_local = (req, res) => res.render(req.params[0]);
    application.get('/views/*', views_local);

    var views_imported = require("./views");
    application.get('/views/*', views_imported);

})();