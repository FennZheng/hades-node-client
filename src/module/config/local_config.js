// Generated by CoffeeScript 1.3.3
(function() {
  var ConfigMap, IConfig, LocalConfig, Module, _instance,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Module = require('../../lib/module').Module;

  IConfig = require('./i_config').IConfig;

  ConfigMap = {};

  LocalConfig = (function(_super) {
    var CONFIG_PATH;

    __extends(LocalConfig, _super);

    LocalConfig.include(IConfig);

    CONFIG_PATH = "../../setting/";

    function LocalConfig(path) {
      if (path != null) {
        CONFIG_PATH = path;
      }
    }

    LocalConfig.prototype.get = function(name) {
      if (name.slice(-5, -1) === ".json") {
        throw new Error("config can not end with .json");
      }
      if (!(ConfigMap[name] != null)) {
        ConfigMap[name] = require(CONFIG_PATH + name + ".json");
      }
      return ConfigMap[name];
    };

    LocalConfig.prototype.getDynamic = function(name) {
      return this.get(name);
    };

    return LocalConfig;

  })(Module);

  _instance = new LocalConfig();

  exports.LocalConfig = _instance;

}).call(this);
