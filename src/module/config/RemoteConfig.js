// Generated by CoffeeScript 1.3.3
(function() {
  var ConfigMap, IConfig, Module, RemoteConfig, ZkProxy, _instance,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Module = require('../../lib/Module').Module;

  IConfig = require('./IConfig').IConfig;

  ZkProxy = require('../zk/ZkProxy').ZkProxy;

  ConfigMap = require('./RemoteConfigStore').ConfigMap;

  RemoteConfig = (function(_super) {

    __extends(RemoteConfig, _super);

    RemoteConfig.include(IConfig);

    function RemoteConfig(path) {
      var CONFIG_PATH;
      if (path != null) {
        CONFIG_PATH = path;
      }
      this._zkProxy = ZkProxy;
    }

    RemoteConfig.prototype.get = function(name) {
      if (!(name != null) || (name.length >= 5 && name.slice(-5, -1) === ".json")) {
        throw new Error("config can not end with .json");
      }
      if (!(ConfigMap[name] != null)) {
        ConfigMap[name] = this._zkProxy.getConfig(name, true);
      }
      return ConfigMap[name];
    };

    RemoteConfig.prototype.getDynamic = function(name) {
      if (!(name != null) || (name.length >= 5 && name.slice(-5, -1) === ".json")) {
        throw new Error("config can not end with .json");
      }
      if (!(ConfigMap[name] != null)) {
        ConfigMap[name] = this._zkProxy.getConfigAndWatch(name);
      }
      return ConfigMap[name];
    };

    return RemoteConfig;

  })(Module);

  _instance = new RemoteConfig();

  exports.RemoteConfig = _instance;

}).call(this);
